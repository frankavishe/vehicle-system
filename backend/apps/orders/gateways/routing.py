"""The single source of truth for the Flutterwave/Selcom split (PLAN.md
§5.3). Every payment initiation and every webhook route ultimately calls
`select_gateway`/`get_gateway_client` from here — nothing else in the
codebase should know which method maps to which gateway."""

from ..models import PaymentMethod, ProviderGateway

_GATEWAY_BY_METHOD = {
    PaymentMethod.CARD: ProviderGateway.FLUTTERWAVE,
    PaymentMethod.AIRTEL_MONEY: ProviderGateway.FLUTTERWAVE,
    PaymentMethod.TIGO_PESA: ProviderGateway.FLUTTERWAVE,
    PaymentMethod.HALOPESA: ProviderGateway.FLUTTERWAVE,
    PaymentMethod.MPESA: ProviderGateway.SELCOM,
}


def select_gateway(payment_method: str) -> str:
    try:
        return _GATEWAY_BY_METHOD[payment_method]
    except KeyError:
        raise ValueError(f"No gateway routing configured for payment method '{payment_method}'.")


def get_gateway_client(provider_gateway: str):
    # Imported lazily to avoid importing both gateway SDKs' modules (and
    # their settings-dependent client construction) unless actually needed.
    if provider_gateway == ProviderGateway.FLUTTERWAVE:
        from .flutterwave import FlutterwaveClient

        return FlutterwaveClient()
    if provider_gateway == ProviderGateway.SELCOM:
        from .selcom import SelcomClient

        return SelcomClient()
    raise ValueError(f"Unknown provider gateway '{provider_gateway}'.")
