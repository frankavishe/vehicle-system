from django.urls import path

from .views import (
    AdminOrderShipmentView,
    CartItemCreateView,
    CartItemUpdateDeleteView,
    CartView,
    OrderCancelView,
    OrderDetailView,
    OrderListCreateView,
    OrderPayView,
    OrderShipmentView,
    PaymentSimulateView,
)
from .webhook_views import FlutterwaveWebhookView, SelcomWebhookView

urlpatterns = [
    path("cart", CartView.as_view(), name="cart"),
    path("cart/items", CartItemCreateView.as_view(), name="cart-items-create"),
    path("cart/items/<uuid:pk>", CartItemUpdateDeleteView.as_view(), name="cart-items-detail"),
    path("orders", OrderListCreateView.as_view(), name="orders-list-create"),
    path("orders/<uuid:pk>", OrderDetailView.as_view(), name="orders-detail"),
    path("orders/<uuid:pk>/cancel", OrderCancelView.as_view(), name="orders-cancel"),
    path("orders/<uuid:pk>/pay", OrderPayView.as_view(), name="orders-pay"),
    path("orders/<uuid:pk>/shipment", OrderShipmentView.as_view(), name="orders-shipment"),
    path(
        "admin/orders/<uuid:pk>/shipment",
        AdminOrderShipmentView.as_view(),
        name="admin-orders-shipment",
    ),
    # TEMPORARY — see PAYMENT_SIMULATION_MODE's docstring in
    # config/settings/base.py; remove this route together with that flag.
    path("payments/<uuid:pk>/simulate", PaymentSimulateView.as_view(), name="payments-simulate"),
    # Mounted under /api/v1/ (config/urls.py) for consistency with every
    # other Phase 1/2 endpoint group, even though PLAN.md §4 writes this
    # bullet without that prefix.
    path("webhooks/flutterwave", FlutterwaveWebhookView.as_view(), name="webhook-flutterwave"),
    path("webhooks/selcom", SelcomWebhookView.as_view(), name="webhook-selcom"),
]
