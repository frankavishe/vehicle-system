# OSRM Tanzania extract — one-time setup

PLAN.md §5.2 chose self-hosted OSRM (Tanzania Geofabrik extract) over a
paid routing API as the primary distance source for the RECOVERY fare
engine, falling back to Haversine when OSRM has no route or is
unreachable. This is a **manual, one-time data-prep step** — not
something `docker-compose up` does for you, and not something this repo
can commit (the processed dataset is hundreds of MB). Until it's done,
`infra/docker-compose.yml`'s `osrm` service simply has nothing to serve
and every fare estimate uses the Haversine fallback — the app is fully
functional either way (see `backend/apps/dispatch/services/fare.py`).

## Steps

Run these once from `infra/osrm/` (creates `infra/osrm/data/`, which is
gitignored):

```sh
mkdir -p data && cd data

# 1. Download the Tanzania extract (~100-200MB, updated periodically by
#    Geofabrik — re-run this + the steps below to refresh road data).
curl -O https://download.geofabrik.de/africa/tanzania-latest.osm.pbf

# 2. Extract, partition, customize — the standard OSRM MLD pipeline
#    (matches the `--algorithm mld` flag in docker-compose.yml's osrm
#    service command). Each step reads the previous step's output.
docker run --rm -v "$(pwd):/data" osrm/osrm-backend:v5.27.1 \
  osrm-extract -p /opt/car.lua /data/tanzania-latest.osm.pbf
docker run --rm -v "$(pwd):/data" osrm/osrm-backend:v5.27.1 \
  osrm-partition /data/tanzania-latest.osrm
docker run --rm -v "$(pwd):/data" osrm/osrm-backend:v5.27.1 \
  osrm-customize /data/tanzania-latest.osrm
```

Then `docker-compose up osrm` (or restart the full stack) — it serves on
the internal compose network at `http://osrm:5000`, which is
`OSRM_BASE_URL`'s default (`backend/config/settings/base.py`).

## Refreshing later

OSM road-network completeness in rural Tanzania improves over time
(PLAN.md §5.2 flags this explicitly) — periodically re-run all three
steps above against a fresh `.osm.pbf` download to pick up improvements.
There's no automated schedule for this; it's an operational task, not
application code.
