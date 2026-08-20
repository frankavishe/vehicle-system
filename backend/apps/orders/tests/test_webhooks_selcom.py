import hashlib
import hmac
import json

import pytest
import responses
from django.urls import reverse
from rest_framework import status

from apps.orders.models import OrderStatus, PaymentStatus
from apps.orders.tests.factories import OrderFactory, PaymentFactory

pytestmark = pytest.mark.django_db


def _configure(settings):
    settings.SELCOM_BASE_URL = "https://selcom.test"
    settings.SELCOM_API_KEY = "key123"
    settings.SELCOM_API_SECRET = "secret123"
    settings.SELCOM_VENDOR_ID = "VEND1"


def _mock_verify(payment_status, amount):
    responses.add(
        responses.GET,
        "https://selcom.test/v1/checkout/order-status",
        json={"data": [{"payment_status": payment_status, "amount": amount, "reference": "REF1"}]},
        status=200,
    )


def _post_webhook(api_client, body: dict):
    raw = json.dumps(body).encode()
    digest = hmac.new(b"secret123", raw, hashlib.sha256).hexdigest()
    return api_client.post(
        reverse("webhook-selcom"), data=raw, content_type="application/json", HTTP_DIGEST=digest
    )


@responses.activate
def test_webhook_rejects_invalid_signature(api_client, settings):
    _configure(settings)
    payment = PaymentFactory(
        transaction_ref="tx-2", amount="1500.00", payment_method="MPESA", provider_gateway="SELCOM"
    )
    response = api_client.post(
        reverse("webhook-selcom"),
        data=json.dumps({"order_id": "tx-2"}).encode(),
        content_type="application/json",
        HTTP_DIGEST="wrong-digest",
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    payment.refresh_from_db()
    assert payment.status == PaymentStatus.PENDING


@responses.activate
def test_webhook_unknown_transaction_ref_404s(api_client, settings):
    _configure(settings)
    response = _post_webhook(api_client, {"order_id": "does-not-exist"})
    assert response.status_code == status.HTTP_404_NOT_FOUND


@responses.activate
def test_webhook_marks_payment_successful_and_order_paid(api_client, settings):
    _configure(settings)
    order = OrderFactory(status=OrderStatus.PENDING)
    payment = PaymentFactory(
        order=order,
        transaction_ref="tx-2",
        amount="1500.00",
        payment_method="MPESA",
        provider_gateway="SELCOM",
    )
    _mock_verify("COMPLETED", 1500)

    response = _post_webhook(api_client, {"order_id": "tx-2"})

    assert response.status_code == status.HTTP_200_OK
    payment.refresh_from_db()
    order.refresh_from_db()
    assert payment.status == PaymentStatus.SUCCESSFUL
    assert order.status == OrderStatus.PAID


@responses.activate
def test_webhook_amount_mismatch_marks_failed_not_paid(api_client, settings):
    _configure(settings)
    order = OrderFactory(status=OrderStatus.PENDING)
    payment = PaymentFactory(
        order=order,
        transaction_ref="tx-2",
        amount="1500.00",
        payment_method="MPESA",
        provider_gateway="SELCOM",
    )
    _mock_verify("COMPLETED", 1)  # gateway confirms a different (lower) amount — fraud case

    response = _post_webhook(api_client, {"order_id": "tx-2"})

    assert response.status_code == status.HTTP_200_OK
    payment.refresh_from_db()
    order.refresh_from_db()
    assert payment.status == PaymentStatus.FAILED
    assert order.status == OrderStatus.PENDING


@responses.activate
def test_webhook_is_idempotent_on_replay(api_client, settings):
    _configure(settings)
    order = OrderFactory(status=OrderStatus.PENDING)
    payment = PaymentFactory(
        order=order,
        transaction_ref="tx-2",
        amount="1500.00",
        payment_method="MPESA",
        provider_gateway="SELCOM",
    )
    _mock_verify("COMPLETED", 1500)
    _mock_verify("COMPLETED", 1500)  # second delivery

    first = _post_webhook(api_client, {"order_id": "tx-2"})
    second = _post_webhook(api_client, {"order_id": "tx-2"})

    assert first.status_code == status.HTTP_200_OK
    assert second.status_code == status.HTTP_200_OK
    payment.refresh_from_db()
    order.refresh_from_db()
    assert payment.status == PaymentStatus.SUCCESSFUL
    assert order.status == OrderStatus.PAID
