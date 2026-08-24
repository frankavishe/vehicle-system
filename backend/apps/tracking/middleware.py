"""Channels' equivalent of DRF's `JWTAuthentication` (config/settings/base.py's
`REST_FRAMEWORK["DEFAULT_AUTHENTICATION_CLASSES"]`) — resolves `scope["user"]`
from a bearer access token, but over a WebSocket handshake rather than an
HTTP `Authorization` header.

Browsers' native WebSocket API can't set arbitrary request headers, so the
token travels as a `?token=<access token>` query-string param instead —
the standard workaround every Channels+JWT integration uses. Same
`AccessToken`/`USER_ID_CLAIM` SimpleJWT already validates HTTP requests
with (see SIMPLE_JWT in config/settings/base.py), just invoked by hand
here instead of through DRF's authentication chain.
"""

from urllib.parse import parse_qs

from channels.db import database_sync_to_async
from channels.middleware import BaseMiddleware
from django.contrib.auth import get_user_model
from django.contrib.auth.models import AnonymousUser
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.settings import api_settings as simplejwt_settings
from rest_framework_simplejwt.tokens import AccessToken


@database_sync_to_async
def _resolve_user(token: str):
    try:
        access = AccessToken(token)
    except TokenError:
        return AnonymousUser()

    User = get_user_model()
    user_id = access.get(simplejwt_settings.USER_ID_CLAIM)
    try:
        return User.objects.get(**{simplejwt_settings.USER_ID_FIELD: user_id})
    except User.DoesNotExist:
        return AnonymousUser()


class JWTAuthMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        query_string = scope.get("query_string", b"").decode()
        token = parse_qs(query_string).get("token", [None])[0]
        scope["user"] = await _resolve_user(token) if token else AnonymousUser()
        return await super().__call__(scope, receive, send)
