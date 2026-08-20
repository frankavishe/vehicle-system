from decimal import Decimal

import pytest
import responses
from django.test import RequestFactory

from apps.orders.gateways.flutterwave import FlutterwaveClient
from apps.orders.tests.factories import PaymentFactory

pytestmark = pytest.mark.django_db


@responses.activate
def test_initiate_checkout_returns_hosted_link(settings):
    settings.FLUTTERWAVE_BASE_URL = "https://flw.test"
    settings.FLUTTERWAVE_SECRET_KEY = "sk_test_123"
    responses.add(
        responses.POST,
        "https://flw.test/v3/payments",
        json={"status": "success", "data": {"link": "https://checkout.flw.test/abc"}},
        status=200,
    )
    payment = PaymentFactory(transaction_ref="tx-1", amount="5000.00")

    client = FlutterwaveClient()
    result = client.initiate_checkout(
        payment=payment, redirect_url="https://app.test/checkout/complete"
    )

    assert result.checkout_url == "https://checkout.flw.test/abc"
    sent_body = responses.calls[0].request.body
    assert b'"tx_ref": "tx-1"' in sent_body or b'"tx_ref":"tx-1"' in sent_body


@responses.activate
def test_verify_transaction_maps_successful_status(settings):
    settings.FLUTTERWAVE_BASE_URL = "https://flw.test"
    settings.FLUTTERWAVE_SECRET_KEY = "sk_test_123"
    responses.add(
        responses.GET,
        "https://flw.test/v3/transactions/verify_by_reference",
        json={
            "status": "success",
            "data": {
                "id": 998877,
                "status": "successful",
                "amount": 5000,
                "currency": "TZS",
            },
        },
        status=200,
    )
    client = FlutterwaveClient()
    result = client.verify_transaction("tx-1")
    assert result.status == "SUCCESSFUL"
    assert result.gateway_transaction_id == "998877"


@responses.activate
def test_verify_transaction_maps_failed_status(settings):
    settings.FLUTTERWAVE_BASE_URL = "https://flw.test"
    settings.FLUTTERWAVE_SECRET_KEY = "sk_test_123"
    responses.add(
        responses.GET,
        "https://flw.test/v3/transactions/verify_by_reference",
        json={
            "status": "success",
            "data": {"id": 998877, "status": "cancelled", "amount": 5000, "currency": "TZS"},
        },
        status=200,
    )
    client = FlutterwaveClient()
    result = client.verify_transaction("tx-1")
    assert result.status == "FAILED"


def test_verify_webhook_signature_valid(settings):
    settings.FLUTTERWAVE_WEBHOOK_SECRET_HASH = "shared-secret"
    request = RequestFactory().post(
        "/webhooks/flutterwave", HTTP_VERIF_HASH="shared-secret"
    )
    client = FlutterwaveClient()
    assert client.verify_webhook_signature(request) is True


def test_verify_webhook_signature_invalid(settings):
    settings.FLUTTERWAVE_WEBHOOK_SECRET_HASH = "shared-secret"
    request = RequestFactory().post(
        "/webhooks/flutterwave", HTTP_VERIF_HASH="wrong-hash"
    )
    client = FlutterwaveClient()
    assert client.verify_webhook_signature(request) is False


def test_verify_webhook_signature_missing_header(settings):
    settings.FLUTTERWAVE_WEBHOOK_SECRET_HASH = "shared-secret"
    request = RequestFactory().post("/webhooks/flutterwave")
    client = FlutterwaveClient()
    assert client.verify_webhook_signature(request) is False
