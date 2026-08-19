import pytest
from django.urls import reverse
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

pytestmark = pytest.mark.django_db


def test_refresh_issues_new_access_token(api_client, customer_user):
    refresh = RefreshToken.for_user(customer_user)
    url = reverse("auth-refresh")
    response = api_client.post(url, {"refresh": str(refresh)})
    assert response.status_code == status.HTTP_200_OK
    assert "access" in response.data


def test_verify_accepts_valid_token(api_client, customer_user):
    access = RefreshToken.for_user(customer_user).access_token
    url = reverse("auth-verify")
    response = api_client.post(url, {"token": str(access)})
    assert response.status_code == status.HTTP_200_OK


def test_verify_rejects_garbage_token(api_client):
    url = reverse("auth-verify")
    response = api_client.post(url, {"token": "not-a-real-token"})
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
