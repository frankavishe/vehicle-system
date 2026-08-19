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
