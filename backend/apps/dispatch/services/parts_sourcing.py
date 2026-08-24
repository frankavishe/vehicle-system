"""Converts an APPROVED PartsSourcingRequest into a real Order, bypassing
the cart entirely. Mirrors `apps.orders.services.checkout.create_order_from_cart`'s
locking/snapshot pattern so the same stock-integrity guarantees hold."""

from django.db import transaction
from rest_framework import serializers

from apps.catalog.models import SparePart
from apps.orders.models import Order, OrderItem

from ..models import PartsSourcingStatus


@transaction.atomic
def convert_to_order(psr, *, delivery_address=None):
    if psr.status != PartsSourcingStatus.APPROVED:
        raise serializers.ValidationError("Only an APPROVED request can be converted to an order.")
    if psr.spare_part_id is None:
        raise serializers.ValidationError("This request's spare part no longer exists.")

    part = SparePart.objects.select_for_update().get(pk=psr.spare_part_id)
    if psr.quantity > part.stock_quantity:
        raise serializers.ValidationError(
            f"Insufficient stock for '{part.title}': requested {psr.quantity}, "
            f"available {part.stock_quantity}."
        )

    order = Order.objects.create(
        customer=psr.service_request.customer,
        total_amount=part.price * psr.quantity,
        delivery_address=delivery_address,
    )
    OrderItem.objects.create(
        order=order, spare_part=part, quantity=psr.quantity, unit_price=part.price
    )
    part.stock_quantity -= psr.quantity
    part.save(update_fields=["stock_quantity"])

    psr.order = order
    psr.status = PartsSourcingStatus.ORDERED
    psr.save(update_fields=["order", "status"])
    return order
