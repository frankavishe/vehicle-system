import pytest
from django.urls import reverse
from rest_framework import status

pytestmark = pytest.mark.django_db


def test_mechanic_can_toggle_availability(auth_client, mechanic_user):
    client = auth_client(mechanic_user)
    url = reverse("provider-availability")
    response = client.patch(url, {"is_available": True})
    assert response.status_code == status.HTTP_200_OK
    assert response.data["is_available"] is True
    mechanic_user.provider_profile.refresh_from_db()
    assert mechanic_user.provider_profile.is_available is True


def test_recovery_can_toggle_availability(auth_client, recovery_user):
    client = auth_client(recovery_user)
    url = reverse("provider-availability")
    response = client.patch(url, {"is_available": True})
    assert response.status_code == status.HTTP_200_OK


def test_customer_cannot_toggle_availability(auth_client, customer_user):
    client = auth_client(customer_user)
    url = reverse("provider-availability")
    response = client.patch(url, {"is_available": True})
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_admin_cannot_toggle_availability(auth_client, admin_user):
    client = auth_client(admin_user)
    url = reverse("provider-availability")
    response = client.patch(url, {"is_available": True})
    assert response.status_code == status.HTTP_403_FORBIDDEN
