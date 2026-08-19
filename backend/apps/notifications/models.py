from django.conf import settings
from django.db import models

from apps.common.models import UUIDModel


class Platform(models.TextChoices):
    ANDROID = "ANDROID", "Android"
    IOS = "IOS", "iOS"
    WEB = "WEB", "Web"


class NotificationCategory(models.TextChoices):
    JOB_ALERT = "JOB_ALERT", "Job Alert"
    ORDER_UPDATE = "ORDER_UPDATE", "Order Update"
    DISPATCH = "DISPATCH", "Dispatch"
    DISPUTE = "DISPUTE", "Dispute"
    GENERAL = "GENERAL", "General"


class DeliveryStatus(models.TextChoices):
    PENDING = "PENDING", "Pending"
    SENT = "SENT", "Sent"
    FAILED = "FAILED", "Failed"


class DeviceToken(UUIDModel):
    """Matches PLAN.md §3.2's `device_tokens` table. A user can have
    several rows (multiple devices). No FCM send logic lives here yet —
    Phase 1 owns only the schema + register/upsert endpoint; Phase 3 wires
    up the actual Celery/FCM send flow that flips `is_active` on an
    UNREGISTERED/INVALID_ARGUMENT response."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="device_tokens"
    )
    fcm_token = models.CharField(unique=True, max_length=255)
    platform = models.CharField(max_length=10, choices=Platform.choices)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "device_tokens"

    def __str__(self):
        return f"DeviceToken<{self.user_id}, {self.platform}>"


class Notification(UUIDModel):
    """Matches PLAN.md §3.2's `notifications` table — the Celery/Firebase
    send target. Phase 1 owns the schema + list/mark-read endpoints only;
    the actual send flow (FCM multicast, Beem SMS fallback for
    JOB_ALERT/DISPATCH per PLAN.md §5.4) is built in Phase 3."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="notifications"
    )
    category = models.CharField(max_length=30, choices=NotificationCategory.choices)
    title = models.CharField(max_length=255)
    body = models.TextField()
    delivery_status = models.CharField(
        max_length=20, choices=DeliveryStatus.choices, default=DeliveryStatus.PENDING
    )
    sms_fallback_sent = models.BooleanField(default=False)
    read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "notifications"
        ordering = ["-created_at"]

    def __str__(self):
        return f"Notification<{self.user_id}, {self.category}>"
