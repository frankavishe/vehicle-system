from django.contrib import admin

from .models import DeviceToken, Notification


@admin.register(DeviceToken)
class DeviceTokenAdmin(admin.ModelAdmin):
    list_display = ["user", "platform", "is_active", "created_at", "updated_at"]
    list_filter = ["platform", "is_active"]
    search_fields = ["user__email", "fcm_token"]


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ["user", "category", "delivery_status", "sms_fallback_sent", "read", "created_at"]
    list_filter = ["category", "delivery_status", "read"]
    search_fields = ["user__email", "title"]
