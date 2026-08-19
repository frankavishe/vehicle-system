"""Phone normalization at registration time, per PLAN.md §5.4: validating
E.164 format at signup is "the better fix" so a malformed number fails at
signup rather than at dispatch/payout time later. Independent of the Beem
SMS integration itself (Phase 3) — this only owns normalization/validation."""

import phonenumbers
from django.core.exceptions import ValidationError


def normalize_tz_phone(raw_phone: str) -> str:
    """Parse `raw_phone` (assuming Tanzania as the default region for
    national-format input) and return it in Beem's expected international
    format, e.g. `255712345678`.

    Raises `django.core.exceptions.ValidationError` if the number isn't a
    valid, possible phone number.
    """
    try:
        parsed = phonenumbers.parse(raw_phone, "TZ")
    except phonenumbers.NumberParseException as exc:
        raise ValidationError(f"'{raw_phone}' is not a valid phone number.") from exc

    if not phonenumbers.is_valid_number(parsed):
        raise ValidationError(f"'{raw_phone}' is not a valid phone number.")

    e164 = phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164)
    # Beem expects no leading '+' (e.g. 255XXXXXXXXX) — see PLAN.md §5.4.
    return e164.lstrip("+")
