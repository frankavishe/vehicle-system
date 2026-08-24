"""POST /webhooks/flutterwave, POST /webhooks/selcom.

Both follow the identical two-step flow PLAN.md §5.3 mandates: (1) verify
the webhook's own signature, (2) make a genuine server-to-server call to
the gateway's verify-transaction endpoint — never trust the webhook
payload's self-reported status/amount. Idempotent: a payment already past
PENDING is left alone, so gateway retries/duplicate deliveries are no-ops.
"""

import logging

from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .gateways.flutterwave import FlutterwaveClient
from .gateways.selcom import SelcomClient
from .models import Order, OrderStatus, Payment, PaymentStatus

logger = logging.getLogger(__name__)


def _apply_verified_result(payment, verified):
    if payment.status != PaymentStatus.PENDING:
        return  # already settled — idempotent no-op on webhook replay

    if verified.status != "SUCCESSFUL" or verified.amount != payment.amount:
        payment.status = PaymentStatus.FAILED
        payment.gateway_transaction_id = verified.gateway_transaction_id
        payment.save(update_fields=["status", "gateway_transaction_id"])
        return

    payment.status = PaymentStatus.SUCCESSFUL
    payment.gateway_transaction_id = verified.gateway_transaction_id
    payment.save(update_fields=["status", "gateway_transaction_id"])

    if payment.order_id:
        Order.objects.filter(pk=payment.order_id).update(status=OrderStatus.PAID)
    elif payment.service_request_id:
        # Phase 4: no service_status value means "paid" (§3.1's
        # service_status enum has no such state — the request is already
        # COMPLETED by the time it's payable, see
        # apps.dispatch.views.ServiceRequestPayView) — the only cascade
        # needed here is telling both parties the money cleared.
        from apps.notifications.models import NotificationCategory
        from apps.notifications.services.create import create_and_send

        sr = payment.service_request
        create_and_send(
            user=sr.customer,
            category=NotificationCategory.GENERAL,
            title="Payment received",
            body=f"Your payment of {payment.amount} for this {sr.service_type.lower()} request was received.",
        )
        if sr.provider_id:
            create_and_send(
                user=sr.provider,
                category=NotificationCategory.GENERAL,
                title="Payment received",
                body=f"The customer's payment of {payment.amount} for this job was received.",
            )


class _BaseWebhookView(APIView):
    permission_classes = [permissions.AllowAny]
    authentication_classes = []  # gateway callbacks carry no JWT
    client_class = None

    def post(self, request):
        client = self.client_class()
        if not client.verify_webhook_signature(request):
            return Response({"detail": "Invalid signature."}, status=status.HTTP_400_BAD_REQUEST)

        tx_ref = self.extract_tx_ref(request)
        if not tx_ref:
            return Response({"detail": "Missing transaction reference."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            payment = Payment.objects.get(transaction_ref=tx_ref)
        except Payment.DoesNotExist:
            logger.warning("Webhook for unknown transaction_ref=%s", tx_ref)
            return Response({"detail": "Unknown transaction."}, status=status.HTTP_404_NOT_FOUND)

        verified = client.verify_transaction(tx_ref)
        _apply_verified_result(payment, verified)
        return Response({"detail": "ok"}, status=status.HTTP_200_OK)

    def extract_tx_ref(self, request):
        raise NotImplementedError


class FlutterwaveWebhookView(_BaseWebhookView):
    client_class = FlutterwaveClient

    def extract_tx_ref(self, request):
        return request.data.get("data", {}).get("tx_ref")


class SelcomWebhookView(_BaseWebhookView):
    client_class = SelcomClient

    def extract_tx_ref(self, request):
        return request.data.get("order_id")
