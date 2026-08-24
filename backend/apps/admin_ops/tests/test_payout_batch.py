from decimal import Decimal

import pytest
import responses

from apps.admin_ops.models import Payout, PayoutItem, PayoutStatus
from apps.admin_ops.services.payout_batch import run_batch
from apps.dispatch.models import ServiceStatus
from apps.dispatch.tests.factories import ServiceRequestFactory
from apps.orders.models import PaymentStatus
from apps.orders.tests.factories import PaymentFactory
from apps.users.models import UserRole
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


def _configure(settings):
    settings.FLUTTERWAVE_BASE_URL = "https://flw.test"
    settings.FLUTTERWAVE_SECRET_KEY = "sk_test_123"
    settings.PLATFORM_COMMISSION_PCT = 0.15
    settings.PROVIDER_PAYOUT_GATEWAY = "FLUTTERWAVE"


def _mock_transfer(status_str="SUCCESSFUL"):
    responses.add(
        responses.POST,
        "https://flw.test/v3/transfers",
        json={"status": "success", "data": {"id": 1234, "status": status_str}},
        status=200,
    )


@responses.activate
def test_batch_deducts_commission_and_pays_provider(settings):
    _configure(settings)
    mechanic = UserFactory(role=UserRole.MECHANIC)
    sr = ServiceRequestFactory(
        provider=mechanic, status=ServiceStatus.COMPLETED, final_fare="10000.00"
    )
    PaymentFactory(
        order=None, service_request=sr, status=PaymentStatus.SUCCESSFUL, amount="10000.00"
    )
    _mock_transfer()

    payouts = run_batch()

    assert len(payouts) == 1
    payout = payouts[0]
    assert payout.provider == mechanic
    # 10000 * (1 - 0.15) = 8500.00
    assert payout.amount == Decimal("8500.00")
    assert payout.status == PayoutStatus.PAID
    assert PayoutItem.objects.filter(payout=payout, service_request=sr).exists()


@responses.activate
def test_already_claimed_request_is_not_paid_twice(settings):
    _configure(settings)
    mechanic = UserFactory(role=UserRole.MECHANIC)
    sr = ServiceRequestFactory(
        provider=mechanic, status=ServiceStatus.COMPLETED, final_fare="10000.00"
    )
    PaymentFactory(
        order=None, service_request=sr, status=PaymentStatus.SUCCESSFUL, amount="10000.00"
    )
    _mock_transfer()

    first_run = run_batch()
    second_run = run_batch()

    assert len(first_run) == 1
    assert second_run == []
    assert Payout.objects.count() == 1


def test_no_candidates_returns_empty_list(settings):
    _configure(settings)
    assert run_batch() == []


@responses.activate
def test_manual_trigger_scopes_to_one_provider(settings):
    _configure(settings)
    mechanic_a = UserFactory(role=UserRole.MECHANIC)
    mechanic_b = UserFactory(role=UserRole.MECHANIC)
    sr_a = ServiceRequestFactory(
        provider=mechanic_a, status=ServiceStatus.COMPLETED, final_fare="10000.00"
    )
    sr_b = ServiceRequestFactory(
        provider=mechanic_b, status=ServiceStatus.COMPLETED, final_fare="10000.00"
    )
    PaymentFactory(order=None, service_request=sr_a, status=PaymentStatus.SUCCESSFUL, amount="10000.00")
    PaymentFactory(order=None, service_request=sr_b, status=PaymentStatus.SUCCESSFUL, amount="10000.00")
    _mock_transfer()

    payouts = run_batch(is_manual=True, provider_id=mechanic_a.id)

    assert len(payouts) == 1
    assert payouts[0].provider == mechanic_a
    assert payouts[0].is_manual is True


@responses.activate
def test_gateway_failure_marks_payout_failed(settings):
    _configure(settings)
    mechanic = UserFactory(role=UserRole.MECHANIC)
    sr = ServiceRequestFactory(
        provider=mechanic, status=ServiceStatus.COMPLETED, final_fare="10000.00"
    )
    PaymentFactory(order=None, service_request=sr, status=PaymentStatus.SUCCESSFUL, amount="10000.00")
    responses.add(responses.POST, "https://flw.test/v3/transfers", status=500)

    payouts = run_batch()

    assert payouts[0].status == PayoutStatus.FAILED
