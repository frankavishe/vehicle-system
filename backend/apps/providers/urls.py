from django.urls import path

from .views import (
    ProviderAvailabilityView,
    ProviderDocumentListCreateView,
    ProviderLocationView,
    ProviderPayoutListView,
)

urlpatterns = [
    path("providers/me/availability", ProviderAvailabilityView.as_view(), name="provider-availability"),
    path("providers/me/location", ProviderLocationView.as_view(), name="provider-location"),
    path("providers/me/documents", ProviderDocumentListCreateView.as_view(), name="provider-documents"),
    path("providers/me/payouts", ProviderPayoutListView.as_view(), name="provider-payouts"),
]
