from django.urls import path

from .views import (
    AdminSparePartStockAdjustView,
    AdminVendorDetailView,
    AdminVendorListCreateView,
    SparePartDetailView,
    SparePartFacetsView,
    SparePartListView,
)

urlpatterns = [
    path("parts", SparePartListView.as_view(), name="parts-list"),
    path("parts/facets", SparePartFacetsView.as_view(), name="parts-facets"),
    path("parts/<uuid:pk>", SparePartDetailView.as_view(), name="parts-detail"),
    path("admin/vendors", AdminVendorListCreateView.as_view(), name="admin-vendors-list"),
    path("admin/vendors/<uuid:pk>", AdminVendorDetailView.as_view(), name="admin-vendors-detail"),
    path(
        "admin/parts/<uuid:pk>/stock",
        AdminSparePartStockAdjustView.as_view(),
        name="admin-parts-stock",
    ),
]
