from django.contrib import admin as plain_admin
from django.contrib.gis import admin

from .models import ProviderDocument, ProviderProfile


@admin.register(ProviderProfile)
class ProviderProfileAdmin(admin.GISModelAdmin):
    list_display = ["user", "is_available", "rating", "service_radius_km", "updated_at"]
    list_filter = ["is_available"]
    search_fields = ["user__email", "user__full_name", "vehicle_plate"]


@plain_admin.register(ProviderDocument)
class ProviderDocumentAdmin(plain_admin.ModelAdmin):
    list_display = ["provider", "doc_type", "verified", "uploaded_at"]
    list_filter = ["verified", "doc_type"]
    search_fields = ["provider__email", "provider__full_name"]
    actions = ["mark_verified"]

    @plain_admin.action(description="Mark selected documents as verified")
    def mark_verified(self, request, queryset):
        queryset.update(verified=True)
