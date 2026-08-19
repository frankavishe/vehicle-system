from django.contrib.postgres.operations import CreateExtension
from django.db import migrations


class Migration(migrations.Migration):
    """Bootstraps the Postgres extensions AutoServe's schema depends on
    (PostGIS geometry columns, uuid-ossp for parity with PLAN.md §3.1's
    `uuid_generate_v4()` default — the ORM generates UUIDs Python-side so
    this isn't strictly required, but costs nothing to enable).

    Runs first so every other app's migrations can depend on it, keeping
    `manage.py migrate` the single bootstrap command instead of a manual
    `psql` step."""

    initial = True

    dependencies = []

    operations = [
        CreateExtension("postgis"),
        CreateExtension("uuid-ossp"),
    ]
