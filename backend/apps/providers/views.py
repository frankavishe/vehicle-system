from django.contrib.gis.geos import Point
from rest_framework import generics, permissions
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.permissions import IsProvider

from .models import ProviderDocument, ProviderProfile
from .serializers import ProviderAvailabilitySerializer, ProviderDocumentSerializer, ProviderLocationSerializer


class ProviderAvailabilityView(APIView):
    """PATCH /providers/me/availability"""

    permission_classes = [permissions.IsAuthenticated, IsProvider]

    def patch(self, request):
        profile = ProviderProfile.objects.get(user=request.user)
        serializer = ProviderAvailabilitySerializer(profile, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class ProviderLocationView(APIView):
    """PATCH /providers/me/location"""

    permission_classes = [permissions.IsAuthenticated, IsProvider]

    def patch(self, request):
        profile = ProviderProfile.objects.get(user=request.user)
        # Not partial=True: lat/lng are a pair, always required together —
        # unlike availability, there's no meaningful "patch just one".
        serializer = ProviderLocationSerializer(profile, data=request.data)
        serializer.is_valid(raise_exception=True)
        lat = serializer.validated_data.pop("lat")
        lng = serializer.validated_data.pop("lng")
        profile.current_location = Point(lng, lat, srid=4326)
        profile.save(update_fields=["current_location", "updated_at"])
        return Response(ProviderLocationSerializer(profile).data)


class ProviderDocumentListCreateView(generics.ListCreateAPIView):
    """POST /providers/me/documents (multipart), GET /providers/me/documents
    (flagged addition — the Flutter documents screen needs to list its own
    uploads). `verified` stays Django-admin-only, no admin API this phase."""

    serializer_class = ProviderDocumentSerializer
    permission_classes = [permissions.IsAuthenticated, IsProvider]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        return ProviderDocument.objects.filter(provider=self.request.user)

    def perform_create(self, serializer):
        serializer.save(provider=self.request.user)
