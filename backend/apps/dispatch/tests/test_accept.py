import pytest
from django.urls import reverse
from rest_framework import status

from apps.dispatch.models import ServiceStatus, ServiceType
from apps.dispatch.tests.factories import ServiceRequestFactory
from apps.notifications.models import Notification

pytestmark = pytest.mark.django_db


def test_mechanic_accepts_pending_request(auth_client, mechanic_user):
    mechanic_user.provider_profile.is_available = True
    mechanic_user.provider_profile.save()
    sr = ServiceRequestFactory(service_type=ServiceType.MECHANIC)

    client = auth_client(mechanic_user)
    response = client.post(reverse("service-requests-accept", args=[sr.id]))

    assert response.status_code == status.HTTP_200_OK
    assert response.data["status"] == ServiceStatus.ACCEPTED
    sr.refresh_from_db()
    assert sr.provider == mechanic_user
    assert sr.status == ServiceStatus.ACCEPTED
    # A GENERAL notification fires on the customer.
    assert Notification.objects.filter(user=sr.customer, category="GENERAL").exists()


def test_double_accept_race_returns_409(auth_client):
    from apps.users.models import UserRole
    from apps.users.tests.factories import UserFactory

    first = UserFactory(role=UserRole.MECHANIC)
    first.provider_profile.is_available = True
    first.provider_profile.save()
    second = UserFactory(role=UserRole.MECHANIC)
    second.provider_profile.is_available = True
    second.provider_profile.save()

    sr = ServiceRequestFactory(service_type=ServiceType.MECHANIC)

    client_first = auth_client(first)
    client_second = auth_client(second)

    response_first = client_first.post(reverse("service-requests-accept", args=[sr.id]))
    response_second = client_second.post(reverse("service-requests-accept", args=[sr.id]))

    assert response_first.status_code == status.HTTP_200_OK
    assert response_second.status_code == status.HTTP_409_CONFLICT
    sr.refresh_from_db()
    assert sr.provider == first


def test_unavailable_mechanic_cannot_accept(auth_client, mechanic_user):
    mechanic_user.provider_profile.is_available = False
    mechanic_user.provider_profile.save()
    sr = ServiceRequestFactory(service_type=ServiceType.MECHANIC)

    client = auth_client(mechanic_user)
    response = client.post(reverse("service-requests-accept", args=[sr.id]))
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_recovery_cannot_accept_mechanic_request(auth_client, recovery_user):
    recovery_user.provider_profile.is_available = True
    recovery_user.provider_profile.save()
    sr = ServiceRequestFactory(service_type=ServiceType.MECHANIC)

    client = auth_client(recovery_user)
    response = client.post(reverse("service-requests-accept", args=[sr.id]))
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_customer_cannot_accept(auth_client, customer_user):
    sr = ServiceRequestFactory(service_type=ServiceType.MECHANIC)
    client = auth_client(customer_user)
    response = client.post(reverse("service-requests-accept", args=[sr.id]))
    assert response.status_code == status.HTTP_403_FORBIDDEN
