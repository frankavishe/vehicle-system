import pytest
from django.urls import reverse
from rest_framework import status

from apps.catalog.models import Vendor
from apps.catalog.tests.factories import VendorFactory

pytestmark = pytest.mark.django_db


def test_admin_can_create_vendor(auth_client, admin_user):
    client = auth_client(admin_user)
    response = client.post(
        reverse("admin-vendors-list"),
        {"name": "Acme Auto Parts", "contact_email": "acme@example.com", "contact_phone": "255711000111"},
    )
    assert response.status_code == status.HTTP_201_CREATED
    assert Vendor.objects.filter(name="Acme Auto Parts").exists()


def test_admin_can_list_vendors(auth_client, admin_user):
    VendorFactory()
    client = auth_client(admin_user)
    response = client.get(reverse("admin-vendors-list"))
    assert response.status_code == status.HTTP_200_OK
    assert response.data["count"] == 1


def test_admin_can_deactivate_vendor(auth_client, admin_user):
    vendor = VendorFactory(is_active=True)
    client = auth_client(admin_user)
    response = client.patch(reverse("admin-vendors-detail", args=[vendor.id]), {"is_active": False})
    assert response.status_code == status.HTTP_200_OK
    vendor.refresh_from_db()
    assert vendor.is_active is False


def test_customer_cannot_create_vendor(auth_client, customer_user):
    client = auth_client(customer_user)
    response = client.post(reverse("admin-vendors-list"), {"name": "Nope"})
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_vendors_require_auth(api_client):
    response = api_client.get(reverse("admin-vendors-list"))
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
