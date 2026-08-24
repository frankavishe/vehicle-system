import pytest
from django.urls import reverse
from rest_framework import status

from apps.dispatch.models import ServiceStatus, ServiceType
from apps.dispatch.tests.factories import ServiceRequestFactory

pytestmark = pytest.mark.django_db


def _sr(**kwargs):
    return ServiceRequestFactory(service_type=ServiceType.MECHANIC, **kwargs)


def test_provider_advances_accepted_to_en_route(auth_client, mechanic_user):
    sr = _sr(status=ServiceStatus.ACCEPTED, provider=mechanic_user)
    client = auth_client(mechanic_user)
    response = client.patch(reverse("service-requests-status", args=[sr.id]), {"status": "EN_ROUTE"})
    assert response.status_code == status.HTTP_200_OK
    assert response.data["status"] == ServiceStatus.EN_ROUTE


def test_provider_advances_en_route_to_in_progress(auth_client, mechanic_user):
    sr = _sr(status=ServiceStatus.EN_ROUTE, provider=mechanic_user)
    client = auth_client(mechanic_user)
    response = client.patch(reverse("service-requests-status", args=[sr.id]), {"status": "IN_PROGRESS"})
    assert response.status_code == status.HTTP_200_OK


def test_provider_completes_in_progress(auth_client, mechanic_user):
    sr = _sr(status=ServiceStatus.IN_PROGRESS, provider=mechanic_user)
    client = auth_client(mechanic_user)
    response = client.patch(reverse("service-requests-status", args=[sr.id]), {"status": "COMPLETED"})
    assert response.status_code == status.HTTP_200_OK


def test_customer_cannot_advance_to_en_route(auth_client, customer_user):
    sr = _sr(status=ServiceStatus.ACCEPTED, customer=customer_user)
    client = auth_client(customer_user)
    response = client.patch(reverse("service-requests-status", args=[sr.id]), {"status": "EN_ROUTE"})
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_customer_can_cancel(auth_client, customer_user):
    sr = _sr(status=ServiceStatus.ACCEPTED, customer=customer_user)
    client = auth_client(customer_user)
    response = client.patch(reverse("service-requests-status", args=[sr.id]), {"status": "CANCELLED"})
    assert response.status_code == status.HTTP_200_OK


def test_pending_cannot_be_patched_to_accepted(auth_client, customer_user):
    """ACCEPTED is only reachable via the race-safe /accept endpoint."""
    sr = _sr(status=ServiceStatus.PENDING, customer=customer_user)
    client = auth_client(customer_user)
    response = client.patch(reverse("service-requests-status", args=[sr.id]), {"status": "ACCEPTED"})
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_customer_can_cancel_still_pending_request(auth_client, customer_user):
    """A customer must be able to back out before anyone accepts."""
    sr = _sr(status=ServiceStatus.PENDING, customer=customer_user)
    client = auth_client(customer_user)
    response = client.patch(reverse("service-requests-status", args=[sr.id]), {"status": "CANCELLED"})
    assert response.status_code == status.HTTP_200_OK


def test_completed_is_terminal(auth_client, mechanic_user):
    sr = _sr(status=ServiceStatus.COMPLETED, provider=mechanic_user)
    client = auth_client(mechanic_user)
    response = client.patch(reverse("service-requests-status", args=[sr.id]), {"status": "EN_ROUTE"})
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_unrelated_user_gets_404(auth_client, mechanic_user):
    sr = _sr(status=ServiceStatus.ACCEPTED)  # different provider/customer
    client = auth_client(mechanic_user)
    response = client.patch(reverse("service-requests-status", args=[sr.id]), {"status": "EN_ROUTE"})
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_status_update_requires_auth(api_client):
    sr = _sr(status=ServiceStatus.ACCEPTED)
    response = api_client.patch(reverse("service-requests-status", args=[sr.id]), {"status": "EN_ROUTE"})
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
