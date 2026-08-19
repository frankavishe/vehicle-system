from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver

from apps.users.models import UserRole

from .models import ProviderProfile


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_provider_profile(sender, instance, created, **kwargs):
    """Auto-create a ProviderProfile the moment a MECHANIC/RECOVERY user is
    created. This is how the "only mechanics/recovery get a profile" rule
    from models.py is enforced in practice."""
    if created and instance.role in (UserRole.MECHANIC, UserRole.RECOVERY):
        ProviderProfile.objects.get_or_create(user=instance)
