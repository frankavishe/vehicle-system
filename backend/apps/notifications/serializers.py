from rest_framework import serializers

from .models import DeviceToken, Notification


class DeviceTokenSerializer(serializers.ModelSerializer):
    # Declared explicitly to drop ModelSerializer's auto-generated
    # UniqueValidator (from the model's `unique=True`) — create() below
    # upserts on this field itself, so a repeat value is the expected
    # re-registration case, not a validation error.
    fcm_token = serializers.CharField(max_length=255)

    class Meta:
        model = DeviceToken
        fields = ["id", "fcm_token", "platform", "is_active", "created_at", "updated_at"]
        read_only_fields = ["id", "is_active", "created_at", "updated_at"]

    def create(self, validated_data):
        # POST /users/me/device-tokens upserts on fcm_token (a token can
        # rotate ownership between devices/re-registers) rather than
        # erroring on the unique constraint.
        user = self.context["request"].user
        token, _created = DeviceToken.objects.update_or_create(
            fcm_token=validated_data["fcm_token"],
            defaults={
                "user": user,
                "platform": validated_data["platform"],
                "is_active": True,
            },
        )
        return token


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = [
            "id", "category", "title", "body", "delivery_status",
            "sms_fallback_sent", "read", "created_at",
        ]
        read_only_fields = fields
