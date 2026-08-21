"""Celery task: FCM multicast send, dead-token deactivation, Beem SMS
fallback for dispatch-critical categories only (PLAN.md §5.4's cost
scoping — JOB_ALERT/DISPATCH get SMS on FCM failure; every other category
is push-only)."""

from celery import shared_task

from .models import DeliveryStatus, DeviceToken, Notification, NotificationCategory
from .services import beem, fcm

_SMS_FALLBACK_CATEGORIES = {NotificationCategory.JOB_ALERT, NotificationCategory.DISPATCH}


@shared_task
def send_notification(notification_id: str):
    try:
        notification = Notification.objects.select_related("user").get(pk=notification_id)
    except Notification.DoesNotExist:
        return

    tokens_qs = DeviceToken.objects.filter(user=notification.user, is_active=True)
    tokens = list(tokens_qs.values_list("fcm_token", flat=True))

    result = fcm.send_multicast(
        tokens,
        notification.title,
        notification.body,
        data={"notification_id": str(notification.id), "category": notification.category},
    )

    if result.dead_tokens:
        # Closes Phase 1's DeviceToken TODO: flip UNREGISTERED/
        # INVALID_ARGUMENT tokens inactive rather than deleting them
        # (keeps delivery history coherent).
        DeviceToken.objects.filter(fcm_token__in=result.dead_tokens).update(is_active=False)

    fcm_delivered = bool(result.success_tokens)
    notification.delivery_status = DeliveryStatus.SENT if fcm_delivered else DeliveryStatus.FAILED

    if not fcm_delivered and notification.category in _SMS_FALLBACK_CATEGORIES:
        sms_sent = beem.send_sms(notification.user.phone, f"{notification.title}: {notification.body}")
        if sms_sent:
            notification.sms_fallback_sent = True
            # SMS fallback delivered the message even though FCM didn't —
            # the notification's overall delivery goal was still met.
            notification.delivery_status = DeliveryStatus.SENT

    notification.save(update_fields=["delivery_status", "sms_fallback_sent"])
