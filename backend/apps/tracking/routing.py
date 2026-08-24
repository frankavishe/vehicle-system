from django.urls import re_path

from .consumers import TrackingConsumer

# Mirrors config/urls.py's `api/v1/` HTTP prefix so the WS surface reads
# consistently with the rest of the API (PLAN.md §4's
# `ws://api/v1/tracking/{service_request_id}/`).
websocket_urlpatterns = [
    re_path(
        r"^ws/api/v1/tracking/(?P<service_request_id>[0-9a-fA-F-]{36})/$",
        TrackingConsumer.as_asgi(),
    ),
]
