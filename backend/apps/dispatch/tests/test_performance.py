from datetime import timedelta

import pytest
from django.urls import reverse
from django.utils import timezone
from rest_framework import status

from apps.dispatch.models import Review, ServiceStatus, ServiceType
from apps.dispatch.tests.factories import ServiceRequestFactory
from apps.users.models import UserRole
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


def _completed_job(provider, customer, response_seconds=300):
    """A RECOVERY job accepted `response_seconds` after creation and
    completed 30 minutes after that — created_at is auto_now_add (can't be
    backdated via the factory), so accepted_at/completed_at are derived
    from the row's *actual* created_at once it exists, then saved."""
    sr = ServiceRequestFactory(
        service_type=ServiceType.RECOVERY,
        provider=provider,
        customer=customer,
        status=ServiceStatus.COMPLETED,
        estimated_fare="10000.00",
        final_fare="10000.00",
    )
    sr.accepted_at = sr.created_at + timedelta(seconds=response_seconds)
    sr.completed_at = sr.accepted_at + timedelta(minutes=30)
    sr.save(update_fields=["accepted_at", "completed_at"])
    return sr


def _cancelled_job(provider, customer):
    return ServiceRequestFactory(
        service_type=ServiceType.RECOVERY,
        provider=provider,
        customer=customer,
        status=ServiceStatus.CANCELLED,
    )


def test_requires_auth(api_client):
    response = api_client.get(reverse("providers-me-performance"))
    assert response.status_code == status.HTTP_401_UNAUTHORIZED


def test_non_recovery_role_forbidden(auth_client, mechanic_user):
    client = auth_client(mechanic_user)
    response = client.get(reverse("providers-me-performance"))
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_customer_role_forbidden(auth_client, customer_user):
    client = auth_client(customer_user)
    response = client.get(reverse("providers-me-performance"))
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_happy_path_counts_and_averages(auth_client, recovery_user, customer_user):
    _completed_job(recovery_user, customer_user, response_seconds=200)
    second = _completed_job(recovery_user, customer_user, response_seconds=400)
    _cancelled_job(recovery_user, customer_user)

    Review.objects.create(
        service_request=_completed_job(recovery_user, customer_user, response_seconds=300),
        customer=customer_user,
        rating=5,
    )
    Review.objects.create(service_request=second, customer=customer_user, rating=4)

    client = auth_client(recovery_user)
    response = client.get(reverse("providers-me-performance"))

    assert response.status_code == status.HTTP_200_OK
    assert response.data["completed_count"] == 3
    assert response.data["cancelled_count"] == 1
    # float(...) sidesteps whether the DB backend's Avg() comes back as a
    # float or a Decimal — either way this is the same numeric value.
    assert float(response.data["average_rating"]) == 4.5
    # (200 + 400 + 300) / 3 = 300
    assert response.data["average_response_time_seconds"] == 300


def test_all_cancelled_period_distinguishes_from_no_completions(auth_client, recovery_user, customer_user):
    """FR-008: '0 completed, N cancelled' must read unambiguously, not as
    a bare, context-free zero."""
    _cancelled_job(recovery_user, customer_user)
    _cancelled_job(recovery_user, customer_user)

    client = auth_client(recovery_user)
    response = client.get(reverse("providers-me-performance"))

    assert response.status_code == status.HTTP_200_OK
    assert response.data["completed_count"] == 0
    assert response.data["cancelled_count"] == 2
    assert response.data["average_rating"] is None
    assert response.data["average_response_time_seconds"] is None


def test_empty_period_reports_null_not_zero(auth_client, recovery_user, customer_user):
    """FR-008: a period with genuinely no data must render as an explicit
    empty state (null averages), not 0 with no context."""
    _completed_job(recovery_user, customer_user)  # created "now" — outside the queried period below

    today = timezone.localdate()
    period_start = today - timedelta(days=90)
    period_end = today - timedelta(days=60)

    client = auth_client(recovery_user)
    response = client.get(
        reverse("providers-me-performance"),
        {"period_start": period_start.isoformat(), "period_end": period_end.isoformat()},
    )

    assert response.status_code == status.HTTP_200_OK
    assert response.data["completed_count"] == 0
    assert response.data["cancelled_count"] == 0
    assert response.data["average_rating"] is None
    assert response.data["average_response_time_seconds"] is None


def test_another_operators_jobs_never_counted(auth_client, recovery_user, customer_user):
    """FR-009: strictly self-scoped."""
    other_recovery = UserFactory(role=UserRole.RECOVERY)
    _completed_job(other_recovery, customer_user)
    _completed_job(other_recovery, customer_user)

    client = auth_client(recovery_user)
    response = client.get(reverse("providers-me-performance"))

    assert response.status_code == status.HTTP_200_OK
    assert response.data["completed_count"] == 0
    assert response.data["average_rating"] is None


def test_period_start_after_period_end_is_rejected(auth_client, recovery_user):
    client = auth_client(recovery_user)
    response = client.get(
        reverse("providers-me-performance"),
        {"period_start": "2026-08-30", "period_end": "2026-08-01"},
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
