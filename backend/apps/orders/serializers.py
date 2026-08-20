from rest_framework import serializers

from apps.catalog.serializers import SparePartListSerializer

from .models import Cart, CartItem, Order, OrderItem, OrderShipment


class CartItemSerializer(serializers.ModelSerializer):
    spare_part = SparePartListSerializer(read_only=True)

    class Meta:
        model = CartItem
        fields = ["id", "spare_part", "quantity"]
        read_only_fields = ["id", "spare_part"]


class CartItemCreateSerializer(serializers.Serializer):
    """POST /cart/items body — spare_part is write-only-by-id here, distinct
    from CartItemSerializer's read shape (which nests the full part)."""

    spare_part_id = serializers.UUIDField()
    quantity = serializers.IntegerField(min_value=1, default=1)


class CartItemUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CartItem
        fields = ["quantity"]

    def validate_quantity(self, value):
        if value < 1:
            raise serializers.ValidationError("quantity must be at least 1.")
        return value


class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many=True, read_only=True)
    total = serializers.SerializerMethodField()

    class Meta:
        model = Cart
        fields = ["id", "items", "total", "updated_at"]
        read_only_fields = fields

    def get_total(self, obj):
        return sum((item.spare_part.price * item.quantity for item in obj.items.all()), start=0)


class OrderItemSerializer(serializers.ModelSerializer):
    spare_part = SparePartListSerializer(read_only=True)

    class Meta:
        model = OrderItem
        fields = ["id", "spare_part", "quantity", "unit_price"]
        read_only_fields = fields


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = [
            "id", "status", "total_amount", "delivery_address", "items", "created_at",
        ]
        read_only_fields = fields


class OrderCreateSerializer(serializers.Serializer):
    """POST /orders body — the cart itself supplies the line items; this
    only carries what checkout adds on top."""

    delivery_address = serializers.CharField(allow_blank=False)


class OrderShipmentSerializer(serializers.ModelSerializer):
    current_location = serializers.SerializerMethodField()

    class Meta:
        model = OrderShipment
        fields = [
            "id", "courier_name", "tracking_ref", "dispatched_at", "delivered_at",
            "current_location",
        ]
        read_only_fields = fields

    def get_current_location(self, obj):
        if obj.current_location is None:
            return None
        return {"lat": obj.current_location.y, "lng": obj.current_location.x}


class AdminOrderShipmentUpdateSerializer(serializers.Serializer):
    """PATCH /admin/orders/{id}/shipment — all fields optional per-call
    (courier can be set first, location updated later, etc.)."""

    courier_name = serializers.CharField(required=False, allow_blank=True)
    tracking_ref = serializers.CharField(required=False, allow_blank=True)
    lat = serializers.FloatField(required=False)
    lng = serializers.FloatField(required=False)
    mark_delivered = serializers.BooleanField(required=False, default=False)

    def validate(self, attrs):
        has_lat = "lat" in attrs
        has_lng = "lng" in attrs
        if has_lat != has_lng:
            raise serializers.ValidationError("lat and lng must be provided together.")
        return attrs
