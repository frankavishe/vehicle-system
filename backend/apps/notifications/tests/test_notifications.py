import pytest
from django.urls import reverse
from rest_framework import status

from apps.notifications.models import Notification, NotificationCategory

pytestmark = pytest.mark.django_db


@pytest.fixture
def notification(customer_user):
    return Notification.objects.create(
        user=customer_user,
        category=NotificationCategory.GENERAL,
        title="Welcome",
        body="Thanks for signing up.",
    )


def test_list_own_notifications(auth_client, customer_user, notification):
    client = auth_client(customer_user)
    url = reverse("notifications-list")
    response = client.get(url)
    assert response.status_code == status.HTTP_200_OK
    assert response.data["count"] == 1


def test_cannot_see_other_users_notifications(auth_client, mechanic_user, notification):
    client = auth_client(mechanic_user)
    url = reverse("notifications-list")
    response = client.get(url)
    assert response.status_code == status.HTTP_200_OK
    assert response.data["count"] == 0


def test_mark_notification_read(auth_client, customer_user, notification):
    client = auth_client(customer_user)
    url = reverse("notification-mark-read", args=[notification.id])
    response = client.patch(url)
    assert response.status_code == status.HTTP_200_OK
    notification.refresh_from_db()
    assert notification.read is True


def test_cannot_mark_other_users_notification_read(auth_client, mechanic_user, notification):
    client = auth_client(mechanic_user)
    url = reverse("notification-mark-read", args=[notification.id])
    response = client.patch(url)
    assert response.status_code == status.HTTP_404_NOT_FOUND
