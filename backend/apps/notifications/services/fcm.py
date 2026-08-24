"""Guarded Firebase Admin SDK wrapper — every function here is a no-op
unless `settings.FIREBASE_PROJECT_ID` is set *and* the service-account
JSON actually exists on disk, same no-op-safe pattern already used for
Phase 2's web push (nothing crashes app boot / task execution just
because no Firebase project exists yet)."""

import os
from dataclasses import dataclass, field

from django.conf import settings


@dataclass
class FCMResult:
    success_tokens: list[str] = field(default_factory=list)
    failed_tokens: list[str] = field(default_factory=list)
    # Tokens FCM reports as permanently dead (UNREGISTERED/INVALID_ARGUMENT)
    # — caller flips DeviceToken.is_active = False for these.
    dead_tokens: list[str] = field(default_factory=list)
    attempted: bool = True


_app = None


def _get_app():
    """Lazily initializes the Firebase Admin app exactly once. Returns
    None (and stays a no-op) if credentials aren't configured."""

    global _app
    if _app is not None:
        return _app

    if not settings.FIREBASE_PROJECT_ID:
        return None
    if not os.path.exists(settings.FIREBASE_SERVICE_ACCOUNT_JSON_PATH):
        return None

    import firebase_admin
    from firebase_admin import credentials

    cred = credentials.Certificate(settings.FIREBASE_SERVICE_ACCOUNT_JSON_PATH)
    _app = firebase_admin.initialize_app(cred, {"projectId": settings.FIREBASE_PROJECT_ID})
    return _app


def is_configured() -> bool:
    return _get_app() is not None


def send_multicast(tokens: list[str], title: str, body: str, data: dict | None = None) -> FCMResult:
    """Sends one push to each of `tokens`. No-op (attempted=False) if
    Firebase isn't configured — callers treat that the same as "FCM
    failed" for the purposes of the Beem SMS fallback decision."""

    if not tokens:
        return FCMResult(attempted=False)

    app = _get_app()
    if app is None:
        return FCMResult(attempted=False)

    from firebase_admin import exceptions as firebase_exceptions
    from firebase_admin import messaging

    result = FCMResult()
    for token in tokens:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            token=token,
        )
        try:
            messaging.send(message, app=app)
            result.success_tokens.append(token)
        except (messaging.UnregisteredError, firebase_exceptions.InvalidArgumentError):
            # UNREGISTERED / INVALID_ARGUMENT — token is permanently dead.
            result.failed_tokens.append(token)
            result.dead_tokens.append(token)
        except Exception:
            # Any other send failure (network, quota, malformed) — token
            # stays active, just counted as a failed attempt.
            result.failed_tokens.append(token)
    return result
