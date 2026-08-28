import pytest
from django.urls import reverse
from rest_framework import status

pytestmark = pytest.mark.django_db


def test_register_customer_success(api_client):
    url = reverse("auth-register")
    payload = {
        "email": "newcustomer@example.com",
        "phone": "0712345678",  # national format, normalized to E.164 TZ
        "full_name": "New Customer",
        "role": "CUSTOMER",
        "password": "StrongPass123!",
    }
    response = api_client.post(url, payload)
    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["phone"] == "255712345678"
    assert response.data["role"] == "CUSTOMER"
    assert "password" not in response.data


def test_register_rejects_admin_role(api_client):
    url = reverse("auth-register")
    payload = {
        "email": "wannabe-admin@example.com",
        "phone": "0712345679",
        "full_name": "Wannabe Admin",
        "role": "ADMIN",
        "password": "StrongPass123!",
    }
    response = api_client.post(url, payload)
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_register_rejects_phone_duplicate_after_normalization(api_client):
    """255712345678 already exists as an E.164 value; a national-format
    submission that normalizes to the same number must be rejected with a
    clean 400, not an unhandled IntegrityError (500)."""
    url = reverse("auth-register")
    first = {
        "email": "first@example.com",
        "phone": "0712345680",
        "full_name": "First User",
        "role": "CUSTOMER",
        "password": "StrongPass123!",
    }
    assert api_client.post(url, first).status_code == status.HTTP_201_CREATED

    second = {
        "email": "second@example.com",
        "phone": "255712345680",  # same number, already-normalized format
        "full_name": "Second User",
        "role": "CUSTOMER",
        "password": "StrongPass123!",
    }
    response = api_client.post(url, second)
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert "phone" in response.data


def test_register_rejects_invalid_phone(api_client):
    url = reverse("auth-register")
    payload = {
        "email": "badphone@example.com",
        "phone": "not-a-phone",
        "full_name": "Bad Phone",
        "role": "CUSTOMER",
        "password": "StrongPass123!",
    }
    response = api_client.post(url, payload)
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert "phone" in response.data
