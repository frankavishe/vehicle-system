"""Service-request status state machine. `ACCEPTED` is deliberately absent
as a *target* of `ALLOWED_TRANSITIONS` from `PENDING` — it's reachable only
through the race-safe `ServiceRequestAcceptView` (an atomic conditional
UPDATE), never through the generic status PATCH, so a provider can't just
PATCH their way past the accept race-guard."""

from ..models import ServiceStatus

# status -> set of statuses it may move to via the generic PATCH endpoint.
ALLOWED_TRANSITIONS: dict[str, set[str]] = {
    # PENDING -> ACCEPTED is only reachable via /accept, but the customer
    # must still be able to back out of a still-unaccepted request.
    ServiceStatus.PENDING: {ServiceStatus.CANCELLED},
    ServiceStatus.ACCEPTED: {ServiceStatus.EN_ROUTE, ServiceStatus.CANCELLED},
    ServiceStatus.EN_ROUTE: {ServiceStatus.IN_PROGRESS, ServiceStatus.CANCELLED},
    ServiceStatus.IN_PROGRESS: {ServiceStatus.COMPLETED, ServiceStatus.CANCELLED},
    ServiceStatus.COMPLETED: set(),
    ServiceStatus.CANCELLED: set(),
}

# Which role(s) may drive a given *target* status via the generic PATCH.
# The customer can cancel at any still-open stage; the assigned provider
# drives the working stages forward.
_ROLES_BY_TARGET = {
    ServiceStatus.EN_ROUTE: {"MECHANIC", "RECOVERY"},
    ServiceStatus.IN_PROGRESS: {"MECHANIC", "RECOVERY"},
    ServiceStatus.COMPLETED: {"MECHANIC", "RECOVERY"},
    ServiceStatus.CANCELLED: {"CUSTOMER", "MECHANIC", "RECOVERY", "ADMIN"},
}


def is_transition_allowed(current_status: str, target_status: str) -> bool:
    return target_status in ALLOWED_TRANSITIONS.get(current_status, set())


def role_may_transition(role: str, target_status: str) -> bool:
    return role in _ROLES_BY_TARGET.get(target_status, set())
