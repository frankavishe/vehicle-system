from django.conf import settings
from django.db import models

from apps.common.models import UUIDModel
from apps.orders.models import ProviderGateway


class DisputeStatus(models.TextChoices):
    OPEN = "OPEN", "Open"
    RESOLVED = "RESOLVED", "Resolved"


class Dispute(UUIDModel):
    """Matches PLAN.md §3.2's `disputes` table. Lives here, not
    `apps.dispatch`, per §2's repo layout — `apps.admin_ops` owns
    disputes/moderation/payouts end-to-end, the same way
    `parts_sourcing_requests` FKs into `apps.orders.Order` across an app
    boundary already."""

    service_request = models.ForeignKey(
        "dispatch.ServiceRequest", on_delete=models.CASCADE, related_name="disputes"
    )
    raised_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name="+"
    )
    reason = models.TextField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=DisputeStatus.choices, default=DisputeStatus.OPEN)
    resolved_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name="+"
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "disputes"
        ordering = ["-created_at"]

    def __str__(self):
        return f"Dispute<{self.id}, {self.status}>"


class PayoutStatus(models.TextChoices):
    PENDING = "PENDING", "Pending"
    PROCESSING = "PROCESSING", "Processing"
    PAID = "PAID", "Paid"
    FAILED = "FAILED", "Failed"


class Payout(UUIDModel):
    """Matches PLAN.md §3.2's `payouts` table (PLAN.md §5.5). `amount` is
    already net of `settings.PLATFORM_COMMISSION_PCT` — see
    services/payout_batch.py, the only place that math happens."""

    provider = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="payouts"
    )
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    period_start = models.DateTimeField(null=True, blank=True)
    period_end = models.DateTimeField(null=True, blank=True)
    # TRUE = admin-triggered off-cycle payout (§5.5's Admin "Rapid
    # Moderation" path), FALSE = the weekly Celery beat batch.
    is_manual = models.BooleanField(default=False)
    provider_gateway = models.CharField(max_length=20, choices=ProviderGateway.choices)
    gateway_transaction_id = models.CharField(max_length=255, null=True, blank=True)
    status = models.CharField(max_length=20, choices=PayoutStatus.choices, default=PayoutStatus.PENDING)
    created_at = models.DateTimeField(auto_now_add=True)
    paid_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "payouts"
        ordering = ["-created_at"]

    def __str__(self):
        return f"Payout<{self.provider_id}, {self.amount}, {self.status}>"


class PayoutItem(UUIDModel):
    """Matches PLAN.md §3.2's `payout_items` table — itemizes exactly
    which service_requests a Payout covers, so a provider's earnings are
    auditable back to individual completed jobs."""

    payout = models.ForeignKey(Payout, on_delete=models.CASCADE, related_name="items")
    service_request = models.ForeignKey(
        "dispatch.ServiceRequest", on_delete=models.SET_NULL, null=True, blank=True, related_name="+"
    )
    amount = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        db_table = "payout_items"

    def __str__(self):
        return f"PayoutItem<{self.payout_id}, {self.service_request_id}, {self.amount}>"
