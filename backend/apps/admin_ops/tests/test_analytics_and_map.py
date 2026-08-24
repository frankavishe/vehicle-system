import pytest
from django.contrib.gis.geos import Point
from django.urls import reverse
from rest_framework import status

from apps.dispatch.models import ServiceStatus
from apps.dispatch.tests.factories import ServiceRequestFactory
from apps.orders.models import OrderStatus, PaymentStatus
from apps.orders.tests.factories import OrderFactory, PaymentFactory
from apps.users.models import UserRole
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


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
