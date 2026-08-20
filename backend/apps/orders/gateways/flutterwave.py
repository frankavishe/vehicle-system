"""Flutterwave v3 hosted-checkout client. Covers card, Airtel Money, Tigo
Pesa, HaloPesa (PLAN.md §5.3) — everything except Vodacom M-Pesa, which
Selcom carries instead (see `selcom.py`).

Flutterwave offers self-serve sandbox/test API keys at signup (no business
KYC required until going live), so this client is written to be exercised
against a real Flutterwave test account, unlike Selcom's mock-only client —
see PLAN.md-derived Phase 2 plan for that asymmetry."""

import hmac

import requests
from django.conf import settings

from .base import BaseGatewayClient, CheckoutResult, VerifiedTransaction


class FlutterwaveClient(BaseGatewayClient):
    def __init__(self):
        self.base_url = settings.FLUTTERWAVE_BASE_URL
        self.secret_key = settings.FLUTTERWAVE_SECRET_KEY

    def _headers(self):
        return {"Authorization": f"Bearer {self.secret_key}", "Content-Type": "application/json"}

    def initiate_checkout(self, *, payment, redirect_url: str) -> CheckoutResult:
        # payment.transaction_ref is always set by initiate_payment() before
        # a gateway client is ever called (see services/payments.py).
        tx_ref = payment.transaction_ref
        customer = payment.order.customer if payment.order_id else None
        body = {
            "tx_ref": tx_ref,
            "amount": str(payment.amount),
            "currency": settings.DEFAULT_CURRENCY,
            "redirect_url": redirect_url,
            # "mobilemoneytanzania" is Flutterwave's single umbrella option
            # covering Airtel Money/Tigo Pesa/HaloPesa for TZ — the
            # specific network is chosen by the customer on Flutterwave's
            # hosted checkout page, not selected by us here.
            "payment_options": "card,mobilemoneytanzania",
            "customer": {
                "email": customer.email if customer else "",
                "phonenumber": customer.phone if customer else "",
                "name": customer.full_name if customer else "",
            },
        }
        response = requests.post(
            f"{self.base_url}/v3/payments", json=body, headers=self._headers(), timeout=15
        )
        response.raise_for_status()
        data = response.json()["data"]
        return CheckoutResult(checkout_url=data["link"], gateway_transaction_id=None)

    def verify_transaction(self, transaction_ref: str) -> VerifiedTransaction:
        response = requests.get(
            f"{self.base_url}/v3/transactions/verify_by_reference",
            params={"tx_ref": transaction_ref},
            headers=self._headers(),
            timeout=15,
        )
        response.raise_for_status()
        data = response.json()["data"]
        status = "SUCCESSFUL" if data["status"] == "successful" else "FAILED"
        return VerifiedTransaction(
            status=status,
            amount=data["amount"],
            currency=data["currency"],
            gateway_transaction_id=str(data["id"]),
        )

    def verify_webhook_signature(self, request) -> bool:
        # Flutterwave v3 webhooks use a static shared secret compared
        # against the `verif-hash` header — not a computed HMAC of the
        # body. Constant-time comparison to avoid a timing side-channel.
        received = request.headers.get("verif-hash", "")
        expected = settings.FLUTTERWAVE_WEBHOOK_SECRET_HASH
        if not expected or not received:
            return False
        return hmac.compare_digest(received, expected)
