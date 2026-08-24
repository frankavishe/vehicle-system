import pytest
import responses
from django.urls import reverse
from rest_framework import status

from apps.dispatch.tests.factories import ServiceRequestFactory
from apps.notifications.models import Notification
from apps.orders.models import OrderStatus, PaymentStatus
from apps.orders.tests.factories import OrderFactory, PaymentFactory

pytestmark = pytest.mark.django_db


def _configure(settings):
    settings.FLUTTERWAVE_BASE_URL = "https://flw.test"
    settings.FLUTTERWAVE_SECRET_KEY = "sk_test_123"
    settings.FLUTTERWAVE_WEBHOOK_SECRET_HASH = "shared-secret"


def _mock_verify(status_str, amount):
    responses.add(
        responses.GET,
        "https://flw.test/v3/transactions/verify_by_reference",
        json={
            "status": "success",
            "data": {"id": 1, "status": status_str, "amount": amount, "currency": "TZS"},
        },
        status=200,
    )


@responses.activate
def test_webhook_rejects_invalid_signature(api_client, settings):
    _configure(settings)
    payment = PaymentFactory(transaction_ref="tx-1", amount="5000.00")
    response = api_client.post(
        reverse("webhook-flutterwave"),
        {"data": {"tx_ref": "tx-1"}},
        format="json",
        HTTP_VERIF_HASH="wrong",
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    payment.refresh_from_db()
    assert payment.status == PaymentStatus.PENDING


@responses.activate
def test_webhook_unknown_transaction_ref_404s(api_client, settings):
    _configure(settings)
    response = api_client.post(
        reverse("webhook-flutterwave"),
        {"data": {"tx_ref": "does-not-exist"}},
        format="json",
        HTTP_VERIF_HASH="shared-secret",
    )
    assert response.status_code == status.HTTP_404_NOT_FOUND


@responses.activate
def test_webhook_marks_payment_successful_and_order_paid(api_client, settings):
    _configure(settings)
    order = OrderFactory(status=OrderStatus.PENDING)
    payment = PaymentFactory(order=order, transaction_ref="tx-1", amount="5000.00")
    _mock_verify("successful", 5000)

    response = api_client.post(
        reverse("webhook-flutterwave"),
        {"data": {"tx_ref": "tx-1"}},
        format="json",
        HTTP_VERIF_HASH="shared-secret",
    )

    assert response.status_code == status.HTTP_200_OK
    payment.refresh_from_db()
    order.refresh_from_db()
    assert payment.status == PaymentStatus.SUCCESSFUL
    assert order.status == OrderStatus.PAID


@responses.activate
def test_webhook_marks_service_request_payment_successful_and_notifies(api_client, settings):
    """Phase 4: no service_status models "paid" — the cascade is just
    notifying both parties (apps/orders/webhook_views.py)."""
    _configure(settings)
    sr = ServiceRequestFactory(status="COMPLETED", estimated_fare="5000.00")
    payment = PaymentFactory(order=None, service_request=sr, transaction_ref="tx-1", amount="5000.00")
    _mock_verify("successful", 5000)

    response = api_client.post(
        reverse("webhook-flutterwave"),
        {"data": {"tx_ref": "tx-1"}},
        format="json",
        HTTP_VERIF_HASH="shared-secret",
    )

    assert response.status_code == status.HTTP_200_OK
    payment.refresh_from_db()
    assert payment.status == PaymentStatus.SUCCESSFUL
    assert Notification.objects.filter(user=sr.customer, title="Payment received").exists()


@responses.activate
def test_webhook_amount_mismatch_marks_failed_not_paid(api_client, settings):
    _configure(settings)
    order = OrderFactory(status=OrderStatus.PENDING)
    payment = PaymentFactory(order=order, transaction_ref="tx-1", amount="5000.00")
    _mock_verify("successful", 1)  # gateway confirms a different (lower) amount — fraud case

    response = api_client.post(
        reverse("webhook-flutterwave"),
        {"data": {"tx_ref": "tx-1"}},
        format="json",
        HTTP_VERIF_HASH="shared-secret",
    )

    assert response.status_code == status.HTTP_200_OK
    payment.refresh_from_db()
    order.refresh_from_db()
    assert payment.status == PaymentStatus.FAILED
    assert order.status == OrderStatus.PENDING


@responses.activate
def test_webhook_is_idempotent_on_replay(api_client, settings):
    _configure(settings)
    order = OrderFactory(status=OrderStatus.PENDING)
    payment = PaymentFactory(order=order, transaction_ref="tx-1", amount="5000.00")
    _mock_verify("successful", 5000)
    _mock_verify("successful", 5000)  # second delivery

    first = api_client.post(
        reverse("webhook-flutterwave"),
        {"data": {"tx_ref": "tx-1"}},
        format="json",
        HTTP_VERIF_HASH="shared-secret",
    )
    second = api_client.post(
        reverse("webhook-flutterwave"),
        {"data": {"tx_ref": "tx-1"}},
        format="json",
        HTTP_VERIF_HASH="shared-secret",
    )

    assert first.status_code == status.HTTP_200_OK
    assert second.status_code == status.HTTP_200_OK
    payment.refresh_from_db()
    order.refresh_from_db()
    assert payment.status == PaymentStatus.SUCCESSFUL
    assert order.status == OrderStatus.PAID
