from django.db import transaction
from django.db.models import F
from django.shortcuts import get_object_or_404
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.permissions import IsAdmin

from .filters import SparePartFilter
from .models import SparePart, Vendor
from .serializers import (
    SparePartDetailSerializer,
    SparePartListSerializer,
    SparePartStockAdjustSerializer,
    VendorSerializer,
)


class SparePartListView(generics.ListAPIView):
    """GET /parts?make=&model=&year=&category="""

    queryset = SparePart.objects.select_related("vendor").all()
    serializer_class = SparePartListSerializer
    permission_classes = [permissions.AllowAny]
    filterset_class = SparePartFilter


class SparePartDetailView(generics.RetrieveAPIView):
    """GET /parts/{id}"""

    queryset = SparePart.objects.select_related("vendor").all()
    serializer_class = SparePartDetailSerializer
    permission_classes = [permissions.AllowAny]


class SparePartFacetsView(APIView):
    """GET /parts/facets?make= — distinct compatible_make/compatible_model
    values, for populating the storefront's compatibility-search dropdowns.
    Not in PLAN.md §4's literal endpoint list: added because the schema has
    no fixed vehicle make/model vocabulary table, so the "compatibility
    search" storefront feature (PLAN.md §1 role matrix) needs some way to
    know what values actually exist rather than guessing free-text."""

    permission_classes = [permissions.AllowAny]

    def get(self, request):
        makes = (
            SparePart.objects.exclude(compatible_make__isnull=True)
            .exclude(compatible_make="")
            .order_by("compatible_make")
            .values_list("compatible_make", flat=True)
            .distinct()
        )
        qs = SparePart.objects.exclude(compatible_model__isnull=True).exclude(compatible_model="")
        make = request.query_params.get("make")
        if make:
            qs = qs.filter(compatible_make__iexact=make)
        models_ = qs.order_by("compatible_model").values_list("compatible_model", flat=True).distinct()
        return Response({"makes": list(makes), "models": list(models_)})


class AdminVendorListCreateView(generics.ListCreateAPIView):
    """GET/POST /admin/vendors"""

    queryset = Vendor.objects.all()
    serializer_class = VendorSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]


class AdminVendorDetailView(generics.RetrieveUpdateAPIView):
    """GET/PATCH /admin/vendors/{id}. No DELETE: vendors deactivate
    (`is_active=False`) rather than hard-delete, since `spare_parts.vendor`
    is SET_NULL on vendor deletion and orphaning live parts silently would
    be worse than requiring an explicit deactivation."""

    queryset = Vendor.objects.all()
    serializer_class = VendorSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]


class AdminSparePartStockAdjustView(APIView):
    """PATCH /admin/parts/{id}/stock — body: {"adjustment": <signed int>}"""

    permission_classes = [permissions.IsAuthenticated, IsAdmin]

    def patch(self, request, pk):
        with transaction.atomic():
            part = get_object_or_404(SparePart.objects.select_for_update(), pk=pk)
            serializer = SparePartStockAdjustSerializer(
                data=request.data, context={"spare_part": part}
            )
            serializer.is_valid(raise_exception=True)
            adjustment = serializer.validated_data["adjustment"]
            part.stock_quantity = F("stock_quantity") + adjustment
            part.save(update_fields=["stock_quantity"])
            part.refresh_from_db()
        return Response(SparePartDetailSerializer(part).data, status=status.HTTP_200_OK)
