"""Cart -> Order conversion. Isolated from views.py since this is the
concurrency-sensitive core of the whole checkout flow (PLAN.md §8's
stock-reservation policy: reserved at order creation, released on cancel)."""

from django.db import transaction
from rest_framework import serializers

from apps.catalog.models import SparePart

from ..models import Order, OrderItem, OrderStatus


class InsufficientStockError(serializers.ValidationError):
    pass


@transaction.atomic
def create_order_from_cart(*, user, delivery_address):
    """Converts `user`'s cart into an Order, atomically. Re-validates stock
    at checkout time (not just at add-to-cart time, since stock can change
    in between) and decrements it. Raises InsufficientStockError (a
    ValidationError subclass) naming the offending part if any line can't
    be fulfilled — no partial order is created."""

    cart = user.cart
    items = list(cart.items.select_related("spare_part").all())
    if not items:
        raise serializers.ValidationError("Cart is empty.")

    # Lock the involved SparePart rows in a stable order (by id) so two
    # concurrent checkouts touching overlapping parts can't deadlock each
    # other, then re-check stock under the lock.
    part_ids = sorted(item.spare_part_id for item in items)
    locked_parts = {
        part.id: part
        for part in SparePart.objects.select_for_update().filter(id__in=part_ids)
    }

    for item in items:
        part = locked_parts[item.spare_part_id]
        if item.quantity > part.stock_quantity:
            raise InsufficientStockError(
                f"Insufficient stock for '{part.title}': requested {item.quantity}, "
                f"available {part.stock_quantity}."
            )

    total_amount = sum(
        (locked_parts[item.spare_part_id].price * item.quantity for item in items),
        start=0,
    )
    order = Order.objects.create(
        customer=user, total_amount=total_amount, delivery_address=delivery_address
    )
    for item in items:
        part = locked_parts[item.spare_part_id]
        OrderItem.objects.create(
            order=order, spare_part=part, quantity=item.quantity, unit_price=part.price
        )
        part.stock_quantity -= item.quantity
        part.save(update_fields=["stock_quantity"])

    cart.items.all().delete()
    return order


@transaction.atomic
def cancel_order(order):
    """Only valid from PENDING. Restores stock for every line (the
    "released on CANCELLED" half of PLAN.md §8's stock policy)."""

    if order.status != OrderStatus.PENDING:
        raise serializers.ValidationError("Only a PENDING order can be cancelled.")

    for item in order.items.select_related("spare_part").all():
        SparePart.objects.filter(id=item.spare_part_id).update(
            stock_quantity=item.spare_part.stock_quantity + item.quantity
        )
    order.status = OrderStatus.CANCELLED
    order.save(update_fields=["status"])
    return order
