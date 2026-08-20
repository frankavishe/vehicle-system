"""Shared gateway client interface — every gateway implements these three
methods identically so webhook handling and payment initiation stay
uniform across Flutterwave/Selcom (PLAN.md §5.3)."""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from decimal import Decimal


@dataclass
class CheckoutResult:
    checkout_url: str
    gateway_transaction_id: str | None = None


@dataclass
class VerifiedTransaction:
    status: str  # "SUCCESSFUL" | "FAILED"
    amount: Decimal
    currency: str
    gateway_transaction_id: str


class BaseGatewayClient(ABC):
    @abstractmethod
    def initiate_checkout(self, *, payment, redirect_url: str) -> CheckoutResult:
        """Starts a hosted-checkout session for `payment` (an
        `apps.orders.models.Payment` instance) and returns where to send
        the customer."""

    @abstractmethod
    def verify_transaction(self, transaction_ref: str) -> VerifiedTransaction:
        """Server-to-server call to the gateway's own verify endpoint.
        Never trust a webhook's self-reported status/amount — always
        confirm against this (PLAN.md §5.3)."""

    @abstractmethod
    def verify_webhook_signature(self, request) -> bool:
        """Validates an inbound webhook request's signature/hash header."""
