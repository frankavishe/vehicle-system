"""Weekly provider payout batch (PLAN.md §5.5) — reuses the same two
gateways already built for checkout (§5.3, `apps.orders.gateways`), just
the reverse direction of money movement, per §5.5's explicit "reuse the
existing gateways rather than adding a third vendor" decision."""

from decimal import ROUND_HALF_UP, Decimal

from django.conf import settings
from django.db import transaction
from django.utils import timezone

from apps.dispatch.models import ServiceRequest, ServiceStatus
from apps.notifications.models import NotificationCategory
from apps.notifications.services.create import create_and_send
from apps.orders.gateways.routing import get_gateway_client
from apps.orders.models import Payment, PaymentStatus

from ..models import Payout, PayoutItem, PayoutStatus


def _net_amount(gross: Decimal) -> Decimal:
    commission = Decimal(str(settings.PLATFORM_COMMISSION_PCT))
    net = gross * (Decimal("1") - commission)
    return net.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def _unclaimed_completed_requests():
    """COMPLETED service_requests with a SUCCESSFUL payment, not yet
    covered by any existing PayoutItem — the batch's per-run candidate
    set. A request only ever appears in one payout, ever, across runs."""
    paid_sr_ids = Payment.objects.filter(
        status=PaymentStatus.SUCCESSFUL, service_request__isnull=False
    ).values_list("service_request_id", flat=True)
    claimed_sr_ids = PayoutItem.objects.values_list("service_request_id", flat=True)
    return (
        ServiceRequest.objects.filter(id__in=paid_sr_ids, status=ServiceStatus.COMPLETED)
        .exclude(id__in=claimed_sr_ids)
        .select_related("provider")
    )


@transaction.atomic
def run_batch(*, is_manual: bool = False, provider_id=None) -> list[Payout]:
    """Builds one `Payout` per provider with unclaimed completed+paid
    requests, then disburses each immediately. `provider_id` scopes the
    batch to a single provider — the Admin manual/off-cycle trigger path
    (§5.5's Admin "Rapid Moderation" case); omitted, it's the weekly
    Celery beat run covering every provider at once."""

    candidates = _unclaimed_completed_requests()
    if provider_id:
        candidates = candidates.filter(provider_id=provider_id)

    by_provider: dict = {}
    for sr in candidates:
        if sr.provider_id is None:
            continue
        by_provider.setdefault(sr.provider_id, []).append(sr)

    payouts = []
    for requests_for_provider in by_provider.values():
        provider = requests_for_provider[0].provider
        item_amounts = [
            (sr, _net_amount(sr.final_fare or sr.estimated_fare or Decimal("0")))
            for sr in requests_for_provider
        ]
        net_total = sum((amount for _sr, amount in item_amounts), Decimal("0"))

        payout = Payout.objects.create(
            provider=provider,
            amount=net_total,
            period_start=min(sr.created_at for sr in requests_for_provider),
            period_end=timezone.now(),
            is_manual=is_manual,
            provider_gateway=settings.PROVIDER_PAYOUT_GATEWAY,
            status=PayoutStatus.PROCESSING,
        )
        PayoutItem.objects.bulk_create(
            PayoutItem(payout=payout, service_request=sr, amount=amount)
            for sr, amount in item_amounts
        )

        _disburse(payout, provider)
        payouts.append(payout)

    return payouts


def _disburse(payout: Payout, provider) -> None:
    client = get_gateway_client(payout.provider_gateway)
    try:
        result = client.disburse(payout=payout, phone=provider.phone)
    except Exception:
        payout.status = PayoutStatus.FAILED
        payout.save(update_fields=["status"])
        _notify(provider, payout, failed=True)
        return

    payout.status = result.status
    payout.gateway_transaction_id = result.gateway_transaction_id
    if result.status == PayoutStatus.PAID:
        payout.paid_at = timezone.now()
    payout.save(update_fields=["status", "gateway_transaction_id", "paid_at"])

    if result.status == PayoutStatus.PAID:
        _notify(provider, payout, failed=False)
    elif result.status == PayoutStatus.FAILED:
        _notify(provider, payout, failed=True)


def _notify(provider, payout: Payout, *, failed: bool) -> None:
    create_and_send(
        user=provider,
        category=NotificationCategory.GENERAL,
        title="Payout failed" if failed else "Payout sent",
        body=(
            f"Your payout of {payout.amount} could not be processed."
            if failed
            else f"Your payout of {payout.amount} was sent."
        ),
    )
