from django.urls import path

from .views import (
    PartsSourcingRequestApproveView,
    PartsSourcingRequestListCreateView,
    PartsSourcingRequestOrderView,
    ProviderPerformanceView,
    ServiceRequestAcceptView,
    ServiceRequestDetailView,
    ServiceRequestListCreateView,
    ServiceRequestPayView,
    ServiceRequestReviewView,
    ServiceRequestStatusUpdateView,
)

urlpatterns = [
    path("service-requests", ServiceRequestListCreateView.as_view(), name="service-requests-list-create"),
    # Co-located here, not apps/providers or apps/admin_ops — reads
    # ServiceRequest+Review, mirrors where PartsSourcingRequest/Review
    # already live relative to their source table (plan.md).
    path("providers/me/performance", ProviderPerformanceView.as_view(), name="providers-me-performance"),
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
        "service-requests/<uuid:pk>/pay",
        ServiceRequestPayView.as_view(),
        name="service-requests-pay",
    ),
    path(
        "service-requests/<uuid:pk>/review",
        ServiceRequestReviewView.as_view(),
        name="service-requests-review",
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
