from datetime import timedelta

import pytest
from django.contrib.gis.geos import Point
from django.urls import reverse
from django.utils import timezone
from rest_framework import status

from apps.dispatch.models import ServiceStatus
from apps.dispatch.tests.factories import ServiceRequestFactory
from apps.notifications.models import DeliveryStatus, Notification, NotificationCategory
from apps.orders.models import OrderStatus, PaymentStatus
from apps.orders.tests.factories import OrderFactory, PaymentFactory
from apps.users.models import UserRole
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


def _failed_notification():
    return Notification.objects.create(
        user=UserFactory(),
        category=NotificationCategory.GENERAL,
        title="test",
        body="test",
        delivery_status=DeliveryStatus.FAILED,
    )


def test_admin_analytics_aggregates(auth_client, admin_user):
    OrderFactory(status=OrderStatus.PAID)
    OrderFactory(status=OrderStatus.PENDING)
    ServiceRequestFactory(status=ServiceStatus.COMPLETED)
    PaymentFactory(status=PaymentStatus.SUCCESSFUL, amount="5000.00")
    mechanic = UserFactory(role=UserRole.MECHANIC)
    mechanic.provider_profile.is_available = True
    mechanic.provider_profile.save()

    client = auth_client(admin_user)
    response = client.get(reverse("admin-analytics"))

    assert response.status_code == status.HTTP_200_OK
    assert response.data["orders_by_status"]["PAID"] == 1
    assert response.data["service_requests_by_status"]["COMPLETED"] == 1
    assert response.data["active_providers"] >= 1
    assert float(response.data["revenue"]) >= 5000.0


def test_non_admin_cannot_view_analytics(auth_client, customer_user):
    client = auth_client(customer_user)
    response = client.get(reverse("admin-analytics"))
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_analytics_revenue_is_always_a_string(auth_client, admin_user):
    # Regression test — found via live emulator testing
    # (specs/003-admin-mobile-app/tasks.md T032), not by an earlier
    # automated test: with zero successful payments, `revenue` used to
    # render as a raw JSON number (`0`) instead of a decimal string like
    # every other money field in this codebase, which broke a strict-typed
    # client-side model.
    client = auth_client(admin_user)
    response = client.get(reverse("admin-analytics"))
    assert isinstance(response.data["revenue"], str)
    assert response.data["revenue"] == "0.00"


# --- 003-admin-mobile-app: failure-spike alert fields (spec.md FR-004,
# research.md §7) ---


def test_analytics_has_alert_false_below_threshold(auth_client, admin_user, settings):
    settings.FAILURE_ALERT_THRESHOLD = 5
    for _ in range(5):
        _failed_notification()

    client = auth_client(admin_user)
    response = client.get(reverse("admin-analytics"))

    assert response.data["failed_notifications_recent"] == 5
    assert response.data["failed_payments_recent"] == 0
    assert response.data["has_alert"] is False


def test_analytics_has_alert_true_above_threshold(auth_client, admin_user, settings):
    settings.FAILURE_ALERT_THRESHOLD = 5
    for _ in range(6):
        PaymentFactory(status=PaymentStatus.FAILED)

    client = auth_client(admin_user)
    response = client.get(reverse("admin-analytics"))

    assert response.data["failed_payments_recent"] == 6
    assert response.data["has_alert"] is True


def test_analytics_ignores_failures_outside_recent_window(auth_client, admin_user, settings):
    settings.FAILURE_ALERT_THRESHOLD = 0
    old = _failed_notification()
    Notification.objects.filter(pk=old.pk).update(
        created_at=timezone.now() - timedelta(hours=25)
    )

    client = auth_client(admin_user)
    response = client.get(reverse("admin-analytics"))

    assert response.data["failed_notifications_recent"] == 0
    assert response.data["has_alert"] is False


def test_admin_map_lists_providers_with_known_location(auth_client, admin_user):
    mechanic = UserFactory(role=UserRole.MECHANIC)
    mechanic.provider_profile.current_location = Point(39.2083, -6.7924, srid=4326)
    mechanic.provider_profile.save()
    UserFactory(role=UserRole.RECOVERY)  # no location set — excluded

    client = auth_client(admin_user)
    response = client.get(reverse("admin-map"))

    assert response.status_code == status.HTTP_200_OK
    assert response.data["count"] == 1
    assert response.data["results"][0]["lat"] == -6.7924
    assert response.data["results"][0]["lng"] == 39.2083
