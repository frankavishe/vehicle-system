from rest_framework import serializers

from .models import ProviderProfile


class ProviderAvailabilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = ProviderProfile
        fields = ["is_available"]


class ProviderLocationSerializer(serializers.ModelSerializer):
    lat = serializers.FloatField(write_only=True)
    lng = serializers.FloatField(write_only=True)
    current_location = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = ProviderProfile
        fields = ["lat", "lng", "current_location"]

    def get_current_location(self, obj):
        if obj.current_location is None:
            return None
        return {"lat": obj.current_location.y, "lng": obj.current_location.x}
