import pytest
from django.urls import reverse
from django.utils import timezone
from rest_framework import status

from apps.admin_ops.models import Payout
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


def test_period_end_includes_payouts_created_later_that_same_day(auth_client, mechanic_user):
    """Regression (found via manual QA of specs/001-mechanic-web-portal):
    a bare period_end=YYYY-MM-DD used to compare against created_at with a
    plain __lte, i.e. "before midnight at the *start* of period_end" —
    silently dropping a payout created later that same day from its own
    default "last 30 days, ending today" range."""
    payout = PayoutFactory(provider=mechanic_user, amount="10000.00")
    # __date__lte compares in settings.TIME_ZONE (Africa/Dar_es_Salaam),
    # not UTC — go via localtime() so "23:00 today" is unambiguous there.
    late_today = timezone.localtime(timezone.now()).replace(hour=23, minute=0, second=0, microsecond=0)
    Payout.objects.filter(pk=payout.pk).update(created_at=late_today)

    client = auth_client(mechanic_user)
    today = late_today.date().isoformat()
    response = client.get(reverse("provider-payouts"), {"period_start": today, "period_end": today})

    assert response.status_code == status.HTTP_200_OK
    assert response.data["count"] == 1


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
