from django.contrib.gis.geos import Point
from django.http import Http404
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import permissions, status
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.catalog.models import SparePart
from apps.common.permissions import IsAdmin, IsCustomer

from .models import Cart, CartItem, Order, OrderShipment
from .serializers import (
    AdminOrderShipmentUpdateSerializer,
    CartItemCreateSerializer,
    CartItemSerializer,
    CartItemUpdateSerializer,
    CartSerializer,
    OrderCreateSerializer,
    OrderSerializer,
    OrderShipmentSerializer,
)
from .services.checkout import cancel_order, create_order_from_cart
from .services.payments import initiate_payment


class CartView(APIView):
    """GET /cart"""

    permission_classes = [permissions.IsAuthenticated, IsCustomer]

    def get(self, request):
        cart, _ = Cart.objects.get_or_create(customer=request.user)
        return Response(CartSerializer(cart).data)


class CartItemCreateView(APIView):
    """POST /cart/items — adds to an existing line's quantity if the part
    is already in the cart (upsert on the (cart, spare_part) unique
    constraint), rather than erroring."""

    permission_classes = [permissions.IsAuthenticated, IsCustomer]

    def post(self, request):
        serializer = CartItemCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        spare_part = get_object_or_404(SparePart, pk=serializer.validated_data["spare_part_id"])
        quantity = serializer.validated_data["quantity"]

        cart, _ = Cart.objects.get_or_create(customer=request.user)
        item = CartItem.objects.filter(cart=cart, spare_part=spare_part).first()
        new_quantity = (item.quantity if item else 0) + quantity

        # Validate before writing anything — an existing `get_or_create()`
        # here would persist the new-line case even when the stock check
        # below rejects it, since get_or_create() commits on creation
        # before this function ever gets a chance to raise.
        if new_quantity > spare_part.stock_quantity:
            raise ValidationError(
                f"Only {spare_part.stock_quantity} of '{spare_part.title}' in stock."
            )

        if item is None:
            item = CartItem.objects.create(cart=cart, spare_part=spare_part, quantity=new_quantity)
        else:
            item.quantity = new_quantity
            item.save(update_fields=["quantity"])
        return Response(CartItemSerializer(item).data, status=status.HTTP_201_CREATED)


class CartItemUpdateDeleteView(APIView):
    """PATCH/DELETE /cart/items/{id} — scoped to the requesting user's own
    cart. A cart-item id belonging to someone else 404s rather than 403s,
    so we don't leak the existence of other users' cart contents."""

    permission_classes = [permissions.IsAuthenticated, IsCustomer]

    def _get_item(self, request, pk):
        return get_object_or_404(CartItem, pk=pk, cart__customer=request.user)

    def patch(self, request, pk):
        item = self._get_item(request, pk)
        serializer = CartItemUpdateSerializer(item, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        quantity = serializer.validated_data.get("quantity", item.quantity)
        if quantity > item.spare_part.stock_quantity:
            raise ValidationError(f"Only {item.spare_part.stock_quantity} in stock.")
        serializer.save()
        return Response(CartItemSerializer(item).data)

    def delete(self, request, pk):
        item = self._get_item(request, pk)
        item.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class OrderListCreateView(APIView):
    """GET /orders (own order history), POST /orders (checkout from cart).
    Not itemized verbatim in PLAN.md §4's endpoint list, but a direct,
    unavoidable consequence of "checkout... endpoints" existing at all."""

    permission_classes = [permissions.IsAuthenticated, IsCustomer]

    def get(self, request):
        orders = Order.objects.filter(customer=request.user).prefetch_related("items__spare_part")
        return Response(OrderSerializer(orders, many=True).data)

    def post(self, request):
        serializer = OrderCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        order = create_order_from_cart(
            user=request.user, delivery_address=serializer.validated_data["delivery_address"]
        )
        return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)


def _get_owned_or_admin_order(request, pk):
    order = get_object_or_404(Order, pk=pk)
    if order.customer_id != request.user.id and request.user.role != "ADMIN":
        # 404, not 403: consistent with the cart-item isolation policy
        # above — don't confirm another customer's order id exists.
        raise Http404
    return order


class OrderDetailView(APIView):
    """GET /orders/{id} — owner or admin."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        order = _get_owned_or_admin_order(request, pk)
        return Response(OrderSerializer(order).data)


class OrderCancelView(APIView):
    """POST /orders/{id}/cancel — owner-only, PENDING-only. Flagged
    addition beyond PLAN.md §4's literal list: it's the only path into the
    CANCELLED state that §8's stock-release policy requires."""

    permission_classes = [permissions.IsAuthenticated, IsCustomer]

    def post(self, request, pk):
        order = get_object_or_404(Order, pk=pk, customer=request.user)
        order = cancel_order(order)
        return Response(OrderSerializer(order).data)


class OrderShipmentView(APIView):
    """GET /orders/{id}/shipment — owner or admin. 404 if not dispatched yet."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        order = _get_owned_or_admin_order(request, pk)
        shipment = get_object_or_404(OrderShipment, order=order)
        return Response(OrderShipmentSerializer(shipment).data)


class AdminOrderShipmentView(APIView):
    """PATCH /admin/orders/{id}/shipment — upserts the shipment and
    cascades Order.status: first time courier info is set -> DISPATCHED;
    mark_delivered=true -> DELIVERED."""

    permission_classes = [permissions.IsAuthenticated, IsAdmin]

    def patch(self, request, pk):
        order = get_object_or_404(Order, pk=pk)
        serializer = AdminOrderShipmentUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        shipment, _ = OrderShipment.objects.get_or_create(order=order)
        was_dispatched = shipment.dispatched_at is not None

        if "courier_name" in data:
            shipment.courier_name = data["courier_name"]
        if "tracking_ref" in data:
            shipment.tracking_ref = data["tracking_ref"]
        if "lat" in data:
            shipment.current_location = Point(data["lng"], data["lat"], srid=4326)
        if not was_dispatched and (data.get("courier_name") or data.get("tracking_ref")):
            shipment.dispatched_at = timezone.now()
        if data.get("mark_delivered"):
            shipment.delivered_at = timezone.now()
        shipment.save()

        if shipment.delivered_at and order.status != "DELIVERED":
            order.status = "DELIVERED"
            order.save(update_fields=["status"])
        elif shipment.dispatched_at and order.status == "PAID":
            order.status = "DISPATCHED"
            order.save(update_fields=["status"])

        return Response(OrderShipmentSerializer(shipment).data)


class OrderPayView(APIView):
    """POST /orders/{id}/pay — owner-only. body: {"payment_method": "..."}"""

    permission_classes = [permissions.IsAuthenticated, IsCustomer]

    def post(self, request, pk):
        order = get_object_or_404(Order, pk=pk, customer=request.user)
        payment_method = request.data.get("payment_method")
        if not payment_method:
            raise ValidationError({"payment_method": "This field is required."})
        result = initiate_payment(user=request.user, payment_method=payment_method, order=order)
        return Response(result, status=status.HTTP_201_CREATED)
