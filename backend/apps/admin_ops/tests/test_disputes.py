import pytest
from django.urls import reverse
from rest_framework import status

from apps.admin_ops.models import Dispute, DisputeStatus
from apps.admin_ops.tests.factories import DisputeFactory
from apps.dispatch.models import ServiceStatus
from apps.dispatch.tests.factories import ServiceRequestFactory
from apps.notifications.models import Notification

pytestmark = pytest.mark.django_db


def test_customer_raises_dispute_on_own_request(auth_client, customer_user, mechanic_user):
    sr = ServiceRequestFactory(
        customer=customer_user, provider=mechanic_user, status=ServiceStatus.COMPLETED
    )
    client = auth_client(customer_user)
    response = client.post(
        reverse("service-requests-disputes-create", args=[sr.id]),
        {"reason": "Job was never finished."},
    )
    assert response.status_code == status.HTTP_201_CREATED
    assert Dispute.objects.filter(service_request=sr, raised_by=customer_user).exists()
    # The other participant (provider) is notified, not the raiser.
    assert Notification.objects.filter(user=mechanic_user, title="A dispute was raised").exists()


def test_stranger_cannot_raise_dispute(auth_client, customer_user):
    sr = ServiceRequestFactory(status=ServiceStatus.COMPLETED)  # different customer
    client = auth_client(customer_user)
    response = client.post(
        reverse("service-requests-disputes-create", args=[sr.id]), {"reason": "..."}
    )
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_admin_lists_disputes(auth_client, admin_user):
    DisputeFactory()
    DisputeFactory()
    client = auth_client(admin_user)
    response = client.get(reverse("admin-disputes-list"))
    assert response.status_code == status.HTTP_200_OK
    assert response.data["count"] == 2


def test_non_admin_cannot_list_disputes(auth_client, customer_user):
    client = auth_client(customer_user)
    response = client.get(reverse("admin-disputes-list"))
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_admin_resolves_dispute_and_notifies_raiser(auth_client, admin_user):
    dispute = DisputeFactory()
    client = auth_client(admin_user)
    response = client.patch(reverse("admin-disputes-resolve", args=[dispute.id]))
    assert response.status_code == status.HTTP_200_OK
    dispute.refresh_from_db()
    assert dispute.status == DisputeStatus.RESOLVED
    assert dispute.resolved_by == admin_user
    assert Notification.objects.filter(
        user=dispute.raised_by, category="DISPUTE", title="Your dispute was resolved"
    ).exists()


def test_cannot_resolve_already_resolved_dispute(auth_client, admin_user):
    dispute = DisputeFactory(status=DisputeStatus.RESOLVED)
    client = auth_client(admin_user)
    response = client.patch(reverse("admin-disputes-resolve", args=[dispute.id]))
    assert response.status_code == status.HTTP_400_BAD_REQUEST


# --- 003-admin-mobile-app: DisputeSerializer's additive read-only fields
# (spec.md FR-002/FR-003 — job/complainant/resolver detail without a
# second lookup, research.md §3) ---


def test_dispute_list_includes_readable_summary_fields(auth_client, admin_user):
    sr = ServiceRequestFactory()
    dispute = DisputeFactory(service_request=sr, raised_by=sr.customer)
    client = auth_client(admin_user)
    response = client.get(reverse("admin-disputes-list"))
    assert response.status_code == status.HTTP_200_OK
    row = next(r for r in response.data["results"] if r["id"] == str(dispute.id))
    assert row["service_request_summary"]["id"] == str(sr.id)
    assert row["service_request_summary"]["service_type"] == sr.service_type
    assert row["service_request_summary"]["status"] == sr.status
    assert row["service_request_summary"]["customer_name"] == sr.customer.full_name
    assert row["raised_by_name"] == sr.customer.full_name
    assert row["raised_by_email"] == sr.customer.email
    assert row["resolved_by_name"] is None


def test_dispute_summary_fields_null_safe_when_raised_by_missing(auth_client, admin_user):
    dispute = DisputeFactory(raised_by=None)
    client = auth_client(admin_user)
    response = client.get(reverse("admin-disputes-list"))
    row = next(r for r in response.data["results"] if r["id"] == str(dispute.id))
    assert row["raised_by_name"] is None
    assert row["raised_by_email"] is None


def test_resolved_dispute_shows_resolver_name(auth_client, admin_user):
    dispute = DisputeFactory()
    client = auth_client(admin_user)
    client.patch(reverse("admin-disputes-resolve", args=[dispute.id]))
    response = client.get(reverse("admin-disputes-list"))
    row = next(r for r in response.data["results"] if r["id"] == str(dispute.id))
    assert row["resolved_by_name"] == admin_user.full_name
