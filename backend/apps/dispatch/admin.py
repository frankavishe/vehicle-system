from django.contrib.gis import admin

from .models import PartsSourcingRequest, ServiceRequest


@admin.register(ServiceRequest)
class ServiceRequestAdmin(admin.GISModelAdmin):
    list_display = ["id", "service_type", "status", "customer", "provider", "created_at"]
    list_filter = ["service_type", "status"]
    search_fields = ["customer__email", "provider__email"]


@admin.register(PartsSourcingRequest)
class PartsSourcingRequestAdmin(admin.ModelAdmin):
    list_display = ["id", "service_request", "requested_by", "spare_part", "quantity", "status", "created_at"]
    list_filter = ["status"]
    search_fields = ["requested_by__email"]
