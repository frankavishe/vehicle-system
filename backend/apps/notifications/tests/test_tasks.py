"""send_notification task: FCM-success, FCM-failure -> Beem fallback
(category-gated per PLAN.md §5.4), dead-token deactivation. No live
Firebase/Beem accounts exist yet — fcm.send_multicast/beem.send_sms are
mocked directly (same pattern as Phase 2's gateway-client tests)."""

from unittest.mock import patch

import pytest

from apps.notifications.models import (
    DeliveryStatus,
    DeviceToken,
    Notification,
    NotificationCategory,
)
from apps.notifications.services.fcm import FCMResult
from apps.notifications.tasks import send_notification
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


def _notification(user, category=NotificationCategory.GENERAL):
    return Notification.objects.create(user=user, category=category, title="Hi", body="Body")


def _token(user, is_active=True):
    return DeviceToken.objects.create(
        user=user, fcm_token=f"tok-{user.id}", platform="ANDROID", is_active=is_active
    )


@patch("apps.notifications.tasks.fcm.send_multicast")
def test_fcm_success_marks_sent(mock_send):
    user = UserFactory()
    token = _token(user)
    mock_send.return_value = FCMResult(success_tokens=[token.fcm_token])

    notification = _notification(user)
    send_notification(str(notification.id))

    notification.refresh_from_db()
    assert notification.delivery_status == DeliveryStatus.SENT
    assert notification.sms_fallback_sent is False


@patch("apps.notifications.tasks.beem.send_sms")
@patch("apps.notifications.tasks.fcm.send_multicast")
def test_fcm_failure_falls_back_to_beem_for_job_alert(mock_send, mock_sms):
    user = UserFactory()
    _token(user)
    mock_send.return_value = FCMResult(failed_tokens=["tok"])
    mock_sms.return_value = True

    notification = _notification(user, category=NotificationCategory.JOB_ALERT)
    send_notification(str(notification.id))

    notification.refresh_from_db()
    assert notification.sms_fallback_sent is True
    assert notification.delivery_status == DeliveryStatus.SENT
    mock_sms.assert_called_once()


@patch("apps.notifications.tasks.beem.send_sms")
@patch("apps.notifications.tasks.fcm.send_multicast")
def test_fcm_failure_no_sms_fallback_for_general_category(mock_send, mock_sms):
    user = UserFactory()
    _token(user)
    mock_send.return_value = FCMResult(failed_tokens=["tok"])

    notification = _notification(user, category=NotificationCategory.GENERAL)
    send_notification(str(notification.id))

    notification.refresh_from_db()
    assert notification.sms_fallback_sent is False
    assert notification.delivery_status == DeliveryStatus.FAILED
    mock_sms.assert_not_called()


@patch("apps.notifications.tasks.fcm.send_multicast")
def test_dead_token_deactivated(mock_send):
    user = UserFactory()
    token = _token(user)
    mock_send.return_value = FCMResult(dead_tokens=[token.fcm_token], failed_tokens=[token.fcm_token])

    notification = _notification(user)
    send_notification(str(notification.id))

    token.refresh_from_db()
    assert token.is_active is False


@patch("apps.notifications.tasks.fcm.send_multicast")
def test_unknown_notification_is_a_noop(mock_send):
    send_notification("00000000-0000-0000-0000-000000000000")
    mock_send.assert_not_called()
