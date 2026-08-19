import pytest
from django.urls import reverse
from rest_framework import status

pytestmark = pytest.mark.django_db


def test_login_returns_tokens_with_role_claim(api_client, customer_user):
    url = reverse("auth-login")
    response = api_client.post(
        url, {"email": customer_user.email, "password": "TestPass123!"}
    )
    assert response.status_code == status.HTTP_200_OK
    assert "access" in response.data
    assert "refresh" in response.data

    # decode the access token payload to confirm the role/full_name claims
    import jwt

    payload = jwt.decode(response.data["access"], options={"verify_signature": False})
    assert payload["role"] == "CUSTOMER"
    assert payload["full_name"] == customer_user.full_name


def test_login_rejects_bad_password(api_client, customer_user):
    url = reverse("auth-login")
    response = api_client.post(url, {"email": customer_user.email, "password": "wrong"})
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
