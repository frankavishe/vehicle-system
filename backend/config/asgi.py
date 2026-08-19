import os

from django.core.asgi import get_asgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.dev")

# Plain ASGI app for Phase 1. Phase 4 swaps this for a ProtocolTypeRouter
# (Django Channels) to add the WebSocket tracking consumer alongside this
# same HTTP application — see PLAN.md §5.2/§7 Phase 4.
application = get_asgi_application()
