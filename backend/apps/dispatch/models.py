from django.conf import settings
from django.contrib.gis.db import models as gis_models
from django.db import models

from apps.catalog.models import SparePart
from apps.common.models import UUIDModel


class ServiceType(models.TextChoices):
    MECHANIC = "MECHANIC", "Mechanic"
    RECOVERY = "RECOVERY", "Recovery"


class ServiceStatus(models.TextChoices):
    PENDING = "PENDING", "Pending"
    ACCEPTED = "ACCEPTED", "Accepted"
    EN_ROUTE = "EN_ROUTE", "En Route"
    IN_PROGRESS = "IN_PROGRESS", "In Progress"
    COMPLETED = "COMPLETED", "Completed"
    CANCELLED = "CANCELLED", "Cancelled"


class ServiceRequest(UUIDModel):
    """Matches PLAN.md §3.1's `service_requests` table. `estimated_fare`/
    `final_fare` are left null this phase — the OSRM/Haversine fare engine
    is Phase 4 (PLAN.md §5.2); this phase only carries the request
    lifecycle through accept/status-update."""

    customer = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="service_requests"
    )
    provider = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="assigned_service_requests",
    )
    service_type = models.CharField(max_length=20, choices=ServiceType.choices)
    status = models.CharField(
        max_length=20, choices=ServiceStatus.choices, default=ServiceStatus.PENDING
    )
    pickup_location = gis_models.PointField(srid=4326)
    # Mandatory for RECOVERY, enforced at the serializer level (a plain DB
    # nullable column can't conditionally require itself on a sibling
    # field's value).
    dropoff_location = gis_models.PointField(srid=4326, null=True, blank=True)
    problem_description = models.TextField(null=True, blank=True)
    estimated_fare = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    final_fare = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "service_requests"
        ordering = ["-created_at"]

    def __str__(self):
        return f"ServiceRequest<{self.id}, {self.service_type}, {self.status}>"


class PartsSourcingStatus(models.TextChoices):
    PENDING = "PENDING", "Pending"
    APPROVED = "APPROVED", "Approved"
    REJECTED = "REJECTED", "Rejected"
    ORDERED = "ORDERED", "Ordered"


class PartsSourcingRequest(UUIDModel):
    """Matches PLAN.md §3.2's `parts_sourcing_requests` table. Lives in
    `apps.dispatch`, not `apps.orders` — the FK anchor is
    `service_request_id CASCADE`, and `apps.orders` must not import
    `apps.dispatch` (wrong dependency direction; `orders` was built first,
    in Phase 2)."""

    service_request = models.ForeignKey(
        ServiceRequest, on_delete=models.CASCADE, related_name="parts_sourcing_requests"
    )
    requested_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="parts_sourcing_requests",
    )
    spare_part = models.ForeignKey(SparePart, on_delete=models.SET_NULL, null=True, blank=True)
    quantity = models.PositiveIntegerField(default=1)
    status = models.CharField(
        max_length=20, choices=PartsSourcingStatus.choices, default=PartsSourcingStatus.PENDING
    )
    # `apps.orders.Order`, set once the customer converts an APPROVED
    # request into a real order (services/parts_sourcing.py).
    order = models.ForeignKey(
        "orders.Order", on_delete=models.SET_NULL, null=True, blank=True, related_name="+"
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "parts_sourcing_requests"
        ordering = ["-created_at"]

    def __str__(self):
        return f"PartsSourcingRequest<{self.id}, {self.status}>"
