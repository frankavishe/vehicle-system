"""Dispatch-specific trigger only (who to notify) — generic send
mechanics live in `apps.notifications` (mirrors the
`apps.orders`/`apps.orders.gateways` split: routing decision here,
delivery plumbing there)."""

from celery import shared_task

from apps.notifications.models import NotificationCategory
from apps.notifications.services.create import create_and_send

from .models import ServiceRequest, ServiceType
from .services.matching import match_providers


@shared_task
def fan_out_job_alert(service_request_id: str):
    try:
        sr = ServiceRequest.objects.get(pk=service_request_id)
    except ServiceRequest.DoesNotExist:
        return

    category = (
        NotificationCategory.JOB_ALERT
        if sr.service_type == ServiceType.MECHANIC
        else NotificationCategory.DISPATCH
    )
    matched = match_providers(sr.pickup_location, sr.service_type)

    for profile in matched:
        create_and_send(
            user=profile.user,
            category=category,
            title="New job nearby" if sr.service_type == ServiceType.MECHANIC else "New towing request nearby",
            body=sr.problem_description or f"A customer needs {sr.service_type.lower()} assistance nearby.",
        )
