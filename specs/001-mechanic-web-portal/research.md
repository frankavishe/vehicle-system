# Phase 0 Research: Mechanic Web Portal

No `NEEDS CLARIFICATION` markers remained in Technical Context — every
item was resolvable directly from the running codebase (`web/`,
`backend/`) rather than requiring external research, since this feature
is a frontend build onto already-implemented backend capability. This
document instead records the reuse-vs-new decisions made while filling
in the plan, so `/speckit-tasks` and `/speckit-implement` don't
re-derive them.

## Decision: Route/layout gating pattern

- **Decision**: `web/src/app/mechanic/layout.tsx` follows the exact
  shape of `web/src/app/admin/layout.tsx` — a Server Component that
  calls `getSession()`, redirects to `/login?next=...` if absent, and
  redirects to `/` if the role doesn't match — but adds one more check
  `admin/layout.tsx` doesn't need: verification status. Admin accounts
  don't have an `is_verified` gate; mechanics do (FR-001).
- **Rationale**: `is_verified` is not in the JWT (`CustomTokenObtainPairSerializer`
  only embeds `role`/`full_name`), so it can't be read from
  `getSession()`/`SessionUser` alone. `GET /users/me`
  (`apps/users`, `MeSerializer`) already returns `is_verified` — one
  extra server-side `apiFetch` call in the layout, no backend change.
- **Alternatives considered**: Adding `is_verified` as a third JWT claim
  (mirroring `role`/`full_name`) was considered and rejected for this
  feature — it would touch shared auth code (`apps/users/serializers.py`)
  used by every role for a need that's local to one portal, and the
  existing `/users/me` call achieves the same gate with zero backend
  risk.

## Decision: Job list / queue / history all reuse `GET /service-requests`

- **Decision**: The dashboard's incoming/active job queue (Story 1) and
  the history list (Story 2) are both the same existing
  `GET /service-requests` endpoint, called with different
  `?status=` query params (e.g. no filter or `PENDING`/`ACCEPTED`/
  `EN_ROUTE`/`IN_PROGRESS` for the queue, `COMPLETED` for history) —
  two client-side views over one endpoint, not two endpoints.
- **Rationale**: `ServiceRequestListCreateView.get()` already scopes the
  `MECHANIC` role to `Q(service_type=MECHANIC, status=PENDING) |
  Q(provider=user)` — i.e., every open mechanic job plus every job this
  mechanic is or was assigned to, which is exactly the union the queue
  and history need, already correctly scoped per FR-011.
- **Alternatives considered**: A new `/mechanic/dashboard` aggregate
  endpoint was considered and rejected — it would duplicate filtering
  logic `ServiceRequestListCreateView` already implements correctly.

## Decision: Declining a job is a client-side dismissal only

- **Decision**: "Decline" (FR-004, edge case #1) does not call any
  backend endpoint. The frontend removes the job from the mechanic's own
  visible queue for the current session; no `declined_by` state is
  persisted.
- **Rationale**: No accept/decline-tracking field exists on
  `ServiceRequest` (only `status` + a single `provider` FK), and adding
  one is a schema change with no other consumer today — out of proportion
  to what the spec asks for. Because the query already re-offers every
  `PENDING` mechanic job to every mechanic on each load, a decline
  "expires" naturally on refresh, which already satisfies the edge case
  ("declined jobs go to another mechanic") without new state.
- **Alternatives considered**: A `POST /service-requests/{id}/decline`
  endpoint recording per-mechanic declines was considered and rejected —
  it's a real schema change (Constitution Principle III requires that go
  through spec Clarifications + amendment discussion, not get decided
  inside planning for a "nice to have" not required by any FR/SC).

## Decision: Earnings/payouts — new self-scoped endpoint

See spec.md Clarifications — `GET /providers/me/payouts`, reusing
`Payout`/`PayoutItem`/`PayoutSerializer` from `apps/admin_ops` unchanged,
new `IsMechanic`-gated, `provider=request.user`-filtered view in
`apps/providers/views.py` (same file, same self-scoping shape as
`ProviderDocumentListCreateView`). Optional `?period_start=&period_end=`
query params reuse Django's standard queryset `.filter()` — no new
aggregation service.

## Decision: Live status push — new WebSocket event type

See spec.md Clarifications — extend the existing `tracking_{id}`
Channels group with a `status.update` event, sent via
`async_to_sync(get_channel_layer().group_send)(...)` from
`ServiceRequestAcceptView.post()` and
`ServiceRequestStatusUpdateView.patch()` after the status write commits,
alongside the existing `location.update` handled by the same consumer.
The customer's tracking page (`web/src/app/track/[serviceRequestId]`)
already holds this socket open for position updates; it starts also
listening for `status.update` and updates the on-page
`ServiceRequestStatusBadge` without a refetch. The mechanic portal does
**not** need to open this socket itself — it drives status via the
existing REST `PATCH .../status`, same as the mobile app.

## Decision: Certification uploads and parts-sourcing — no changes

- **Decision**: `POST/GET /providers/me/documents` (uploads +
  verification status) and the `parts-requests` family under
  `/service-requests/{id}/parts-requests` are consumed exactly as they
  exist; no new fields, no new endpoints.
- **Rationale**: Confirmed by reading `apps/providers/views.py` and
  `apps/dispatch/views.py` — both already implement everything FR-008
  through FR-010 ask for, including the "prevent submitting against an
  inactive job" edge case (`sr.service_type != MECHANIC` /
  provider-ownership checks in `PartsSourcingRequestListCreateView.post()`;
  a job that's `COMPLETED`/`CANCELLED` is still the assigned provider's,
  so the frontend additionally disables the request form once
  `service_request.status` is terminal — a UI-only guard, not a new
  backend check, since the backend doesn't currently reject by status
  here and adding that check is out of scope for a portal-only feature).

## Addendum (found during `/speckit-implement`): `ProviderAvailabilityView` needed a GET

FR-002 ("view and toggle") needs to *read* current availability before
the dashboard renders a toggle; `ProviderAvailabilityView` was PATCH-only.
Fixed by adding a `get()` method to that same view (same file, same
serializer, same `IsProvider` gate) — not a new endpoint, completing an
existing one's HTTP methods, exactly the "flagged addition" precedent
`ProviderDocumentListCreateView`'s own GET already set. No Clarifications
entry needed (Principle III's gate is about new *surfaces*; this is the
narrower "existing endpoint was missing a verb" case), but recorded here
since it wasn't caught during planning.

## Note: Constitution's stated Next.js version is stale

The constitution (Principle I) says "Next.js 14 App Router"; the running
`web/package.json` pins `next: 16.3.1`, and `web/AGENTS.md` explicitly
warns this version has breaking API changes from training-data Next.js
and to consult `node_modules/next/dist/docs/` before writing route code.
This is a pre-existing documentation drift, not something this feature
introduces or needs to resolve — noted here so implementation doesn't
assume Next 14 App Router APIs.
