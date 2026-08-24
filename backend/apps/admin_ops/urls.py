from django.urls import path

from .views import (
    AdminAnalyticsView,
    AdminDisputeListView,
    AdminDisputeResolveView,
    AdminMapView,
    AdminPayoutListView,
    AdminPayoutTriggerView,
    ServiceRequestDisputeCreateView,
)

urlpatterns = [
    path(
        "service-requests/<uuid:sr_pk>/disputes",
        ServiceRequestDisputeCreateView.as_view(),
        name="service-requests-disputes-create",
    ),
    path("admin/disputes", AdminDisputeListView.as_view(), name="admin-disputes-list"),
    path(
        "admin/disputes/<uuid:pk>/resolve",
        AdminDisputeResolveView.as_view(),
        name="admin-disputes-resolve",
    ),
    path("admin/payouts", AdminPayoutListView.as_view(), name="admin-payouts-list"),
    path(
        "admin/payouts/<uuid:provider_id>/trigger",
        AdminPayoutTriggerView.as_view(),
        name="admin-payouts-trigger",
    ),
    path("admin/analytics", AdminAnalyticsView.as_view(), name="admin-analytics"),
    path("admin/map", AdminMapView.as_view(), name="admin-map"),
]
