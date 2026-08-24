from decimal import Decimal

import pytest
from django.urls import reverse
from rest_framework import status

from apps.dispatch.models import ServiceStatus, ServiceType
from apps.dispatch.tests.factories import ServiceRequestFactory
from apps.notifications.models import Notification
from apps.providers.models import ProviderProfile

pytestmark = pytest.mark.django_db


def test_customer_reviews_a_completed_request(auth_client, customer_user, mechanic_user):
    sr = ServiceRequestFactory(
        customer=customer_user,
        provider=mechanic_user,
        service_type=ServiceType.MECHANIC,
        status=ServiceStatus.COMPLETED,
    )
    client = auth_client(customer_user)
    response = client.post(
        reverse("service-requests-review", args=[sr.id]),
        {"rating": 5, "comment": "Great work."},
    )
    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["rating"] == 5

    profile = ProviderProfile.objects.get(user=mechanic_user)
    assert profile.rating == Decimal("5.00")
    assert Notification.objects.filter(user=mechanic_user, title="You received a review").exists()


def test_cannot_review_before_completed(auth_client, customer_user, mechanic_user):
    sr = ServiceRequestFactory(
        customer=customer_user, provider=mechanic_user, status=ServiceStatus.ACCEPTED
    )
    client = auth_client(customer_user)
    response = client.post(reverse("service-requests-review", args=[sr.id]), {"rating": 5})
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_cannot_review_twice(auth_client, customer_user, mechanic_user):
    sr = ServiceRequestFactory(
        customer=customer_user, provider=mechanic_user, status=ServiceStatus.COMPLETED
    )
    client = auth_client(customer_user)
    first = client.post(reverse("service-requests-review", args=[sr.id]), {"rating": 4})
    second = client.post(reverse("service-requests-review", args=[sr.id]), {"rating": 2})
    assert first.status_code == status.HTTP_201_CREATED
    assert second.status_code == status.HTTP_400_BAD_REQUEST


def test_rating_averages_across_multiple_reviews(auth_client, mechanic_user):
    from apps.users.models import UserRole
    from apps.users.tests.factories import UserFactory

    customer_a = UserFactory(role=UserRole.CUSTOMER)
    customer_b = UserFactory(role=UserRole.CUSTOMER)
    sr_a = ServiceRequestFactory(
        customer=customer_a, provider=mechanic_user, status=ServiceStatus.COMPLETED
    )
    sr_b = ServiceRequestFactory(
        customer=customer_b, provider=mechanic_user, status=ServiceStatus.COMPLETED
    )

    auth_client(customer_a).post(reverse("service-requests-review", args=[sr_a.id]), {"rating": 5})
    auth_client(customer_b).post(reverse("service-requests-review", args=[sr_b.id]), {"rating": 3})

    profile = ProviderProfile.objects.get(user=mechanic_user)
    assert profile.rating == Decimal("4.00")


def test_rejects_out_of_range_rating(auth_client, customer_user, mechanic_user):
    sr = ServiceRequestFactory(
        customer=customer_user, provider=mechanic_user, status=ServiceStatus.COMPLETED
    )
    client = auth_client(customer_user)
    response = client.post(reverse("service-requests-review", args=[sr.id]), {"rating": 6})
    assert response.status_code == status.HTTP_400_BAD_REQUEST
