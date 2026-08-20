from django.conf import settings
from django.contrib.gis.db import models as gis_models
from django.db import models

from apps.catalog.models import SparePart
from apps.common.models import UUIDModel


class Cart(UUIDModel):
    """Matches PLAN.md §3.2's `carts` table — a persisted pre-checkout
    staging area (the spec jumps straight from "browse" to "checkout" with
    no cart table of its own)."""

    customer = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="cart"
    )
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "carts"

    def __str__(self):
        return f"Cart<{self.customer_id}>"


class CartItem(UUIDModel):
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE, related_name="items")
    spare_part = models.ForeignKey(SparePart, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)

    class Meta:
        db_table = "cart_items"
        constraints = [
            models.UniqueConstraint(fields=["cart", "spare_part"], name="unique_cart_spare_part")
        ]

    def __str__(self):
        return f"CartItem<{self.spare_part_id} x{self.quantity}>"


class OrderStatus(models.TextChoices):
    PENDING = "PENDING", "Pending"
    PAID = "PAID", "Paid"
    DISPATCHED = "DISPATCHED", "Dispatched"
    DELIVERED = "DELIVERED", "Delivered"
    CANCELLED = "CANCELLED", "Cancelled"


class Order(UUIDModel):
    """Matches PLAN.md §3.1's `orders` table."""

    customer = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="orders"
    )
    status = models.CharField(max_length=20, choices=OrderStatus.choices, default=OrderStatus.PENDING)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    delivery_address = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "orders"
        ordering = ["-created_at"]

    def __str__(self):
        return f"Order<{self.id}, {self.status}>"


class OrderItem(UUIDModel):
    """`unit_price` is snapshotted at order-creation time (not a live FK
    lookup to `SparePart.price`) — a later price change must not rewrite
    historical order totals. `on_delete=RESTRICT` matches PLAN.md §3.2:
    a spare part that's part of a historical order can't be hard-deleted."""

    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name="items")
    spare_part = models.ForeignKey(SparePart, on_delete=models.RESTRICT)
    quantity = models.PositiveIntegerField()
    unit_price = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        db_table = "order_items"

    def __str__(self):
        return f"OrderItem<{self.spare_part_id} x{self.quantity}>"


class OrderShipment(UUIDModel):
    """Matches PLAN.md §3.2's `order_shipments` table — parts-delivery
    parity with the mechanic/recovery side's live tracking, per §1's role
    matrix ("Live Breakdown Tracking" also applies to order fulfillment)."""

    order = models.OneToOneField(Order, on_delete=models.CASCADE, related_name="shipment")
    courier_name = models.CharField(max_length=150, null=True, blank=True)
    tracking_ref = models.CharField(max_length=255, null=True, blank=True)
    dispatched_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    current_location = gis_models.PointField(srid=4326, null=True, blank=True)

    class Meta:
        db_table = "order_shipments"

    def __str__(self):
        return f"OrderShipment<{self.order_id}>"


class PaymentMethod(models.TextChoices):
    CARD = "CARD", "Card"
    AIRTEL_MONEY = "AIRTEL_MONEY", "Airtel Money"
    TIGO_PESA = "TIGO_PESA", "Tigo Pesa"
    HALOPESA = "HALOPESA", "HaloPesa"
    MPESA = "MPESA", "M-Pesa"


class ProviderGateway(models.TextChoices):
    FLUTTERWAVE = "FLUTTERWAVE", "Flutterwave"
    SELCOM = "SELCOM", "Selcom"


class PaymentStatus(models.TextChoices):
    PENDING = "PENDING", "Pending"
    SUCCESSFUL = "SUCCESSFUL", "Successful"
    FAILED = "FAILED", "Failed"
    REFUNDED = "REFUNDED", "Refunded"


class Payment(UUIDModel):
    """Matches PLAN.md §3.2's `payments` table.

    `service_request_id` is deliberately a plain `UUIDField`, not a real
    `ForeignKey` — `apps.dispatch.ServiceRequest` (PLAN.md §3.1) doesn't
    exist yet (it's a Phase 3 model, out of scope for this phase per the
    Phase 2 plan). Phase 3 converts this to a real `ForeignKey` via a
    straightforward `AlterField` migration once that model exists; no data
    migration is needed since the underlying UUID values are unaffected by
    the type change.
    """

    order = models.ForeignKey(
        Order, on_delete=models.CASCADE, null=True, blank=True, related_name="payments"
    )
    service_request_id = models.UUIDField(null=True, blank=True, db_index=True)
    payment_method = models.CharField(max_length=20, choices=PaymentMethod.choices)
    provider_gateway = models.CharField(max_length=20, choices=ProviderGateway.choices)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=PaymentStatus.choices, default=PaymentStatus.PENDING)
    transaction_ref = models.CharField(max_length=255, null=True, blank=True)
    gateway_transaction_id = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "payments"
        ordering = ["-created_at"]
        constraints = [
            models.CheckConstraint(
                check=models.Q(order__isnull=False) | models.Q(service_request_id__isnull=False),
                name="payment_has_order_or_service_request",
            )
        ]

    def __str__(self):
        return f"Payment<{self.id}, {self.provider_gateway}, {self.status}>"
