from django.urls import path

from .views import ProviderAvailabilityView, ProviderDocumentListCreateView, ProviderLocationView

urlpatterns = [
    path("providers/me/availability", ProviderAvailabilityView.as_view(), name="provider-availability"),
    path("providers/me/location", ProviderLocationView.as_view(), name="provider-location"),
    path("providers/me/documents", ProviderDocumentListCreateView.as_view(), name="provider-documents"),
]
