"""Geo-correctness unit tests for the flagged dwithin/D(km=...) fix
(services/matching.py) — a real ST_DWithin-on-geometry bug would have
misread the radius as degrees, not km, and silently matched everyone or
no one."""

import pytest
from django.contrib.gis.geos import Point

from apps.dispatch.models import ServiceType
from apps.dispatch.services.matching import match_providers
from apps.users.models import UserRole
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db

PICKUP = Point(39.2083, -6.7924, srid=4326)  # Dar es Salaam
# ~5km north of PICKUP (1 degree latitude ~= 111km).
NEARBY = Point(39.2083, -6.7924 + 0.045, srid=4326)
# ~80km north — outside DISPATCH_MAX_RADIUS_KM's default 50km prefilter.
FAR_AWAY = Point(39.2083, -6.7924 + 0.72, srid=4326)


def _mechanic(*, is_available=True, location=None, radius_km=15):
    user = UserFactory(role=UserRole.MECHANIC)
    profile = user.provider_profile
    profile.is_available = is_available
    profile.current_location = location
    profile.service_radius_km = radius_km
    profile.save()
    return profile


def test_matches_provider_within_own_radius():
    profile = _mechanic(location=NEARBY, radius_km=10)
    matched = match_providers(PICKUP, ServiceType.MECHANIC)
    assert profile in matched


def test_excludes_provider_outside_own_radius_even_if_within_global_prefilter():
    profile = _mechanic(location=NEARBY, radius_km=3)  # ~5km away, radius only 3km
    matched = match_providers(PICKUP, ServiceType.MECHANIC)
    assert profile not in matched


def test_excludes_provider_beyond_global_max_radius():
    profile = _mechanic(location=FAR_AWAY, radius_km=100)  # radius huge, but too far
    matched = match_providers(PICKUP, ServiceType.MECHANIC)
    assert profile not in matched


def test_excludes_unavailable_provider():
    profile = _mechanic(is_available=False, location=NEARBY, radius_km=10)
    matched = match_providers(PICKUP, ServiceType.MECHANIC)
    assert profile not in matched


def test_excludes_wrong_role():
    user = UserFactory(role=UserRole.RECOVERY)
    profile = user.provider_profile
    profile.is_available = True
    profile.current_location = NEARBY
    profile.service_radius_km = 10
    profile.save()

    matched = match_providers(PICKUP, ServiceType.MECHANIC)
    assert profile not in matched


def test_orders_by_distance_nearest_first():
    closer = _mechanic(location=PICKUP, radius_km=20)
    farther = _mechanic(location=NEARBY, radius_km=20)
    matched = match_providers(PICKUP, ServiceType.MECHANIC)
    assert matched.index(closer) < matched.index(farther)
