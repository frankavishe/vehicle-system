"""Payment initiation, generic over `order=`/`service_request=` — Phase 4's
`/service-requests/{id}/pay` (apps/dispatch/views.py) calls this same
function with `service_request=` instead of `order=`, now that the fare
engine (PLAN.md §5.2) populates `estimated_fare`/`final_fare`."""

import requests
from django.conf import settings
from rest_framework import serializers

from ..gateways.routing import get_gateway_client, select_gateway
from ..models import Payment, PaymentStatus
from .checkout import cancel_order


def initiate_payment(*, user, payment_method, order=None, service_request=None):
    if bool(order) == bool(service_request):
        raise serializers.ValidationError(
            "Exactly one of order or service_request must be given."
        )

    amount = order.total_amount if order else service_request.final_fare or service_request.estimated_fare
    if amount is None:
        raise serializers.ValidationError("This service request has no fare to charge yet.")

    provider_gateway = select_gateway(payment_method)
    payment = Payment.objects.create(
        order=order,
        service_request=service_request,
        payment_method=payment_method,
        provider_gateway=provider_gateway,
        amount=amount,
    )
    # transaction_ref must be committed *before* calling the gateway, since
    # the client sends this exact value as its tx_ref/order_id — the later
    # webhook/verify_transaction lookup keys off payment.transaction_ref,
    # so gateway and DB must agree on it from the start.
    payment.transaction_ref = str(payment.id)
    payment.save(update_fields=["transaction_ref"])

    client = get_gateway_client(provider_gateway)
    # Phase 4: service_request has no /checkout/complete-style page of its
    # own yet (web/'s Phase 4 tracking page is `/track/{id}`, not a
    # payment-completion page) — reuse the same query-string shape with a
    # `service_request_id` key instead of `order_id` so a future page can
    # tell the two apart without a different route.
    redirect_target = order.id if order else service_request.id
    redirect_param = "order_id" if order else "service_request_id"
    redirect_url = (
        f"{settings.FRONTEND_BASE_URL}/checkout/complete?{redirect_param}={redirect_target}"
    )
    try:
        result = client.initiate_checkout(payment=payment, redirect_url=redirect_url)
    except requests.RequestException:
        # The gateway call never produced a usable response (network
        # failure, DNS, timeout, or a non-2xx status via raise_for_status())
        # — don't leave `order` sitting PENDING forever holding a stock
        # reservation for a payment that never actually started (see
        # services/checkout.py's reserve-at-creation policy). A
        # service_request has no stock to release, so there's nothing to
        # cancel on that path.
        payment.status = PaymentStatus.FAILED
        payment.save(update_fields=["status"])
        if order is not None:
            cancel_order(order)
        raise serializers.ValidationError(
            "The payment provider could not be reached. Please try again."
        )

    if result.gateway_transaction_id:
        payment.gateway_transaction_id = result.gateway_transaction_id
        payment.save(update_fields=["gateway_transaction_id"])

    return {"payment_id": payment.id, "checkout_url": result.checkout_url}
