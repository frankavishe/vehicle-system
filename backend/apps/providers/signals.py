from decimal import ROUND_HALF_UP, Decimal

from django.conf import settings
from django.db.models import Avg
from django.db.models.signals import post_save
from django.dispatch import receiver

from apps.users.models import UserRole

from .models import ProviderProfile

# Imported at module level, not lazily inside the receiver: this module is
# itself only ever imported from ProvidersConfig.ready() (apps.py), by
# which point every app's models module is already loaded — no circular-
# import risk despite the cross-app (`providers` -> `dispatch`) reference.
# `@receiver(sender=...)` also requires the real model class, not a
# "app_label.ModelName" string (that only works for lazy FK targets).
from apps.dispatch.models import Review  # noqa: E402


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_provider_profile(sender, instance, created, **kwargs):
    """Auto-create a ProviderProfile the moment a MECHANIC/RECOVERY user is
    created. This is how the "only mechanics/recovery get a profile" rule
    from models.py is enforced in practice."""
    if created and instance.role in (UserRole.MECHANIC, UserRole.RECOVERY):
        ProviderProfile.objects.get_or_create(user=instance)


@receiver(post_save, sender=Review)
def recompute_provider_rating(sender, instance, created, **kwargs):
    """Phase 4: `provider_profiles.rating` (§3.1) has no other writer —
    every Review against one of a provider's service_requests recomputes
    their average."""
    if not created:
        return

    provider_id = instance.service_request.provider_id
    if provider_id is None:
        return

    avg = Review.objects.filter(service_request__provider_id=provider_id).aggregate(
        avg=Avg("rating")
    )["avg"]
    if avg is None:
        return

    rating = Decimal(str(avg)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    ProviderProfile.objects.filter(user_id=provider_id).update(rating=rating)
