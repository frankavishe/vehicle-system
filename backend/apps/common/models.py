import uuid

from django.db import models


class UUIDModel(models.Model):
    """Abstract base giving every AutoServe table a UUID primary key,
    matching the `id UUID PRIMARY KEY DEFAULT uuid_generate_v4()` pattern
    used throughout PLAN.md §3."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    class Meta:
        abstract = True
