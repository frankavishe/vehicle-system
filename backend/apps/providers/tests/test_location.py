import pytest
from django.urls import reverse
from rest_framework import status

pytestmark = pytest.mark.django_db


def test_mechanic_can_update_location(auth_client, mechanic_user):
    client = auth_client(mechanic_user)
    url = reverse("provider-location")
    # Dar es Salaam coordinates
    response = client.patch(url, {"lat": -6.7924, "lng": 39.2083})
    assert response.status_code == status.HTTP_200_OK
    assert response.data["current_location"] == {"lat": -6.7924, "lng": 39.2083}

    mechanic_user.provider_profile.refresh_from_db()
    point = mechanic_user.provider_profile.current_location
    assert round(point.y, 4) == -6.7924
    assert round(point.x, 4) == 39.2083


def test_customer_cannot_update_location(auth_client, customer_user):
    client = auth_client(customer_user)
    url = reverse("provider-location")
    response = client.patch(url, {"lat": -6.7924, "lng": 39.2083})
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_location_requires_lat_lng(auth_client, mechanic_user):
    client = auth_client(mechanic_user)
    url = reverse("provider-location")
    response = client.patch(url, {"lat": -6.7924})
    assert response.status_code == status.HTTP_400_BAD_REQUEST
