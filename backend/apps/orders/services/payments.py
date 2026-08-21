"""Payment initiation, generic over `order=`/`service_request=` so
Phase 4's `/service-requests/{id}/pay` can call this same function with
`service_request=` instead of `order=` — no rework needed then."""

from django.conf import settings
from rest_framework import serializers

from ..gateways.routing import get_gateway_client, select_gateway
from ..models import Payment


def initiate_payment(*, user, payment_method, order=None, service_request=None):
    if bool(order) == bool(service_request):
        raise serializers.ValidationError(
            "Exactly one of order or service_request must be given."
        )

    amount = order.total_amount if order else service_request.final_fare or service_request.estimated_fare
    if amount is None:
        # Phase 4 territory: the OSRM/Haversine fare engine (PLAN.md §5.2)
        # is what actually populates estimated_fare/final_fare — until
        # then a service_request has no fare to charge.
        raise NotImplementedError("service_request fare calculation is wired up in Phase 4.")

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
    redirect_url = f"{settings.FRONTEND_BASE_URL}/checkout/complete?order_id={order.id}"
    result = client.initiate_checkout(payment=payment, redirect_url=redirect_url)

    if result.gateway_transaction_id:
        payment.gateway_transaction_id = result.gateway_transaction_id
        payment.save(update_fields=["gateway_transaction_id"])

    return {"payment_id": payment.id, "checkout_url": result.checkout_url}
