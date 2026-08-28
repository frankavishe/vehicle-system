import pytest
from django.urls import reverse
from rest_framework import status

from apps.admin_ops.tests.factories import PayoutFactory
from apps.users.models import UserRole
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


def test_mechanic_sees_only_their_own_payouts(auth_client, mechanic_user):
    PayoutFactory(provider=mechanic_user, amount="10000.00")
    other_mechanic = UserFactory(role=UserRole.MECHANIC)
    PayoutFactory(provider=other_mechanic, amount="99999.00")

    client = auth_client(mechanic_user)
    response = client.get(reverse("provider-payouts"))

    assert response.status_code == status.HTTP_200_OK
    assert response.data["count"] == 1
    assert response.data["results"][0]["amount"] == "10000.00"
    assert response.data["results"][0]["provider"] == mechanic_user.id


def test_mechanic_with_no_payouts_gets_empty_list(auth_client, mechanic_user):
    client = auth_client(mechanic_user)
    response = client.get(reverse("provider-payouts"))
    assert response.status_code == status.HTTP_200_OK
    assert response.data["count"] == 0
    assert response.data["results"] == []


def test_payouts_requires_auth(api_client):
    response = api_client.get(reverse("provider-payouts"))
    assert response.status_code == status.HTTP_401_UNAUTHORIZED


def test_customer_cannot_list_payouts(auth_client, customer_user):
    client = auth_client(customer_user)
    response = client.get(reverse("provider-payouts"))
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_recovery_cannot_list_payouts(auth_client, recovery_user):
    """Deliberately IsMechanic, not IsProvider — nothing in this feature
    asks for the RECOVERY case (see contracts/rest.md)."""
    client = auth_client(recovery_user)
    response = client.get(reverse("provider-payouts"))
    assert response.status_code == status.HTTP_403_FORBIDDEN
