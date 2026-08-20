from decimal import Decimal

import pytest
from django.urls import reverse
from rest_framework import status

from apps.orders.gateways.base import CheckoutResult
from apps.orders.models import OrderStatus, Payment
from apps.orders.tests.factories import OrderFactory

pytestmark = pytest.mark.django_db


class _FakeGatewayClient:
    def initiate_checkout(self, *, payment, redirect_url):
        return CheckoutResult(checkout_url="https://checkout.test/session/abc", gateway_transaction_id="gw-1")


@pytest.fixture
def fake_gateway(monkeypatch):
    monkeypatch.setattr(
        "apps.orders.services.payments.get_gateway_client", lambda provider_gateway: _FakeGatewayClient()
    )


def test_pay_creates_payment_and_returns_checkout_url(auth_client, customer_user, fake_gateway):
    order = OrderFactory(customer=customer_user, status=OrderStatus.PENDING, total_amount="5000.00")
    client = auth_client(customer_user)
    response = client.post(reverse("orders-pay", args=[order.id]), {"payment_method": "CARD"})

    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["checkout_url"] == "https://checkout.test/session/abc"
    payment = Payment.objects.get(order=order)
    assert payment.provider_gateway == "FLUTTERWAVE"
    assert payment.amount == Decimal("5000.00")
    assert payment.transaction_ref == str(payment.id)
    assert payment.gateway_transaction_id == "gw-1"


def test_pay_routes_mpesa_to_selcom(auth_client, customer_user, fake_gateway):
    order = OrderFactory(customer=customer_user, status=OrderStatus.PENDING, total_amount="5000.00")
    client = auth_client(customer_user)
    response = client.post(reverse("orders-pay", args=[order.id]), {"payment_method": "MPESA"})
    assert response.status_code == status.HTTP_201_CREATED
    payment = Payment.objects.get(order=order)
    assert payment.provider_gateway == "SELCOM"


def test_pay_requires_payment_method(auth_client, customer_user, fake_gateway):
    order = OrderFactory(customer=customer_user)
    client = auth_client(customer_user)
    response = client.post(reverse("orders-pay", args=[order.id]), {})
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_pay_requires_ownership(auth_client, customer_user, fake_gateway):
    order = OrderFactory()  # different customer
    client = auth_client(customer_user)
    response = client.post(reverse("orders-pay", args=[order.id]), {"payment_method": "CARD"})
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_pay_requires_auth(api_client):
    order = OrderFactory()
    response = api_client.post(reverse("orders-pay", args=[order.id]), {"payment_method": "CARD"})
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
