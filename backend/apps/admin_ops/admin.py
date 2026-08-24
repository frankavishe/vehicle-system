from django.contrib import admin

from .models import Dispute, Payout, PayoutItem


@admin.register(Dispute)
class DisputeAdmin(admin.ModelAdmin):
    list_display = ["id", "service_request", "raised_by", "status", "resolved_by", "created_at"]
    list_filter = ["status"]
    search_fields = ["raised_by__email"]


class PayoutItemInline(admin.TabularInline):
    model = PayoutItem
    extra = 0


@admin.register(Payout)
class PayoutAdmin(admin.ModelAdmin):
    list_display = ["id", "provider", "amount", "status", "is_manual", "provider_gateway", "created_at"]
    list_filter = ["status", "is_manual", "provider_gateway"]
    search_fields = ["provider__email"]
    inlines = [PayoutItemInline]
