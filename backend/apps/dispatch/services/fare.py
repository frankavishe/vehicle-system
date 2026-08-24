"""Fare engine (PLAN.md §5.2): `fare = base_fee + distance_km * per_km_rate`.

MECHANIC requests have no `dropoff_location` (call-out only, see
`ServiceRequestCreateSerializer`) — there's no meaningful "distance" to
price, so those are a flat `FARE_BASE_FEE`. RECOVERY requests price the
pickup->dropoff tow distance, preferring self-hosted OSRM (a real
road-network distance) and falling back to Haversine (straight-line)
whenever OSRM has no route or is unreachable — the same redundancy
pattern already used for payments (PLAN.md §5.3), and explicitly called
for in §5.2 given Tanzania's uneven OSM road-network completeness.
"""

import math
from decimal import ROUND_HALF_UP, Decimal

import requests
from django.conf import settings
from django.contrib.gis.geos import Point

EARTH_RADIUS_KM = 6371.0088


def _as_money(value: float) -> Decimal:
    # Matches `estimated_fare`/`final_fare`'s DECIMAL(10,2) columns —
    # every other money value in the codebase (order totals, cart lines)
    # is a Decimal, not a bare float.
    return Decimal(str(value)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def _haversine_km(pickup: Point, dropoff: Point) -> float:
    lat1, lng1 = math.radians(pickup.y), math.radians(pickup.x)
    lat2, lng2 = math.radians(dropoff.y), math.radians(dropoff.x)
    dlat, dlng = lat2 - lat1, lng2 - lng1
    a = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlng / 2) ** 2
    return EARTH_RADIUS_KM * 2 * math.asin(math.sqrt(a))


def _osrm_distance_km(pickup: Point, dropoff: Point) -> float | None:
    """Returns the OSRM road-network distance in km, or None on any
    failure (unreachable, timeout, non-200, no route) — callers fall back
    to Haversine rather than propagating the error, per §5.2."""

    url = (
        f"{settings.OSRM_BASE_URL}/route/v1/driving/"
        f"{pickup.x},{pickup.y};{dropoff.x},{dropoff.y}"
    )
    try:
        response = requests.get(
            url, params={"overview": "false"}, timeout=settings.OSRM_TIMEOUT_SECONDS
        )
        response.raise_for_status()
        data = response.json()
        routes = data.get("routes") or []
        if not routes:
            return None
        return routes[0]["distance"] / 1000  # OSRM returns meters
    except (requests.RequestException, ValueError, KeyError, IndexError):
        return None


def estimate_fare(*, service_type: str, pickup: Point, dropoff: Point | None) -> Decimal:
    if service_type == "MECHANIC" or dropoff is None:
        return _as_money(settings.FARE_BASE_FEE)

    distance_km = _osrm_distance_km(pickup, dropoff)
    if distance_km is None:
        distance_km = _haversine_km(pickup, dropoff)

    return _as_money(settings.FARE_BASE_FEE + distance_km * settings.FARE_PER_KM_RATE)
