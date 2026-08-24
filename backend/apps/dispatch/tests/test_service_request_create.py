import pytest
from django.urls import reverse
from rest_framework import status

from apps.dispatch.models import ServiceRequest, ServiceStatus, ServiceType

pytestmark = pytest.mark.django_db


def test_customer_creates_mechanic_request(auth_client, customer_user):
    client = auth_client(customer_user)
    response = client.post(
        reverse("service-requests-list-create"),
        {
            "service_type": "MECHANIC",
            "pickup_lat": -6.7924,
            "pickup_lng": 39.2083,
            "problem_description": "Flat tyre.",
        },
    )
    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["service_type"] == ServiceType.MECHANIC
    assert response.data["status"] == ServiceStatus.PENDING
    assert response.data["pickup_location"] == {"lat": -6.7924, "lng": 39.2083}
    assert response.data["dropoff_location"] is None

    sr = ServiceRequest.objects.get(customer=customer_user)
    assert sr.provider is None


def test_recovery_requires_dropoff(auth_client, customer_user):
    client = auth_client(customer_user)
    response = client.post(
        reverse("service-requests-list-create"),
        {"service_type": "RECOVERY", "pickup_lat": -6.7924, "pickup_lng": 39.2083},
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert not ServiceRequest.objects.filter(customer=customer_user).exists()


def test_recovery_with_dropoff_succeeds(auth_client, customer_user):
    client = auth_client(customer_user)
    response = client.post(
        reverse("service-requests-list-create"),
        {
            "service_type": "RECOVERY",
            "pickup_lat": -6.7924,
            "pickup_lng": 39.2083,
            "dropoff_lat": -6.8000,
            "dropoff_lng": 39.2800,
        },
    )
    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["dropoff_location"] == {"lat": -6.8000, "lng": 39.2800}


def test_non_customer_cannot_create(auth_client, mechanic_user):
    client = auth_client(mechanic_user)
    response = client.post(
        reverse("service-requests-list-create"),
        {"service_type": "MECHANIC", "pickup_lat": -6.7924, "pickup_lng": 39.2083},
    )
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_create_requires_auth(api_client):
    response = api_client.post(
        reverse("service-requests-list-create"),
        {"service_type": "MECHANIC", "pickup_lat": -6.7924, "pickup_lng": 39.2083},
    )
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
