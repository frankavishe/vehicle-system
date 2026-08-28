from django.contrib.gis.geos import Point
from rest_framework import generics, permissions
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.permissions import IsMechanic, IsProvider

# apps.admin_ops already imports apps.providers.models the other way
# (ProviderProfile, for its own map/payout views) — this is the first
# import in the providers -> admin_ops direction, not a new dependency
# edge that creates a cycle (admin_ops.serializers never imports
# apps.providers.views). Payout/PayoutSerializer are reused unchanged;
# see specs/001-mechanic-web-portal/{spec.md Clarifications,
# contracts/rest.md}.
from apps.admin_ops.models import Payout
from apps.admin_ops.serializers import PayoutSerializer

from .models import ProviderDocument, ProviderProfile
from .serializers import ProviderAvailabilitySerializer, ProviderDocumentSerializer, ProviderLocationSerializer


class ProviderAvailabilityView(APIView):
    """GET (flagged addition — the mechanic web portal's dashboard needs
    to render the current on/off state before the mechanic ever toggles
    it, same reasoning as ProviderDocumentListCreateView's own flagged
    GET below), PATCH /providers/me/availability."""

    permission_classes = [permissions.IsAuthenticated, IsProvider]

    def get(self, request):
        profile = ProviderProfile.objects.get(user=request.user)
        return Response(ProviderAvailabilitySerializer(profile).data)

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


class ProviderPayoutListView(generics.ListAPIView):
    """GET /providers/me/payouts — new, self-scoped (specs/001-mechanic-
    web-portal spec.md Clarifications): the only existing payout-read
    endpoint, AdminPayoutListView (apps.admin_ops), is IsAdmin-only, so a
    mechanic has no way to read their own earnings today. Reuses
    Payout/PayoutItem/PayoutSerializer unchanged; scoped to
    `provider=request.user` at the queryset level so a mechanic can never
    pass another provider's id (FR-011) — deliberately IsMechanic rather
    than IsProvider since nothing in this feature asks for the RECOVERY
    case."""

    serializer_class = PayoutSerializer
    permission_classes = [permissions.IsAuthenticated, IsMechanic]

    def get_queryset(self):
        qs = Payout.objects.filter(provider=self.request.user).select_related(
            "provider"
        ).prefetch_related("items")
        period_start = self.request.query_params.get("period_start")
        period_end = self.request.query_params.get("period_end")
        if period_start:
            qs = qs.filter(created_at__date__gte=period_start)
        if period_end:
            # __date__lte (not __lte) — a bare date string compared against
            # a DateTimeField would mean "before midnight at the *start* of
            # period_end", silently excluding every payout created later
            # that same day (found via manual QA: today's seeded payout
            # vanished from its own default 30-day-ending-today range).
            qs = qs.filter(created_at__date__lte=period_end)
        return qs
