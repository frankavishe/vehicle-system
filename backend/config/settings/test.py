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
