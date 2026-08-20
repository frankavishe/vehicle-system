from django.db import models

from apps.common.models import UUIDModel


class Vendor(UUIDModel):
    """Matches PLAN.md §3.2's `vendors` table — the role matrix's Admin
    "vendor management" feature has nothing to manage without this, and
    `spare_parts.vendor_id` (§3.1) has nothing to point at. Must migrate
    before SparePart (enforced naturally here since SparePart.vendor is a
    FK to this model, in the same app)."""

    name = models.CharField(max_length=255)
    contact_email = models.EmailField(max_length=255, null=True, blank=True)
    contact_phone = models.CharField(max_length=20, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "vendors"
        ordering = ["name"]

    def __str__(self):
        return self.name


class SparePart(UUIDModel):
    """Matches PLAN.md §3.1's `spare_parts` table."""

    vendor = models.ForeignKey(
        Vendor, on_delete=models.SET_NULL, null=True, blank=True, related_name="spare_parts"
    )
    title = models.CharField(max_length=255)
    sku = models.CharField(unique=True, max_length=100)
    description = models.TextField(null=True, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock_quantity = models.PositiveIntegerField(default=0)
    category = models.CharField(max_length=100)
    compatible_make = models.CharField(max_length=50, null=True, blank=True)
    compatible_model = models.CharField(max_length=50, null=True, blank=True)
    # Nullable pair = "still compatible with current production" (no upper
    # bound) / "unknown lower bound" respectively — a NULL on either side
    # means "no constraint on this end", not "zero rows match".
    year_start = models.IntegerField(null=True, blank=True)
    year_end = models.IntegerField(null=True, blank=True)
    image_url = models.URLField(max_length=500, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "spare_parts"
        ordering = ["title"]

    def __str__(self):
        return f"{self.title} ({self.sku})"
