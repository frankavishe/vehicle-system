import pytest
from django.urls import reverse
from rest_framework import status

pytestmark = pytest.mark.django_db


def test_get_me_requires_auth(api_client):
    url = reverse("users-me")
    response = api_client.get(url)
    assert response.status_code == status.HTTP_401_UNAUTHORIZED


def test_get_me_returns_own_profile(auth_client, customer_user):
    client = auth_client(customer_user)
    url = reverse("users-me")
    response = client.get(url)
    assert response.status_code == status.HTTP_200_OK
    assert response.data["email"] == customer_user.email


def test_patch_me_updates_full_name(auth_client, customer_user):
    client = auth_client(customer_user)
    url = reverse("users-me")
    response = client.patch(url, {"full_name": "Updated Name"})
    assert response.status_code == status.HTTP_200_OK
    assert response.data["full_name"] == "Updated Name"


def test_patch_me_cannot_change_role(auth_client, customer_user):
    client = auth_client(customer_user)
    url = reverse("users-me")
    response = client.patch(url, {"role": "ADMIN"})
    assert response.status_code == status.HTTP_200_OK
    customer_user.refresh_from_db()
    assert customer_user.role == "CUSTOMER"  # role is read-only on this endpoint
