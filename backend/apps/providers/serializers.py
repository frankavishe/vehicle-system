from rest_framework import serializers

from .models import ProviderDocument, ProviderProfile


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


class ProviderDocumentSerializer(serializers.ModelSerializer):
    file = serializers.FileField(write_only=True)
    file_url = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = ProviderDocument
        fields = ["id", "doc_type", "file", "file_url", "verified", "uploaded_at"]
        read_only_fields = ["id", "file_url", "verified", "uploaded_at"]

    def get_file_url(self, obj):
        if not obj.file:
            return None
        request = self.context.get("request")
        url = obj.file.url
        return request.build_absolute_uri(url) if request else url
