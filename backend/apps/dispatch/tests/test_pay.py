import pytest
import responses
from django.urls import reverse
from rest_framework import status

from apps.dispatch.models import ServiceStatus
from apps.dispatch.tests.factories import ServiceRequestFactory

pytestmark = pytest.mark.django_db


def _configure_flutterwave(settings):
    settings.FLUTTERWAVE_BASE_URL = "https://flw.test"
    settings.FLUTTERWAVE_SECRET_KEY = "sk_test_123"


@responses.activate
def test_customer_pays_completed_request(auth_client, customer_user, settings):
    _configure_flutterwave(settings)
    responses.add(
        responses.POST,
        "https://flw.test/v3/payments",
        json={"status": "success", "data": {"link": "https://checkout.flw.test/abc"}},
        status=200,
    )
    sr = ServiceRequestFactory(
        customer=customer_user, status=ServiceStatus.COMPLETED, final_fare="5000.00"
    )

    client = auth_client(customer_user)
    response = client.post(
        reverse("service-requests-pay", args=[sr.id]), {"payment_method": "CARD"}
    )

    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["checkout_url"] == "https://checkout.flw.test/abc"


def test_pay_requires_completed_status(auth_client, customer_user):
    sr = ServiceRequestFactory(customer=customer_user, status=ServiceStatus.ACCEPTED)
    client = auth_client(customer_user)
    response = client.post(
        reverse("service-requests-pay", args=[sr.id]), {"payment_method": "CARD"}
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_pay_requires_ownership(auth_client, customer_user):
    other = ServiceRequestFactory(status=ServiceStatus.COMPLETED, final_fare="5000.00")
    client = auth_client(customer_user)
    response = client.post(
        reverse("service-requests-pay", args=[other.id]), {"payment_method": "CARD"}
    )
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_pay_requires_payment_method(auth_client, customer_user):
    sr = ServiceRequestFactory(
        customer=customer_user, status=ServiceStatus.COMPLETED, final_fare="5000.00"
    )
    client = auth_client(customer_user)
    response = client.post(reverse("service-requests-pay", args=[sr.id]), {})
    assert response.status_code == status.HTTP_400_BAD_REQUEST
