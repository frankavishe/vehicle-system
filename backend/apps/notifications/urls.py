from django.urls import path

from .views import DeviceTokenUpsertView, NotificationListView, NotificationMarkReadView

urlpatterns = [
    path("users/me/device-tokens", DeviceTokenUpsertView.as_view(), name="device-token-upsert"),
    path("users/me/notifications", NotificationListView.as_view(), name="notifications-list"),
    path(
        "notifications/<uuid:pk>/read",
        NotificationMarkReadView.as_view(),
        name="notification-mark-read",
    ),
]
