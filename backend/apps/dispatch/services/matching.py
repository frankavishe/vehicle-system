"""Radius-match engine (PLAN.md §5.1).

**Deviation from PLAN §5.1's literal raw SQL, flagged**: that SQL runs
`ST_DWithin(current_location, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326),
:radius_meters)` against `provider_profiles.current_location`, a plain
`GEOMETRY(Point, 4326)` column — not `geography`. PostGIS reads a
geometry-column `ST_DWithin` distance argument in the column's own SRID
units, which for SRID 4326 are **degrees**, not meters — `:radius_meters`
would silently be misread as a (huge) number of degrees.

The naive GeoDjango fix — the geodetic `dwithin` lookup with a `D(km=...)`
`Distance` object — turns out to hit the *same* wall from the other side:
Django's PostGIS backend explicitly refuses a `Distance` value on a
`dwithin` lookup against a geodetic geometry (not geography) column,
raising `ValueError: Only numeric values of degree units are allowed on
geographic DWithin queries` — it won't silently misinterpret it, but it
also won't do the conversion for you. The correct GeoDjango pattern for
real-world-unit distance queries on a plain geodetic geometry column is to
**annotate** the actual spheroid distance via `Distance(...)` and filter
the *annotated value* with `__lte=D(km=...)` — that generates a plain
`ST_DistanceSphere(...) <= meters` comparison (no `ST_DWithin`, no degree
ambiguity), which is what this function does. It costs the GiST index's
bounding-box prefilter (a full `ST_DistanceSphere` per candidate row
instead), an acceptable trade at this project's scale — flagged rather
than silently accepted.

Also corrects a second gap: the literal SQL takes one global
`:radius_meters`, but `provider_profiles.service_radius_km` is per-provider
(PLAN.md §3.1). Two-pass design:
  1. DB-side prefilter: annotate `Distance(...)` and keep rows within
     `settings.DISPATCH_MAX_RADIUS_KM` (a sane global upper bound so one
     query can't scan every provider in the database).
  2. Python-side: keep only providers whose own `service_radius_km`
     actually covers the annotated distance.
"""

from django.conf import settings
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D

from apps.providers.models import ProviderProfile

from ..models import ServiceType

_ROLE_BY_SERVICE_TYPE = {
    ServiceType.MECHANIC: "MECHANIC",
    ServiceType.RECOVERY: "RECOVERY",
}


def role_for_service_type(service_type: str) -> str:
    try:
        return _ROLE_BY_SERVICE_TYPE[service_type]
    except KeyError:
        raise ValueError(f"No provider role configured for service type '{service_type}'.")


def match_providers(pickup: Point, service_type: str):
    """Returns a list of `ProviderProfile`s available for `service_type`,
    within their own `service_radius_km` of `pickup`, nearest first."""

    role = role_for_service_type(service_type)
    max_radius = D(km=getattr(settings, "DISPATCH_MAX_RADIUS_KM", 50))

    candidates = (
        ProviderProfile.objects.select_related("user")
        .filter(user__role=role, is_available=True, current_location__isnull=False)
        .annotate(distance=Distance("current_location", pickup))
        .filter(distance__lte=max_radius)
        .order_by("distance")
    )

    return [
        profile
        for profile in candidates
        if profile.distance.km <= profile.service_radius_km
    ]
