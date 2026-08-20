"""Selcom Checkout API client — carries Vodacom M-Pesa (Tanzania) only,
per the routing table in `routing.py` (Selcom's own coverage is broader,
but PLAN.md §5.3/§8 deliberately keeps Flutterwave for the other three
wallets + cards).

**No self-serve Selcom sandbox exists** (Selcom onboarding requires direct
contact or a Selcom Integration Partner — PLAN.md §8) — this client is
therefore built and tested entirely against mocked HTTP responses shaped
per Selcom's publicly documented API, not a live integration. The exact
webhook signing header/algorithm below is docs-based and NOT yet confirmed
against a live Selcom account (same epistemic caveat class as PLAN.md
§8's Flutterwave M-Pesa gap finding) — it's isolated into one function
specifically so a correction later is a one-function fix, not a refactor.
"""

import hashlib
import hmac
import json

import requests
from django.conf import settings

from .base import BaseGatewayClient, CheckoutResult, VerifiedTransaction


class SelcomClient(BaseGatewayClient):
    def __init__(self):
        self.base_url = settings.SELCOM_BASE_URL
        self.api_key = settings.SELCOM_API_KEY
        self.api_secret = settings.SELCOM_API_SECRET
        self.vendor_id = settings.SELCOM_VENDOR_ID

    def _headers(self, body: bytes):
        # Selcom's Checkout API authenticates via an API-key + HMAC digest
        # of the request body (Bearer-token style, per PLAN.md's summary
        # of Selcom's docs) rather than a static shared secret.
        digest = hmac.new(self.api_secret.encode(), body, hashlib.sha256).hexdigest()
        return {
            "Content-Type": "application/json",
            "Authorization": f"SELCOM {self.api_key}",
            "Digest-Method": "HS256",
            "Digest": digest,
        }

    def initiate_checkout(self, *, payment, redirect_url: str) -> CheckoutResult:
        # payment.transaction_ref is always set by initiate_payment() before
        # a gateway client is ever called (see services/payments.py).
        order_id = payment.transaction_ref
        customer = payment.order.customer if payment.order_id else None
        body = json.dumps(
            {
                "vendor": self.vendor_id,
                "order_id": order_id,
                "buyer_email": customer.email if customer else "",
                "buyer_phone": customer.phone if customer else "",
                "amount": str(payment.amount),
                "currency": settings.DEFAULT_CURRENCY,
                # MPESA-TZ: the only rail this client is ever routed for
                # (see routing.py) — push-USSD wallet-pull prompts the
                # customer's phone directly, no redirect needed, but we
                # still pass redirect_url for Selcom's own completion page.
                "payment_method": "MPESA-TZ",
                "redirect_url": redirect_url,
            }
        ).encode()
        response = requests.post(
            f"{self.base_url}/v1/checkout/create-order-minimal",
            data=body,
            headers=self._headers(body),
            timeout=15,
        )
        response.raise_for_status()
        data = response.json()["data"][0]
        return CheckoutResult(
            checkout_url=data["payment_gateway_url"], gateway_transaction_id=data.get("reference")
        )

    def verify_transaction(self, transaction_ref: str) -> VerifiedTransaction:
        response = requests.get(
            f"{self.base_url}/v1/checkout/order-status",
            params={"order_id": transaction_ref, "vendor": self.vendor_id},
            headers=self._headers(b""),
            timeout=15,
        )
        response.raise_for_status()
        data = response.json()["data"][0]
        status = "SUCCESSFUL" if data["payment_status"] == "COMPLETED" else "FAILED"
        return VerifiedTransaction(
            status=status,
            amount=data["amount"],
            currency=settings.DEFAULT_CURRENCY,
            gateway_transaction_id=data.get("reference", transaction_ref),
        )

    def verify_webhook_signature(self, request) -> bool:
        received = request.headers.get("Digest", "")
        if not received:
            return False
        expected = hmac.new(self.api_secret.encode(), request.body, hashlib.sha256).hexdigest()
        return hmac.compare_digest(received, expected)
