import os

from channels.routing import ProtocolTypeRouter, URLRouter
from django.core.asgi import get_asgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.dev")

# django_asgi_app must be constructed before importing anything that
# touches models (apps.tracking.routing -> apps.tracking.consumers ->
# apps.dispatch.models/apps.providers.models) — this populates Django's
# app registry first, same ordering Channels' own docs require.
django_asgi_app = get_asgi_application()

from apps.tracking.middleware import JWTAuthMiddleware  # noqa: E402
from apps.tracking.routing import websocket_urlpatterns  # noqa: E402

# Phase 4: one ASGI process (daphne, per infra/docker-compose.yml) serves
# both the existing DRF/HTTP surface and the new WebSocket tracking
# consumer (PLAN.md §5.2/§7) — no Django session auth involved, so this
# uses apps.tracking's own JWT-over-querystring middleware rather than
# Channels' stock AuthMiddlewareStack.
application = ProtocolTypeRouter(
    {
        "http": django_asgi_app,
        "websocket": JWTAuthMiddleware(URLRouter(websocket_urlpatterns)),
    }
)
