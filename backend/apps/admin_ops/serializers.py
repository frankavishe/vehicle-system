from rest_framework import serializers

from apps.providers.models import ProviderProfile

from .models import Dispute, Payout, PayoutItem


class DisputeRaiseSerializer(serializers.Serializer):
    reason = serializers.CharField()


class DisputeSerializer(serializers.ModelSerializer):
    """`service_request`/`raised_by`/`resolved_by` stay plain FK ids
    (`web/`'s existing DisputeManager.tsx reads `service_request` as a
    string) — the 4 fields below are additive, read-only, and exist so
    003-admin-mobile-app's mobile client (and any future web update) can
    show job/complainant/resolver detail without a second lookup
    (spec.md FR-002/FR-003, research.md §3)."""

    service_request_summary = serializers.SerializerMethodField()
    raised_by_name = serializers.CharField(source="raised_by.full_name", read_only=True, default=None)
    raised_by_email = serializers.CharField(source="raised_by.email", read_only=True, default=None)
    resolved_by_name = serializers.CharField(
        source="resolved_by.full_name", read_only=True, default=None
    )

    class Meta:
        model = Dispute
        fields = [
            "id", "service_request", "raised_by", "reason", "status", "resolved_by", "created_at",
            "service_request_summary", "raised_by_name", "raised_by_email", "resolved_by_name",
        ]
        read_only_fields = fields

    def get_service_request_summary(self, obj):
        sr = obj.service_request
        if sr is None:
            return None
        return {
            "id": str(sr.id),
            "service_type": sr.service_type,
            "status": sr.status,
            "customer_name": sr.customer.full_name if sr.customer_id else None,
            "provider_name": sr.provider.full_name if sr.provider_id else None,
        }


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
