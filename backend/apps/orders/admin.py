from django.contrib import admin
from django.contrib.gis.admin import GISModelAdmin

from .models import Cart, CartItem, Order, OrderItem, OrderShipment, Payment


class CartItemInline(admin.TabularInline):
    model = CartItem
    extra = 0


@admin.register(Cart)
class CartAdmin(admin.ModelAdmin):
    list_display = ["customer", "updated_at"]
    search_fields = ["customer__email"]
    inlines = [CartItemInline]


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ["id", "customer", "status", "total_amount", "created_at"]
    list_filter = ["status"]
    search_fields = ["customer__email", "id"]
    inlines = [OrderItemInline]


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ["id", "order", "provider_gateway", "payment_method", "amount", "status", "created_at"]
    list_filter = ["provider_gateway", "payment_method", "status"]
    search_fields = ["transaction_ref", "gateway_transaction_id"]
    # Gateway-owned fields — never hand-edited from the admin.
    readonly_fields = ["transaction_ref", "gateway_transaction_id"]


@admin.register(OrderShipment)
class OrderShipmentAdmin(GISModelAdmin):
    list_display = ["order", "courier_name", "tracking_ref", "dispatched_at", "delivered_at"]
    search_fields = ["order__id", "tracking_ref"]
