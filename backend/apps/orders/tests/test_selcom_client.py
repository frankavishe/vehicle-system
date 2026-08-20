import hashlib
import hmac

import pytest
import responses
from django.test import RequestFactory

from apps.orders.gateways.selcom import SelcomClient
from apps.orders.tests.factories import PaymentFactory

pytestmark = pytest.mark.django_db


@responses.activate
def test_initiate_checkout_returns_hosted_link(settings):
    settings.SELCOM_BASE_URL = "https://selcom.test"
    settings.SELCOM_API_KEY = "key123"
    settings.SELCOM_API_SECRET = "secret123"
    settings.SELCOM_VENDOR_ID = "VEND1"
    responses.add(
        responses.POST,
        "https://selcom.test/v1/checkout/create-order-minimal",
        json={"data": [{"payment_gateway_url": "https://pay.selcom.test/xyz", "reference": "REF1"}]},
        status=200,
    )
    payment = PaymentFactory(
        transaction_ref="tx-2", amount="1500.00", payment_method="MPESA", provider_gateway="SELCOM"
    )

    client = SelcomClient()
    result = client.initiate_checkout(
        payment=payment, redirect_url="https://app.test/checkout/complete"
    )

    assert result.checkout_url == "https://pay.selcom.test/xyz"
    assert result.gateway_transaction_id == "REF1"


@responses.activate
def test_verify_transaction_maps_completed_status(settings):
    settings.SELCOM_BASE_URL = "https://selcom.test"
    settings.SELCOM_API_KEY = "key123"
    settings.SELCOM_API_SECRET = "secret123"
    settings.SELCOM_VENDOR_ID = "VEND1"
    responses.add(
        responses.GET,
        "https://selcom.test/v1/checkout/order-status",
        json={"data": [{"payment_status": "COMPLETED", "amount": 1500, "reference": "REF1"}]},
        status=200,
    )
    client = SelcomClient()
    result = client.verify_transaction("tx-2")
    assert result.status == "SUCCESSFUL"


@responses.activate
def test_verify_transaction_maps_non_completed_status(settings):
    settings.SELCOM_BASE_URL = "https://selcom.test"
    settings.SELCOM_API_KEY = "key123"
    settings.SELCOM_API_SECRET = "secret123"
    settings.SELCOM_VENDOR_ID = "VEND1"
    responses.add(
        responses.GET,
        "https://selcom.test/v1/checkout/order-status",
        json={"data": [{"payment_status": "PENDING", "amount": 1500, "reference": "REF1"}]},
        status=200,
    )
    client = SelcomClient()
    result = client.verify_transaction("tx-2")
    assert result.status == "FAILED"


def test_verify_webhook_signature_valid(settings):
    settings.SELCOM_API_SECRET = "secret123"
    body = b'{"order_id": "tx-2", "payment_status": "COMPLETED"}'
    digest = hmac.new(b"secret123", body, hashlib.sha256).hexdigest()
    request = RequestFactory().post(
        "/webhooks/selcom", data=body, content_type="application/json", HTTP_DIGEST=digest
    )
    client = SelcomClient()
    assert client.verify_webhook_signature(request) is True


def test_verify_webhook_signature_invalid(settings):
    settings.SELCOM_API_SECRET = "secret123"
    body = b'{"order_id": "tx-2", "payment_status": "COMPLETED"}'
    request = RequestFactory().post(
        "/webhooks/selcom", data=body, content_type="application/json", HTTP_DIGEST="not-the-real-digest"
    )
    client = SelcomClient()
    assert client.verify_webhook_signature(request) is False


def test_verify_webhook_signature_missing_header(settings):
    settings.SELCOM_API_SECRET = "secret123"
    body = b'{"order_id": "tx-2", "payment_status": "COMPLETED"}'
    request = RequestFactory().post("/webhooks/selcom", data=body, content_type="application/json")
    client = SelcomClient()
    assert client.verify_webhook_signature(request) is False
