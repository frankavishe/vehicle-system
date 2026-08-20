from django.contrib import admin

from .models import SparePart, Vendor


@admin.register(Vendor)
class VendorAdmin(admin.ModelAdmin):
    list_display = ["name", "contact_email", "contact_phone", "is_active", "created_at"]
    list_filter = ["is_active"]
    search_fields = ["name", "contact_email"]


@admin.register(SparePart)
class SparePartAdmin(admin.ModelAdmin):
    """Full spare-part CRUD (title/price/images/description/etc.) is
    Django-admin-only in Phase 2 — the REST API exposes browse/detail
    (read-only) plus the one admin stock-adjust endpoint, matching
    PLAN.md §4's precise endpoint list rather than a full parts-management
    REST surface."""

    list_display = ["title", "sku", "vendor", "price", "stock_quantity", "category"]
    list_filter = ["category"]
    search_fields = ["title", "sku"]
