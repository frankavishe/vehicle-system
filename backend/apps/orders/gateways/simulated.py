"""TEMPORARY stand-in for FlutterwaveClient/SelcomClient — see
PAYMENT_SIMULATION_MODE's docstring in config/settings/base.py for the
full removal list. `routing.get_gateway_client()` hands back this client
for every payment while PAYMENT_SIMULATION_MODE is on, so checkout can be
exercised end-to-end (order -> pay -> "gateway" page -> webhook-equivalent
-> order PAID) without real gateway credentials or real money.

Unlike the real clients, `initiate_checkout` never leaves our own
infrastructure: it points the customer at web/'s
`/checkout/simulate` page instead of a hosted Flutterwave/Selcom URL.
That page's "Simulate successful/failed payment" buttons call
`CheckoutPaymentSimulateView` (apps/orders/views.py), which applies the
same `apply_verified_result` logic a real webhook would (see
services/payments.py) rather than duplicating it."""

from urllib.parse import quote

from django.conf import settings

from ..models import PaymentStatus
from .base import BaseGatewayClient, CheckoutResult, DisbursementResult, VerifiedTransaction


class SimulatedGatewayClient(BaseGatewayClient):
    def initiate_checkout(self, *, payment, redirect_url: str) -> CheckoutResult:
        checkout_url = (
            f"{settings.FRONTEND_BASE_URL}/checkout/simulate"
            f"?payment_id={payment.id}&redirect_url={quote(redirect_url, safe='')}"
        )
        return CheckoutResult(
            checkout_url=checkout_url, gateway_transaction_id=f"SIM-{payment.transaction_ref}"
        )

    def verify_transaction(self, transaction_ref: str) -> VerifiedTransaction:
        # Not called on the simulated path (CheckoutPaymentSimulateView
        # applies the outcome directly instead of routing through a
        # webhook), but implemented for interface completeness / in case
        # something re-verifies later — reflects whatever the payment's
        # status already is rather than re-deciding it.
        from ..models import Payment

        payment = Payment.objects.get(transaction_ref=transaction_ref)
        status = "SUCCESSFUL" if payment.status == PaymentStatus.SUCCESSFUL else "FAILED"
        return VerifiedTransaction(
            status=status,
            amount=payment.amount,
            currency=settings.DEFAULT_CURRENCY,
            gateway_transaction_id=payment.gateway_transaction_id or f"SIM-{transaction_ref}",
        )

    def verify_webhook_signature(self, request) -> bool:
        # No real webhook ever arrives for a simulated payment — the
        # simulate page calls CheckoutPaymentSimulateView directly instead.
        return True

    def disburse(self, *, payout, phone: str) -> DisbursementResult:
        return DisbursementResult(status="PAID", gateway_transaction_id=f"SIM-{payout.id}")
