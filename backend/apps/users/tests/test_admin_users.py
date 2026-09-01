import uuid

import pytest
from django.urls import reverse
from rest_framework import status

from apps.users.models import UserRole
from apps.users.tests.factories import UserFactory

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


# --- 003-admin-mobile-app: search (FR-005) ---


def test_admin_can_search_users_by_full_name(auth_client, admin_user):
    match = UserFactory(full_name="Juma Mwakalinga")
    UserFactory(full_name="Someone Else")
    client = auth_client(admin_user)
    response = client.get(reverse("admin-users-list"), {"search": "juma"})
    ids = [row["id"] for row in response.data["results"]]
    assert str(match.id) in ids
    assert len(ids) == 1


def test_admin_can_search_users_by_email(auth_client, admin_user):
    match = UserFactory(email="findme@example.com")
    client = auth_client(admin_user)
    response = client.get(reverse("admin-users-list"), {"search": "findme"})
    ids = [row["id"] for row in response.data["results"]]
    assert str(match.id) in ids


def test_search_combines_with_existing_role_filter(auth_client, admin_user):
    match = UserFactory(full_name="Juma Mechanic", role=UserRole.MECHANIC)
    UserFactory(full_name="Juma Customer", role=UserRole.CUSTOMER)
    client = auth_client(admin_user)
    response = client.get(reverse("admin-users-list"), {"search": "juma", "role": "MECHANIC"})
    ids = [row["id"] for row in response.data["results"]]
    assert ids == [str(match.id)]


def test_non_admin_cannot_search_users(auth_client, customer_user):
    client = auth_client(customer_user)
    response = client.get(reverse("admin-users-list"), {"search": "x"})
    assert response.status_code == status.HTTP_403_FORBIDDEN


# --- 003-admin-mobile-app: suspend/reinstate (FR-005, FR-007) ---


def test_admin_can_suspend_account(auth_client, admin_user, customer_user):
    client = auth_client(admin_user)
    url = reverse("admin-users-status", args=[customer_user.id])
    response = client.patch(url, {"is_active": False})
    assert response.status_code == status.HTTP_200_OK
    customer_user.refresh_from_db()
    assert customer_user.is_active is False
    # contracts/admin-mobile-api.md: response is the full updated user
    # (same shape as the GET /admin/users list item), not just
    # `is_active` — the mobile client's AdminUserSummaryDto.fromJson
    # requires id/email/full_name/role/is_verified/created_at too.
    assert response.data["id"] == str(customer_user.id)
    assert response.data["email"] == customer_user.email
    assert response.data["full_name"] == customer_user.full_name
    assert response.data["role"] == customer_user.role
    assert response.data["is_active"] is False


def test_admin_can_reinstate_account(auth_client, admin_user, customer_user):
    customer_user.is_active = False
    customer_user.save(update_fields=["is_active"])
    client = auth_client(admin_user)
    url = reverse("admin-users-status", args=[customer_user.id])
    response = client.patch(url, {"is_active": True})
    assert response.status_code == status.HTTP_200_OK
    customer_user.refresh_from_db()
    assert customer_user.is_active is True


def test_suspend_is_idempotent_not_an_error(auth_client, admin_user, customer_user):
    customer_user.is_active = False
    customer_user.save(update_fields=["is_active"])
    client = auth_client(admin_user)
    url = reverse("admin-users-status", args=[customer_user.id])
    response = client.patch(url, {"is_active": False})
    assert response.status_code == status.HTTP_200_OK


def test_cannot_suspend_unknown_user(auth_client, admin_user):
    client = auth_client(admin_user)
    url = reverse("admin-users-status", args=[uuid.uuid4()])
    response = client.patch(url, {"is_active": False})
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_cannot_suspend_admin_account(auth_client, admin_user):
    other_admin = UserFactory(role=UserRole.ADMIN, is_staff=True)
    client = auth_client(admin_user)
    url = reverse("admin-users-status", args=[other_admin.id])
    response = client.patch(url, {"is_active": False})
    assert response.status_code == status.HTTP_403_FORBIDDEN
    other_admin.refresh_from_db()
    assert other_admin.is_active is True


def test_admin_cannot_self_suspend(auth_client, admin_user):
    client = auth_client(admin_user)
    url = reverse("admin-users-status", args=[admin_user.id])
    response = client.patch(url, {"is_active": False})
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_non_admin_cannot_change_status(auth_client, customer_user, mechanic_user):
    client = auth_client(customer_user)
    url = reverse("admin-users-status", args=[mechanic_user.id])
    response = client.patch(url, {"is_active": False})
    assert response.status_code == status.HTTP_403_FORBIDDEN
