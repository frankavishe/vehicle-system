from django.db import models as django_models
from django.http import Http404
from django.shortcuts import get_object_or_404
from rest_framework import permissions, status
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.permissions import IsCustomer, IsMechanic, IsProvider
from apps.providers.models import ProviderProfile

from .models import PartsSourcingRequest, PartsSourcingStatus, ServiceRequest, ServiceStatus, ServiceType
from .serializers import (
    PartsSourcingRequestApproveSerializer,
    PartsSourcingRequestCreateSerializer,
    PartsSourcingRequestOrderSerializer,
    PartsSourcingRequestSerializer,
    ServiceRequestCreateSerializer,
    ServiceRequestSerializer,
    ServiceRequestStatusUpdateSerializer,
    build_service_request,
)
from .services.parts_sourcing import convert_to_order
from .services.transitions import is_transition_allowed, role_may_transition


class ServiceRequestListCreateView(APIView):
    """POST /service-requests (IsCustomer), GET /service-requests. Not in
    PLAN.md §4's literal list — flagged addition, needed for job-list/
    history screens (mirrors Phase 2's OrderListCreateView precedent)."""

    # GET is used by all four roles (customer history, provider job list,
    # admin oversight); POST is customer-only — split per-method rather
    # than a single class-wide permission list.
    def get_permissions(self):
        if self.request.method == "POST":
            return [permissions.IsAuthenticated(), IsCustomer()]
        return [permissions.IsAuthenticated()]

    def get(self, request):
        user = request.user
        qs = ServiceRequest.objects.select_related("customer", "provider")

        if user.role == "CUSTOMER":
            qs = qs.filter(customer=user)
        elif user.role in ("MECHANIC", "RECOVERY"):
            service_type = ServiceType.MECHANIC if user.role == "MECHANIC" else ServiceType.RECOVERY
            qs = qs.filter(
                django_models.Q(service_type=service_type, status=ServiceStatus.PENDING)
                | django_models.Q(provider=user)
            )
        # ADMIN: unfiltered.

        status_param = request.query_params.get("status")
        if status_param:
            qs = qs.filter(status=status_param)

        return Response(ServiceRequestSerializer(qs, many=True).data)

    def post(self, request):
        serializer = ServiceRequestCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        service_request = build_service_request(
            customer=request.user, validated_data=serializer.validated_data
        )

        from .tasks import fan_out_job_alert

        fan_out_job_alert.delay(str(service_request.id))

        return Response(
            ServiceRequestSerializer(service_request).data, status=status.HTTP_201_CREATED
        )


def _get_visible_service_request(request, pk):
    sr = get_object_or_404(ServiceRequest, pk=pk)
    user = request.user
    visible = (
        user.role == "ADMIN"
        or sr.customer_id == user.id
        or sr.provider_id == user.id
        or (user.role in ("MECHANIC", "RECOVERY") and sr.status == ServiceStatus.PENDING)
    )
    if not visible:
        raise Http404
    return sr


class ServiceRequestDetailView(APIView):
    """GET /service-requests/{id} — owner, assigned provider, a same-type
    provider while still PENDING (so they can view before accepting), or
    admin. 404, not 403, for anyone else."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        sr = _get_visible_service_request(request, pk)
        return Response(ServiceRequestSerializer(sr).data)


class ServiceRequestAcceptView(APIView):
    """POST /service-requests/{id}/accept — IsProvider. Race-safe: a single
    atomic conditional UPDATE (`WHERE status=PENDING`), not
    select_for_update() — there's no multi-row invariant here, just one
    row's flip, so the cheaper conditional-update pattern is enough.
    0-row update means someone else already accepted -> 409.

    Known, deliberately-accepted gap: doesn't re-verify the accepting
    provider was actually inside the matched radius at accept time (only
    role/availability) — flagged, not silently glossed over.
    """

    permission_classes = [permissions.IsAuthenticated, IsProvider]

    def post(self, request, pk):
        sr = get_object_or_404(ServiceRequest, pk=pk)
        user = request.user

        expected_role = ServiceType.MECHANIC if sr.service_type == ServiceType.MECHANIC else ServiceType.RECOVERY
        if user.role != expected_role:
            raise ValidationError(f"Only a {expected_role} provider may accept this request.")

        profile = get_object_or_404(ProviderProfile, user=user)
        if not profile.is_available:
            raise ValidationError("You must be marked available to accept a job.")

        updated = ServiceRequest.objects.filter(pk=sr.pk, status=ServiceStatus.PENDING).update(
            provider=user, status=ServiceStatus.ACCEPTED
        )
        if updated == 0:
            return Response(
                {"detail": "This request was already accepted by another provider."},
                status=status.HTTP_409_CONFLICT,
            )

        sr.refresh_from_db()

        from apps.notifications.models import NotificationCategory
        from apps.notifications.services.create import create_and_send

        create_and_send(
            user=sr.customer,
            category=NotificationCategory.GENERAL,
            title="Your request was accepted",
            body=f"{user.full_name} accepted your {sr.service_type.lower()} request.",
        )

        return Response(ServiceRequestSerializer(sr).data)


class ServiceRequestStatusUpdateView(APIView):
    """PATCH /service-requests/{id}/status — validated against
    ALLOWED_TRANSITIONS + the role map. ACCEPTED is unreachable here by
    design (services/transitions.py)."""

    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        sr = get_object_or_404(ServiceRequest, pk=pk)
        user = request.user
        is_party = user.role == "ADMIN" or sr.customer_id == user.id or sr.provider_id == user.id
        if not is_party:
            raise Http404

        serializer = ServiceRequestStatusUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        target = serializer.validated_data["status"]

        if not is_transition_allowed(sr.status, target):
            raise ValidationError(f"Cannot transition from {sr.status} to {target}.")
        if not role_may_transition(user.role, target):
            raise ValidationError(f"Your role may not set status to {target}.")

        sr.status = target
        sr.save(update_fields=["status"])
        return Response(ServiceRequestSerializer(sr).data)


class PartsSourcingRequestListCreateView(APIView):
    """POST /service-requests/{id}/parts-requests — IsMechanic, must be the
    assigned provider, MECHANIC service_type only (not Recovery, per §1's
    role matrix). GET (flagged addition) — visible to the assigned
    mechanic + the owning customer."""

    def get_permissions(self):
        if self.request.method == "POST":
            return [permissions.IsAuthenticated(), IsMechanic()]
        return [permissions.IsAuthenticated()]

    def get(self, request, sr_pk):
        sr = get_object_or_404(ServiceRequest, pk=sr_pk)
        user = request.user
        visible = user.role == "ADMIN" or sr.customer_id == user.id or sr.provider_id == user.id
        if not visible:
            raise Http404
        qs = PartsSourcingRequest.objects.filter(service_request=sr)
        return Response(PartsSourcingRequestSerializer(qs, many=True).data)

    def post(self, request, sr_pk):
        sr = get_object_or_404(ServiceRequest, pk=sr_pk)
        if sr.provider_id != request.user.id:
            raise ValidationError("You are not the assigned provider for this request.")
        if sr.service_type != ServiceType.MECHANIC:
            raise ValidationError("Parts sourcing only applies to MECHANIC requests.")

        serializer = PartsSourcingRequestCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        psr = PartsSourcingRequest.objects.create(
            service_request=sr,
            requested_by=request.user,
            spare_part_id=serializer.validated_data["spare_part_id"],
            quantity=serializer.validated_data["quantity"],
        )
        return Response(PartsSourcingRequestSerializer(psr).data, status=status.HTTP_201_CREATED)


def _get_owned_parts_request(request, pk):
    psr = get_object_or_404(PartsSourcingRequest, pk=pk)
    if psr.service_request.customer_id != request.user.id:
        raise Http404
    return psr


class PartsSourcingRequestApproveView(APIView):
    """PATCH /parts-requests/{id}/approve — {"approved": bool}. IsCustomer
    + ownership, PENDING-only guard."""

    permission_classes = [permissions.IsAuthenticated, IsCustomer]

    def patch(self, request, pk):
        psr = _get_owned_parts_request(request, pk)
        if psr.status != PartsSourcingStatus.PENDING:
            raise ValidationError("Only a PENDING request can be approved/rejected.")

        serializer = PartsSourcingRequestApproveSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        psr.status = (
            PartsSourcingStatus.APPROVED
            if serializer.validated_data["approved"]
            else PartsSourcingStatus.REJECTED
        )
        psr.save(update_fields=["status"])
        return Response(PartsSourcingRequestSerializer(psr).data)


class PartsSourcingRequestOrderView(APIView):
    """POST /parts-requests/{id}/order — converts to an Order via
    convert_to_order(); IsCustomer + ownership, APPROVED-only guard.
    Response includes order.id so the client chains straight into the
    existing, unmodified POST /orders/{id}/pay."""

    permission_classes = [permissions.IsAuthenticated, IsCustomer]

    def post(self, request, pk):
        psr = _get_owned_parts_request(request, pk)
        serializer = PartsSourcingRequestOrderSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        order = convert_to_order(
            psr, delivery_address=serializer.validated_data.get("delivery_address")
        )
        return Response(
            {"order_id": order.id, "parts_request": PartsSourcingRequestSerializer(psr).data},
            status=status.HTTP_201_CREATED,
        )
