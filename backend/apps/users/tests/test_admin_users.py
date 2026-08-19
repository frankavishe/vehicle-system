import pytest
from django.urls import reverse
from rest_framework import status

pytestmark = pytest.mark.django_db


def test_admin_can_list_users(auth_client, admin_user, customer_user):
    client = auth_client(admin_user)
    url = reverse("admin-users-list")
    response = client.get(url)
    assert response.status_code == status.HTTP_200_OK


def test_non_admin_cannot_list_users(auth_client, customer_user):
    client = auth_client(customer_user)
    url = reverse("admin-users-list")
    response = client.get(url)
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_admin_can_change_role(auth_client, admin_user, customer_user):
    client = auth_client(admin_user)
    url = reverse("admin-users-role", args=[customer_user.id])
    response = client.patch(url, {"role": "MECHANIC"})
    assert response.status_code == status.HTTP_200_OK
    customer_user.refresh_from_db()
    assert customer_user.role == "MECHANIC"


def test_non_admin_cannot_change_role(auth_client, customer_user, mechanic_user):
    client = auth_client(customer_user)
    url = reverse("admin-users-role", args=[mechanic_user.id])
    response = client.patch(url, {"role": "ADMIN"})
    assert response.status_code == status.HTTP_403_FORBIDDEN
