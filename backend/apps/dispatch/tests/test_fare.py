from decimal import Decimal

import pytest
import responses
from django.contrib.gis.geos import Point

from apps.dispatch.services.fare import estimate_fare

# Dar es Salaam -> a point ~11km away by straight line, matching the
# module's own Haversine implementation (not an OSRM/real-world figure).
PICKUP = Point(39.2083, -6.7924, srid=4326)
DROPOFF = Point(39.30, -6.85, srid=4326)


def test_mechanic_request_is_flat_base_fee(settings):
    settings.FARE_BASE_FEE = 5000.0
    fare = estimate_fare(service_type="MECHANIC", pickup=PICKUP, dropoff=None)
    assert fare == Decimal("5000.00")


@responses.activate
def test_recovery_uses_osrm_distance_when_available(settings):
    settings.OSRM_BASE_URL = "http://osrm.test"
    settings.FARE_BASE_FEE = 5000.0
    settings.FARE_PER_KM_RATE = 1500.0
    responses.add(
        responses.GET,
        f"http://osrm.test/route/v1/driving/{PICKUP.x},{PICKUP.y};{DROPOFF.x},{DROPOFF.y}",
        json={"routes": [{"distance": 10000}]},  # 10km, in meters
        status=200,
    )

    fare = estimate_fare(service_type="RECOVERY", pickup=PICKUP, dropoff=DROPOFF)

    assert fare == Decimal("5000.00") + Decimal("10") * Decimal("1500.00")


@responses.activate
def test_recovery_falls_back_to_haversine_when_osrm_unreachable(settings):
    settings.OSRM_BASE_URL = "http://osrm.test"
    settings.FARE_BASE_FEE = 5000.0
    settings.FARE_PER_KM_RATE = 1500.0
    responses.add(
        responses.GET,
        f"http://osrm.test/route/v1/driving/{PICKUP.x},{PICKUP.y};{DROPOFF.x},{DROPOFF.y}",
        status=500,
    )

    fare = estimate_fare(service_type="RECOVERY", pickup=PICKUP, dropoff=DROPOFF)

    # Haversine distance between PICKUP/DROPOFF is ~11.4km — just assert
    # the fallback path produced a sane fare above the flat base fee,
    # rather than pinning an exact float.
    assert fare > Decimal("5000.00")


@responses.activate
def test_recovery_falls_back_to_haversine_when_osrm_has_no_route(settings):
    settings.OSRM_BASE_URL = "http://osrm.test"
    settings.FARE_BASE_FEE = 5000.0
    settings.FARE_PER_KM_RATE = 1500.0
    responses.add(
        responses.GET,
        f"http://osrm.test/route/v1/driving/{PICKUP.x},{PICKUP.y};{DROPOFF.x},{DROPOFF.y}",
        json={"routes": []},
        status=200,
    )

    fare = estimate_fare(service_type="RECOVERY", pickup=PICKUP, dropoff=DROPOFF)
    assert fare > Decimal("5000.00")
