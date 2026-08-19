from django.contrib.gis import admin

from .models import ProviderProfile


@admin.register(ProviderProfile)
class ProviderProfileAdmin(admin.GISModelAdmin):
    list_display = ["user", "is_available", "rating", "service_radius_km", "updated_at"]
    list_filter = ["is_available"]
    search_fields = ["user__email", "user__full_name", "vehicle_plate"]
