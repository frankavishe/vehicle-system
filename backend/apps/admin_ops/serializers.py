from rest_framework import serializers

from apps.providers.models import ProviderProfile

from .models import Dispute, Payout, PayoutItem


class DisputeRaiseSerializer(serializers.Serializer):
    reason = serializers.CharField()


class DisputeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dispute
        fields = ["id", "service_request", "raised_by", "reason", "status", "resolved_by", "created_at"]
        read_only_fields = fields


class PayoutItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = PayoutItem
        fields = ["id", "service_request", "amount"]
        read_only_fields = fields


class PayoutSerializer(serializers.ModelSerializer):
    items = PayoutItemSerializer(many=True, read_only=True)

    class Meta:
        model = Payout
        fields = [
            "id", "provider", "amount", "period_start", "period_end", "is_manual",
            "provider_gateway", "gateway_transaction_id", "status", "created_at",
            "paid_at", "items",
        ]
        read_only_fields = fields


class ProviderMapSerializer(serializers.ModelSerializer):
    """GET /admin/map — one row per provider with a known position, for
    the web fleet map (§1's Admin "PostGIS live map")."""

    lat = serializers.SerializerMethodField()
    lng = serializers.SerializerMethodField()
    full_name = serializers.CharField(source="user.full_name", read_only=True)
    role = serializers.CharField(source="user.role", read_only=True)

    class Meta:
        model = ProviderProfile
        fields = ["id", "full_name", "role", "is_available", "lat", "lng", "updated_at"]
        read_only_fields = fields

    def get_lat(self, obj):
        return obj.current_location.y if obj.current_location else None

    def get_lng(self, obj):
        return obj.current_location.x if obj.current_location else None
