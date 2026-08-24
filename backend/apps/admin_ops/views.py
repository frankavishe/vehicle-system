from django.db.models import Count, Sum
from django.http import Http404
from django.shortcuts import get_object_or_404
from rest_framework import generics, permissions, status
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.permissions import IsAdmin
from apps.dispatch.models import ServiceRequest
from apps.notifications.models import NotificationCategory
from apps.notifications.services.create import create_and_send
from apps.orders.models import Order, Payment, PaymentStatus
from apps.providers.models import ProviderProfile

from .models import Dispute, DisputeStatus, Payout
from .serializers import (
    DisputeRaiseSerializer,
    DisputeSerializer,
    PayoutSerializer,
    ProviderMapSerializer,
)
from .services.payout_batch import run_batch


class ServiceRequestDisputeCreateView(APIView):
    """POST /service-requests/{id}/disputes — any participant of that
    request (customer or its assigned provider) may raise one. Lives here
    (not apps.dispatch) per PLAN.md §2's layout: admin_ops owns disputes
    end-to-end, the same way parts_sourcing_requests FKs into
    apps.orders.Order across an app boundary already."""

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, sr_pk):
        sr = get_object_or_404(ServiceRequest, pk=sr_pk)
        user = request.user
        if user.id not in (sr.customer_id, sr.provider_id) and user.role != "ADMIN":
            raise Http404

        serializer = DisputeRaiseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        dispute = Dispute.objects.create(
            service_request=sr, raised_by=user, reason=serializer.validated_data["reason"]
        )

        # Notify the *other* participant — no all-admins broadcast
        # primitive exists yet (flagged, not silently skipped; admins see
        # every open dispute via GET /admin/disputes regardless).
        other = sr.provider if user.id == sr.customer_id else sr.customer
        if other:
            create_and_send(
                user=other,
                category=NotificationCategory.GENERAL,
                title="A dispute was raised",
                body=f"A dispute was raised on your {sr.service_type.lower()} request.",
            )

        return Response(DisputeSerializer(dispute).data, status=status.HTTP_201_CREATED)


class AdminDisputeListView(generics.ListAPIView):
    """GET /admin/disputes"""

    queryset = Dispute.objects.select_related("service_request", "raised_by", "resolved_by")
    serializer_class = DisputeSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    filterset_fields = ["status"]


class AdminDisputeResolveView(APIView):
    """PATCH /admin/disputes/{id}/resolve — no body needed; resolved_by is
    always the requesting admin."""

    permission_classes = [permissions.IsAuthenticated, IsAdmin]

    def patch(self, request, pk):
        dispute = get_object_or_404(Dispute, pk=pk)
        if dispute.status == DisputeStatus.RESOLVED:
            raise ValidationError("This dispute is already resolved.")

        dispute.status = DisputeStatus.RESOLVED
        dispute.resolved_by = request.user
        dispute.save(update_fields=["status", "resolved_by"])

        if dispute.raised_by_id:
            create_and_send(
                user=dispute.raised_by,
                category=NotificationCategory.DISPUTE,
                title="Your dispute was resolved",
                body="An admin has resolved your dispute.",
            )
        return Response(DisputeSerializer(dispute).data)


class AdminPayoutListView(generics.ListAPIView):
    """GET /admin/payouts"""

    queryset = Payout.objects.select_related("provider").prefetch_related("items")
    serializer_class = PayoutSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    filterset_fields = ["status", "provider", "is_manual"]


class AdminPayoutTriggerView(APIView):
    """POST /admin/payouts/{provider_id}/trigger — manual/off-cycle batch
    scoped to one provider (§5.5's Admin "Rapid Moderation" path)."""

    permission_classes = [permissions.IsAuthenticated, IsAdmin]

    def post(self, request, provider_id):
        payouts = run_batch(is_manual=True, provider_id=provider_id)
        if not payouts:
            return Response(
                {"detail": "No unpaid completed requests for this provider."},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(PayoutSerializer(payouts, many=True).data, status=status.HTTP_201_CREATED)


class AdminAnalyticsView(APIView):
    """GET /admin/analytics"""

    permission_classes = [permissions.IsAuthenticated, IsAdmin]

    def get(self, request):
        revenue = (
            Payment.objects.filter(status=PaymentStatus.SUCCESSFUL).aggregate(total=Sum("amount"))[
                "total"
            ]
            or 0
        )
        orders_by_status = {
            row["status"]: row["count"]
            for row in Order.objects.values("status").annotate(count=Count("id"))
        }
        service_requests_by_status = {
            row["status"]: row["count"]
            for row in ServiceRequest.objects.values("status").annotate(count=Count("id"))
        }
        return Response(
            {
                "orders_by_status": orders_by_status,
                "service_requests_by_status": service_requests_by_status,
                "revenue": revenue,
                "active_providers": ProviderProfile.objects.filter(is_available=True).count(),
                "open_disputes": Dispute.objects.filter(status=DisputeStatus.OPEN).count(),
            }
        )


class AdminMapView(generics.ListAPIView):
    """GET /admin/map — live provider positions (PostGIS), for the web
    fleet map. Only providers with a known last position are meaningful
    here."""

    queryset = (
        ProviderProfile.objects.filter(current_location__isnull=False)
        .select_related("user")
        .order_by("-updated_at")
    )
    serializer_class = ProviderMapSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
