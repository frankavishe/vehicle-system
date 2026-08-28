# Phase 1 Data Model: Recovery & Towing Web Portal

Most entities below already exist as Django models backing an existing
endpoint. This feature adds **one migration**: two nullable
`DateTimeField` columns on the existing `service_requests` table. Each
entry maps the spec's "Key Entities" (spec.md) to its real model/table
and states exactly what's new.

## Recovery operator profile

- **Backing model**: `apps.users.User` (role, `is_verified`) +
  `apps.providers.ProviderProfile` (one-to-one, `is_available`, `rating`,
  `vehicle_plate`, `service_radius_km`, `current_location`).
- **Fields surfaced to the portal**: `role`, `full_name`, `email` (from
  session/JWT), `is_verified` (from `GET /users/me`).
- **New fields**: none.
- **Validation**: `is_verified` gates all portal content (FR-001) —
  enforced in `web/src/app/recovery/layout.tsx`, mirroring
  `apps.common.permissions.IsRecovery` enforcement the backend already
  applies per-endpoint.
- **"Fleet" scope** (per spec.md Assumptions): this feature treats
  "fleet" as the single coordinating account's own jobs
  (`provider=request.user`) — there is no separate fleet/organization
  model linking multiple `ProviderProfile` rows. See research.md's
  "driver selection" decision.

## Tow job (service request)

- **Backing model**: `apps.dispatch.ServiceRequest`.
- **Fields surfaced**: `id`, `customer` (name/phone), `provider`,
  `service_type` (`RECOVERY`), `status`, `pickup_location`,
  `dropoff_location`, `problem_description`, `estimated_fare`,
  `final_fare`, `created_at` — all already in `ServiceRequestSerializer`.
- **New fields**:
  - `accepted_at` — `DateTimeField(null=True, blank=True)`. Set once, in
    `ServiceRequestAcceptView.post()`, in the same conditional-update
    branch that already flips `status` to `ACCEPTED` (added to that
    view's `.update(...)` call — no new write path, no new race
    condition beyond the one that call already resolves).
  - `completed_at` — `DateTimeField(null=True, blank=True)`. Set once, in
    `ServiceRequestStatusUpdateView.patch()`'s existing
    `if target == ServiceStatus.COMPLETED:` branch, alongside the
    existing `final_fare` assignment (added to that branch's
    `update_fields` list).
  - Both are write-once (a job is accepted once, completed once); no
    update path ever clears or re-sets them.
- **State machine** (unchanged, `apps/dispatch/services/transitions.py`):
  `PENDING → ACCEPTED → EN_ROUTE → IN_PROGRESS → COMPLETED`, `CANCELLED`
  reachable from every non-terminal state. This feature drives no new
  transitions — it only reads status/position (Story 1) and adds two
  timestamp writes alongside transitions that already happen (Story 3).

## Live position

- **Backing model**: `apps.providers.ProviderProfile.current_location`
  (PostGIS `Point`) + `.updated_at` (`auto_now=True`), written by
  `apps.tracking.consumers.TrackingConsumer.receive_json()` on every
  `location.update` the assigned provider's socket sends.
- **Fields surfaced**: `lat`/`lng` (from the live `location_update`
  WebSocket event, not a REST field — `current_location` is the
  persisted fallback used by `GET /admin/map`'s `ProviderMapSerializer`,
  reused here the same way for the portal's initial map render before
  any socket event arrives).
- **New fields**: none. **Staleness** is a client-side derived value
  (see research.md), not a new backend field.

## Fare estimate

- **Backing model**: `apps.dispatch.ServiceRequest.estimated_fare` /
  `.final_fare` — already computed by
  `apps.dispatch.services.fare.estimate_fare()` at request-creation time
  and already on `ServiceRequestSerializer`.
- **New fields**: none.
- **Visibility**: a same-`service_type` provider may `GET
  /service-requests/{id}` while it's still `PENDING`
  (`_get_visible_service_request`), which is exactly when FR-005 needs
  the estimate visible — reused unchanged.

## Driver performance record

- **Backing model**: computed, not stored — aggregated on read from
  `apps.dispatch.ServiceRequest` (count + `accepted_at`/`completed_at`
  for response time) and `apps.dispatch.Review` (rating), both filtered
  to `provider=request.user`, `service_type=RECOVERY`, and the requested
  period.
- **New fields**: none on any model (beyond the two `ServiceRequest`
  timestamp columns above, which back this computation).
- **New access path**: `GET /providers/me/performance` (new view — see
  contracts/rest.md and spec.md Clarifications).
- **Shape** (response, not a model):
  - `period_start`, `period_end` (echoed back)
  - `completed_count` — `ServiceRequest.objects.filter(status=COMPLETED,
    completed_at__range=period).count()`
  - `cancelled_count` — same filter, `status=CANCELLED`,
    `created_at__range=period` (a cancelled job has no `completed_at`) —
    exists specifically so FR-008's "cancelled ≠ completed, not a
    context-free zero" edge case is representable: `completed_count: 0,
    cancelled_count: 3` reads unambiguously.
  - `average_rating` — `Review.objects.filter(service_request__provider=
    request.user, service_request__service_type=RECOVERY,
    created_at__range=period).aggregate(Avg("rating"))`, `null` (not `0`)
    when no reviews exist in the period (FR-008).
  - `average_response_time_seconds` — average of
    `(accepted_at - created_at).total_seconds()` over completed jobs in
    the period whose `accepted_at` is set; `null` when no such jobs exist.
- **Validation**: filtered to `provider=request.user` at the queryset
  level (FR-009) — an operator can never pass another operator's id;
  there is no id parameter to pass.

## Relationships (unchanged except the two new columns)

```text
User(role=RECOVERY) 1───1 ProviderProfile
User(RECOVERY, as provider) 1───N ServiceRequest  (+ accepted_at, completed_at — new)
ServiceRequest 1───1 Review (optional, once COMPLETED)
```
