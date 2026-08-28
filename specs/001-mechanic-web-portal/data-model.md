# Phase 1 Data Model: Mechanic Web Portal

Every entity below already exists as a Django model backing an existing
endpoint; this feature adds **zero new tables and zero migrations**. Each
entry maps the spec's "Key Entities" (spec.md) to its real model/table
and states exactly what's new (a field-level projection, if anything).

## Mechanic profile

- **Backing model**: `apps.users.User` (role, `is_verified`) +
  `apps.providers.ProviderProfile` (one-to-one, `is_available`, `rating`,
  `vehicle_plate`, `service_radius_km`, `current_location`).
- **Fields surfaced to the portal**: `role`, `full_name`, `email` (from
  session/JWT), `is_verified` (from `GET /users/me`), `is_available`
  (from `PATCH /providers/me/availability`, which also returns the
  current value).
- **New fields**: none.
- **Validation**: `is_verified` gates all portal content (FR-001) —
  enforced in `web/src/app/mechanic/layout.tsx`, mirroring the existing
  `apps.common.permissions.IsMechanic` enforcement the backend already
  applies per-endpoint.
- **State**: `is_available` is a simple boolean toggle, no transition
  rules beyond on/off.

## Job (service request)

- **Backing model**: `apps.dispatch.ServiceRequest`.
- **Fields surfaced**: `id`, `customer` (name/phone), `provider`,
  `service_type`, `status`, `pickup_location`, `dropoff_location`,
  `problem_description`, `estimated_fare`, `final_fare`, `created_at` —
  all already in `ServiceRequestSerializer`, unchanged.
- **New fields**: none.
- **State machine** (unchanged, `apps/dispatch/services/transitions.py`):
  `PENDING → ACCEPTED` (only via `/accept`, race-safe conditional
  update) → `EN_ROUTE → IN_PROGRESS → COMPLETED`, with `CANCELLED`
  reachable from every non-terminal state. The portal drives
  `EN_ROUTE`/`IN_PROGRESS`/`COMPLETED` (role-gated to `MECHANIC`/
  `RECOVERY` in `_ROLES_BY_TARGET`) and the initial `/accept`.
- **New side effect** (this feature's one behavioral addition, not a
  schema change): on a successful `/accept` or status `PATCH`, the view
  also emits a `status.update` event to the `tracking_{id}` Channels
  group (see contracts/websocket.md) — additive, does not change what's
  persisted.

## Job history entry

- **Backing model**: same `ServiceRequest` rows, `status=COMPLETED`,
  read via `GET /service-requests?status=COMPLETED` (scoped to
  `provider=request.user` for the `MECHANIC` role — see research.md).
  Not a separate table or read model.
- **New fields**: none.

## Payout

- **Backing model**: `apps.admin_ops.Payout` (+ `PayoutItem`, one row
  per contributing `service_request`).
- **Fields surfaced**: `id`, `amount`, `period_start`, `period_end`,
  `is_manual`, `provider_gateway`, `gateway_transaction_id`, `status`
  (`PENDING`/`PROCESSING`/`PAID`/`FAILED`), `created_at`, `paid_at`,
  `items[].service_request`, `items[].amount` — all via the existing
  `PayoutSerializer`, unchanged.
- **New fields**: none. **New access path**: `GET /providers/me/payouts`
  (new view, existing serializer/model — see contracts/rest.md and
  spec.md Clarifications).
- **Validation**: filtered to `provider=request.user` at the queryset
  level (FR-011) — a mechanic can never pass another provider's id.

## Certification document

- **Backing model**: `apps.providers.ProviderDocument`.
- **Fields surfaced**: `id`, `doc_type`, `file_url`, `verified`,
  `uploaded_at` — via existing `ProviderDocumentSerializer`, unchanged.
- **New fields**: none.
- **State**: `verified` is a plain boolean set only by a Django admin
  today (per spec.md's Assumptions — verification happens elsewhere);
  the portal only uploads (`POST`) and lists (`GET`)
  `/providers/me/documents`, both already `provider=request.user`-scoped.
- **Failure/retry** (edge case): a failed upload is a client-side
  concern — the form resets to let the mechanic retry `POST` with the
  same file; the backend doesn't create a partial `ProviderDocument` row
  on a failed multipart request, so no cleanup/dedup logic is needed.

## Parts-sourcing request

- **Backing model**: `apps.dispatch.PartsSourcingRequest`.
- **Fields surfaced**: `id`, `service_request`, `requested_by`,
  `spare_part`, `quantity`, `status`
  (`PENDING`/`APPROVED`/`REJECTED`/`ORDERED`), `created_at` — via
  existing `PartsSourcingRequestSerializer`, unchanged.
- **New fields**: none.
- **Validation** (already enforced server-side, reused as-is):
  `POST /service-requests/{id}/parts-requests` requires the requester be
  the assigned provider and the request be `service_type=MECHANIC`
  (`PartsSourcingRequestListCreateView.post()`). The portal additionally
  disables the request form once the parent job's `status` is
  `COMPLETED`/`CANCELLED` (FR-010's "prevent submitting against an
  inactive job") — a UI-only guard layered on top of, not replacing, the
  existing server checks.
- **State**: `PENDING → APPROVED|REJECTED` (customer-driven, elsewhere)
  `→ ORDERED` (customer converts to an `Order` via
  `POST /parts-requests/{id}/order`) — the mechanic portal only ever
  reads this state via `GET /service-requests/{id}/parts-requests`, it
  never transitions it.

## Relationships (unchanged)

```text
User(role=MECHANIC) 1───1 ProviderProfile
ProviderProfile 1───N ProviderDocument
User(MECHANIC, as provider) 1───N ServiceRequest
ServiceRequest 1───N PartsSourcingRequest
ServiceRequest N───1 Payout (via PayoutItem)
User(MECHANIC, as provider) 1───N Payout
```
