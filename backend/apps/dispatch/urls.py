from django.urls import path

from .views import (
    PartsSourcingRequestApproveView,
    PartsSourcingRequestListCreateView,
    PartsSourcingRequestOrderView,
    ServiceRequestAcceptView,
    ServiceRequestDetailView,
    ServiceRequestListCreateView,
    ServiceRequestStatusUpdateView,
)

urlpatterns = [
    path("service-requests", ServiceRequestListCreateView.as_view(), name="service-requests-list-create"),
    path("service-requests/<uuid:pk>", ServiceRequestDetailView.as_view(), name="service-requests-detail"),
    path(
        "service-requests/<uuid:pk>/accept",
        ServiceRequestAcceptView.as_view(),
        name="service-requests-accept",
    ),
    path(
        "service-requests/<uuid:pk>/status",
        ServiceRequestStatusUpdateView.as_view(),
        name="service-requests-status",
    ),
    path(
        "service-requests/<uuid:sr_pk>/parts-requests",
        PartsSourcingRequestListCreateView.as_view(),
        name="parts-requests-list-create",
    ),
    path(
        "parts-requests/<uuid:pk>/approve",
        PartsSourcingRequestApproveView.as_view(),
        name="parts-requests-approve",
    ),
    path(
        "parts-requests/<uuid:pk>/order",
        PartsSourcingRequestOrderView.as_view(),
        name="parts-requests-order",
    ),
]
