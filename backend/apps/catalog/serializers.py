from rest_framework import serializers

from .models import SparePart, Vendor


class VendorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vendor
        fields = ["id", "name", "contact_email", "contact_phone", "is_active", "created_at"]
        read_only_fields = ["id", "created_at"]


class VendorSummarySerializer(serializers.ModelSerializer):
    """Nested read-only vendor summary embedded in spare-part responses."""

    class Meta:
        model = Vendor
        fields = ["id", "name"]


class SparePartListSerializer(serializers.ModelSerializer):
    vendor = VendorSummarySerializer(read_only=True)

    class Meta:
        model = SparePart
        fields = [
            "id", "title", "sku", "price", "stock_quantity", "category",
            "compatible_make", "compatible_model", "year_start", "year_end",
            "image_url", "vendor",
        ]
        read_only_fields = fields


class SparePartDetailSerializer(SparePartListSerializer):
    class Meta(SparePartListSerializer.Meta):
        fields = SparePartListSerializer.Meta.fields + ["description"]


class SparePartStockAdjustSerializer(serializers.Serializer):
    """PATCH /admin/parts/{id}/stock — `adjustment` is a signed delta
    (negative for write-offs/corrections), not an absolute value, so
    concurrent adjustments compose correctly (see the F()-expression update
    in the view)."""

    adjustment = serializers.IntegerField()

    def validate_adjustment(self, value):
        part = self.context["spare_part"]
        if part.stock_quantity + value < 0:
            raise serializers.ValidationError(
                f"Adjustment would drive stock below zero "
                f"(current: {part.stock_quantity}, adjustment: {value})."
            )
        return value
