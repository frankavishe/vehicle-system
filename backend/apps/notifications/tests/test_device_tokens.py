import pytest
from django.urls import reverse
from rest_framework import status

from apps.notifications.models import DeviceToken

pytestmark = pytest.mark.django_db


def test_register_device_token(auth_client, customer_user):
    client = auth_client(customer_user)
    url = reverse("device-token-upsert")
    response = client.post(url, {"fcm_token": "tok-abc123", "platform": "ANDROID"})
    assert response.status_code == status.HTTP_201_CREATED
    assert DeviceToken.objects.filter(user=customer_user, fcm_token="tok-abc123").exists()


def test_re_registering_same_token_upserts(auth_client, customer_user, mechanic_user):
    client_a = auth_client(customer_user)
    url = reverse("device-token-upsert")
    client_a.post(url, {"fcm_token": "shared-tok", "platform": "ANDROID"})

    # token re-registers under a different user (e.g. device changed hands)
    client_b = auth_client(mechanic_user)
    client_b.post(url, {"fcm_token": "shared-tok", "platform": "IOS"})

    assert DeviceToken.objects.filter(fcm_token="shared-tok").count() == 1
    token = DeviceToken.objects.get(fcm_token="shared-tok")
    assert token.user == mechanic_user
    assert token.platform == "IOS"


def test_device_token_requires_auth(api_client):
    url = reverse("device-token-upsert")
    response = api_client.post(url, {"fcm_token": "tok-xyz", "platform": "WEB"})
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
