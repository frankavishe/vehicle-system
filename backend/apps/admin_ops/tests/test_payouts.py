import pytest
import responses
from django.urls import reverse
from rest_framework import status

from apps.admin_ops.tests.factories import PayoutFactory
from apps.dispatch.models import ServiceStatus
from apps.dispatch.tests.factories import ServiceRequestFactory
from apps.orders.models import PaymentStatus
from apps.orders.tests.factories import PaymentFactory
from apps.users.models import UserRole
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


def test_admin_lists_payouts(auth_client, admin_user):
    PayoutFactory()
    PayoutFactory()
    client = auth_client(admin_user)
    response = client.get(reverse("admin-payouts-list"))
    assert response.status_code == status.HTTP_200_OK
    assert response.data["count"] == 2


def test_non_admin_cannot_trigger_payout(auth_client, customer_user):
    mechanic = UserFactory(role=UserRole.MECHANIC)
    client = auth_client(customer_user)
    response = client.post(reverse("admin-payouts-trigger", args=[mechanic.id]))
    assert response.status_code == status.HTTP_403_FORBIDDEN


@responses.activate
def test_admin_triggers_manual_payout(auth_client, admin_user, settings):
    settings.FLUTTERWAVE_BASE_URL = "https://flw.test"
    settings.FLUTTERWAVE_SECRET_KEY = "sk_test_123"
    settings.PROVIDER_PAYOUT_GATEWAY = "FLUTTERWAVE"
    responses.add(
        responses.POST,
        "https://flw.test/v3/transfers",
        json={"status": "success", "data": {"id": 1, "status": "SUCCESSFUL"}},
        status=200,
    )
    mechanic = UserFactory(role=UserRole.MECHANIC)
    sr = ServiceRequestFactory(provider=mechanic, status=ServiceStatus.COMPLETED, final_fare="5000.00")
    PaymentFactory(order=None, service_request=sr, status=PaymentStatus.SUCCESSFUL, amount="5000.00")

    client = auth_client(admin_user)
    response = client.post(reverse("admin-payouts-trigger", args=[mechanic.id]))

    assert response.status_code == status.HTTP_201_CREATED
    assert len(response.data) == 1
    assert response.data[0]["is_manual"] is True


def test_trigger_with_no_candidates_404s(auth_client, admin_user):
    mechanic = UserFactory(role=UserRole.MECHANIC)
    client = auth_client(admin_user)
    response = client.post(reverse("admin-payouts-trigger", args=[mechanic.id]))
    assert response.status_code == status.HTTP_404_NOT_FOUND
