"""Guarded Beem Africa SMS send — plain REST + Basic Auth via `requests`,
no dedicated SDK package (PLAN.md §5.4). No-op (returns False) unless
credentials are configured, same pattern as `services/fcm.py`."""

import requests
from django.conf import settings
from django.core.exceptions import ValidationError

from apps.users.validators import normalize_tz_phone


def is_configured() -> bool:
    return bool(
        settings.BEEM_API_KEY and settings.BEEM_SECRET_KEY and settings.BEEM_SENDER_ID
    )


def send_sms(phone: str, message: str) -> bool:
    """Sends `message` to `phone` (normalized to E.164 first). Returns
    True only on a confirmed-accepted response from Beem — "sent," not
    "delivered" (PLAN.md §5.4's own caveat: Beem's send call confirms
    acceptance for delivery, not that the handset received it)."""

    if not is_configured():
        return False

    try:
        # `phone` is already normalized at registration time
        # (apps.users.validators, run against /auth/register), but
        # re-normalize defensively rather than trust the stored value
        # unconditionally.
        e164_phone = normalize_tz_phone(phone)
    except ValidationError:
        return False

    try:
        response = requests.post(
            f"{settings.BEEM_BASE_URL}/v1/send",
            auth=(settings.BEEM_API_KEY, settings.BEEM_SECRET_KEY),
            json={
                "source_addr": settings.BEEM_SENDER_ID,
                "encoding": 0,
                "message": message,
                "recipients": [{"recipient_id": 1, "dest_addr": e164_phone}],
            },
            timeout=10,
        )
        return response.status_code in (200, 201)
    except requests.RequestException:
        return False
