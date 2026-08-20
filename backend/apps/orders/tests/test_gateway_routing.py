import pytest

from apps.orders.gateways.flutterwave import FlutterwaveClient
from apps.orders.gateways.routing import get_gateway_client, select_gateway
from apps.orders.gateways.selcom import SelcomClient
from apps.orders.models import PaymentMethod, ProviderGateway


@pytest.mark.parametrize(
    "payment_method,expected_gateway",
    [
        (PaymentMethod.CARD, ProviderGateway.FLUTTERWAVE),
        (PaymentMethod.AIRTEL_MONEY, ProviderGateway.FLUTTERWAVE),
        (PaymentMethod.TIGO_PESA, ProviderGateway.FLUTTERWAVE),
        (PaymentMethod.HALOPESA, ProviderGateway.FLUTTERWAVE),
        (PaymentMethod.MPESA, ProviderGateway.SELCOM),
    ],
)
def test_select_gateway_routes_every_payment_method(payment_method, expected_gateway):
    assert select_gateway(payment_method) == expected_gateway


def test_select_gateway_rejects_unknown_method():
    with pytest.raises(ValueError):
        select_gateway("BITCOIN")


def test_get_gateway_client_returns_flutterwave():
    assert isinstance(get_gateway_client(ProviderGateway.FLUTTERWAVE), FlutterwaveClient)


def test_get_gateway_client_returns_selcom():
    assert isinstance(get_gateway_client(ProviderGateway.SELCOM), SelcomClient)


def test_get_gateway_client_rejects_unknown_gateway():
    with pytest.raises(ValueError):
        get_gateway_client("STRIPE")
