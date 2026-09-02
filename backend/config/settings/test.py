from .base import *  # noqa: F401,F403

DEBUG = False

# GeoDjango's PointField has no SQLite equivalent, so tests run against a
# real Postgres/PostGIS instance — docker-compose's `db` service locally,
# a Postgres+PostGIS service container in CI (see .github/workflows/backend-ci.yml).
DATABASES["default"] = env.db(  # noqa: F405
    "DATABASE_URL",
    default="postgis://autoserve:autoserve@localhost:5432/autoserve_test",
)

PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.MD5PasswordHasher",  # fast, test-only
]

# TEMPORARY — see PAYMENT_SIMULATION_MODE's docstring in base.py. Pinned
# off here regardless of a developer's local .env so
# test_gateway_routing.py's real-routing assertions stay deterministic.
PAYMENT_SIMULATION_MODE = False

# Phase 3: tasks run synchronously in-process during tests — no worker/
# broker round-trip, no need for a running Redis in CI/local pytest.
CELERY_TASK_ALWAYS_EAGER = True
CELERY_TASK_EAGER_PROPAGATES = True
