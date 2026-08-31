# Phase 0 Research: Recovery & Towing Web Portal

No `NEEDS CLARIFICATION` markers remained in Technical Context — every
item was resolvable directly from the running codebase (`web/`,
`backend/`), since this feature is mostly a frontend build onto
already-implemented backend capability, with one small justified backend
addition (spec.md Clarifications). This document records the
reuse-vs-new decisions made while filling in the plan, so
`/speckit-tasks` and `/speckit-implement` don't re-derive them.

## Decision: Route/layout gating pattern

- **Decision**: `web/src/app/recovery/layout.tsx` follows the exact
  shape of `web/src/app/mechanic/layout.tsx` (itself following
  `admin/layout.tsx`) — a Server Component calling `getSession()`,
  redirecting to `/login?next=...` if absent, `/` if `role !== "RECOVERY"`,
  plus a `GET /users/me` check for `is_verified` (FR-001).
- **Rationale**: Identical shape to the already-shipped mechanic portal;
  `is_verified` isn't in the JWT (`CustomTokenObtainPairSerializer` only
  embeds `role`/`full_name`), so it's read the same way — one extra
  server-side `apiFetch` call, no backend change.
- **Alternatives considered**: none beyond what 001-mechanic-web-portal
  already evaluated and settled — no reason to re-litigate an identical
  gating need.

## Decision: Multi-tow dispatch view is `GET /service-requests` filtered client-side, not a new endpoint

- **Decision**: `web/src/app/recovery/page.tsx` calls the existing
  `GET /service-requests` (no `status` filter, or a client-side filter
  over the response) and renders every row with
  `status in {ACCEPTED, EN_ROUTE, IN_PROGRESS}` as an active job — both
  on the map (`ActiveTowMap.tsx`) and in a list (`ActiveJobList.tsx`).
- **Rationale**: `ServiceRequestListCreateView.get()` already scopes the
  `RECOVERY` role to `Q(service_type=RECOVERY, status=PENDING) |
  Q(provider=user)` (`backend/apps/dispatch/views.py`) — i.e. every open
  recovery job plus every job this operator is or was assigned to,
  already correctly scoped per FR-009. Nothing in `ServiceRequestAcceptView`
  prevents one operator holding several simultaneously-`ACCEPTED`/
  `EN_ROUTE`/`IN_PROGRESS` jobs, so "multi-tow" is a real, reachable state
  today, not something the backend needs to newly support.
- **Alternatives considered**: A new `/recovery/dashboard` aggregate
  endpoint was considered and rejected — it would duplicate filtering
  logic `ServiceRequestListCreateView` already implements correctly, the
  same conclusion 001-mechanic-web-portal reached for its own dashboard.

## Decision: Live position reuses the existing per-job tracking WebSocket and `admin/map`'s marker pattern

- **Decision**: For each active job rendered, `ActiveTowMap.tsx` opens
  (or reuses, if already open for that job) a
  `ws://.../tracking/{service_request_id}/` connection — the exact
  connection `web/src/app/track/[serviceRequestId]/page.tsx` already
  opens for a single job — and plots one Leaflet marker per job from its
  `location_update` events, following the multi-marker layout
  `web/src/components/admin/FleetMap.tsx` already uses for `GET
  /admin/map` (there, one marker per provider; here, one marker per
  active job — the provider's own vehicle may back more than one
  concurrently-accepted job, which is fine: shared jobs simply share a
  position until their own `location_update` diverges, since positions
  are published by the connected provider socket, not looked up
  per-job).
- **Rationale**: `apps.tracking.consumers.TrackingConsumer` is already
  the single source of live position for this exact
  `service_request_id` shape; the constitution's own Reuse Map names
  this pairing explicitly ("Recovery/Towing web portal: `/service-requests`
  + the tracking WebSocket ... + the PostGIS live-position pattern
  already built for `web/src/app/admin/map`"). Building a second
  position channel would fork a source of truth that already exists.
- **Alternatives considered**: Polling `GET /providers/me/location`-style
  data was rejected for the same reason 001-mechanic-web-portal rejected
  polling for status — it duplicates real-time infra the constitution
  already commits to (Principle I, Django Channels) instead of reusing
  the one connection each job already supports.
- **Staleness (edge case)**: no new field is needed — `ProviderProfile
  .updated_at` (`auto_now=True`) already changes whenever the assigned
  provider's location is written. The portal treats "no `location_update`
  event received in > N seconds since connect, and no
  `ProviderProfile.updated_at` change" as stale and shows an explicit
  indicator rather than a silently-frozen marker — a client-side timer,
  no backend change. This is the same imprecision `admin/map` already
  lives with (`updated_at` also ticks on unrelated `ProviderProfile`
  saves, e.g. an availability toggle) — not solved here, not a
  regression introduced by this feature.

## Decision: Fare estimate is a pure read of already-computed fields, not a new "estimator" endpoint

- **Decision**: `FareEstimateCard.tsx` on the job detail page
  (`web/src/app/recovery/jobs/[id]/page.tsx`) reads `estimated_fare` (and,
  once `COMPLETED`, `final_fare` alongside it) straight off the existing
  `GET /service-requests/{id}` response.
- **Rationale**: `apps.dispatch.services.fare.estimate_fare()` already
  computes `estimated_fare` at request-creation time
  (`ServiceRequestCreateSerializer`/`build_service_request`) using
  OSRM-with-Haversine-fallback, satisfying the edge case ("poor
  road-network data" → still returns an estimate, never fails) without
  this feature touching the fare engine at all. `_get_visible_service_request`
  already allows a same-type provider to `GET` a still-`PENDING` request
  before accepting it, so "estimate before committing" (FR-005) needs no
  new visibility rule either. `final_fare` is set (equal to the locked-in
  estimate) on the `COMPLETED` transition, already satisfying FR-006's
  "both visible together" — trivially equal today, but the field-level
  contract is already there if the fare engine's `COMPLETED`-time
  behavior ever changes.
- **Alternatives considered**: A dedicated `POST /fare-estimates` taking
  an arbitrary pickup/dropoff pair (for estimating *before* a request
  even exists) was considered — the spec's Story 2 language
  ("before accepting") could be read either way. Rejected: every
  Acceptance Scenario and FR-005 both frame this as viewing an
  **existing pending request's** estimate before the operator commits to
  it (accepting), not a free-standing calculator over arbitrary
  coordinates a customer hasn't requested yet — that calculator, if ever
  needed, belongs to the request-creation flow (`apps/dispatch`'s
  existing `POST /service-requests`), not this portal.

## Decision: Driver performance is one new self-scoped, period-filterable endpoint

- **Decision**: see spec.md Clarifications and contracts/rest.md — one
  new `GET /providers/me/performance` view in `apps/dispatch` (co-located
  with `ServiceRequest`/`Review`, not `apps/providers` or `apps/admin_ops`),
  plus two new nullable `ServiceRequest` columns (`accepted_at`,
  `completed_at`).
- **Rationale**: fully justified in spec.md's Clarifications — no
  existing endpoint is both self-scoped and period-filterable, and no
  existing column records accept/complete timestamps to derive response
  time from.
- **Alternatives considered**: A generic `ServiceRequestStatusHistory`
  table (logging every transition with a timestamp) was considered —
  more general, but rejected as over-scoped for this feature: nothing in
  spec.md asks for a full transition audit trail, only the two specific
  instants (accept, complete) FR-007 needs. Two columns on the existing
  row is the smaller change, consistent with Constitution Principle III's
  "reuse before new" bias applying equally to *how big* a justified
  addition should be, not just *whether* one is added.
- **"Driver" selection**: per spec.md's Assumptions ("the portal must
  support the single-operator case at minimum; multi-driver coordination
  ... is not separately specified here beyond the performance view"),
  and because no fleet/organization model linking multiple
  `ProviderProfile` rows under one coordinating account exists in the
  schema, `GET /providers/me/performance` is strictly self-scoped
  (`provider=request.user`) — there is no `?driver=` param. A
  coordinating account viewing other drivers' performance is out of
  scope for this feature (would need a fleet-membership model this spec
  doesn't introduce, per the Assumption's own boundary).

## Decision: No new WebSocket event type

- **Decision**: This feature adds zero new Channels event types. It
  reuses `location.update` and the already-shipped `status.update`
  (001-mechanic-web-portal) unchanged.
- **Rationale**: FR-010 ("status changes from the portal reach the
  customer's tracking view live") is already satisfied by
  `_broadcast_status_update()` (`apps/dispatch/views.py`), which fires on
  every `ServiceRequestAcceptView`/`ServiceRequestStatusUpdateView`
  success regardless of the caller's role — a `RECOVERY` operator's
  status change already broadcasts exactly like a `MECHANIC`'s.
- **Alternatives considered**: none needed — the existing mechanism is
  role-agnostic by construction.
