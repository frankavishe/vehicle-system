from decimal import Decimal

from django.conf import settings
from django.contrib.gis.db import models as gis_models
from django.db import models

from apps.common.models import UUIDModel


class ProviderProfile(UUIDModel):
    """Matches PLAN.md §3.1's `provider_profiles` table. One row per
    MECHANIC/RECOVERY user, auto-created by `signals.py` on user creation.
    Role restriction (only mechanics/recovery get a profile) is enforced
    app-side rather than a DB CHECK, since Postgres checks can't
    cross-reference `users.role`."""

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="provider_profile"
    )
    is_available = models.BooleanField(default=False)
    # GEOMETRY(Point, 4326) in PLAN.md §3.1. `spatial_index=True` (the
    # GeometryField default) auto-creates the GiST index Phase 3's
    # ST_DWithin radius-match query (PLAN.md §5.1) needs — no explicit
    # index declaration required.
    current_location = gis_models.PointField(srid=4326, null=True, blank=True)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=Decimal("5.00"))
    vehicle_plate = models.CharField(max_length=30, null=True, blank=True)
    service_radius_km = models.PositiveIntegerField(default=15)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "provider_profiles"

    def __str__(self):
        return f"ProviderProfile<{self.user.full_name}>"
