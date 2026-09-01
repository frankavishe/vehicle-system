# Phase 0 Research: Admin Mobile App

No `NEEDS CLARIFICATION` markers remain in the Technical Context — this
feature reuses an already-decided stack (Constitution I) and an
already-running backend (Constitution III's Reuse Map explicitly names
`apps.admin_ops` for this exact feature). The research below covers the
concrete decisions needed to turn the spec into a buildable plan, not
open technology choices.

## 1. Where does ADMIN currently live in the mobile app?

- **Decision**: Replace the existing `/admin` route's `AdminHomeScreen`
  stub (`mobile/lib/core/router/app_router.dart`) with a real nested
  route tree, following the exact pattern already used for
  `/mechanic`/`/recovery` (`ProviderShell` + nested `GoRoute`s for
  `jobs/:id`, `tracking/:id`).
- **Rationale**: `computeRedirect`/`homeForRole` already confine every
  authenticated user to paths under their own role's home — this is a
  hard constraint already in the router (see its docstring), not a new
  decision. `AdminHomeScreen`'s own comment ("profile only until Phase 4:
  apps.admin_ops") already flags this exact feature as the reason it's a
  stub.
- **Alternatives considered**: A single flat `/admin` screen with
  in-page tab state (no nested routes). Rejected: it would be the only
  role without deep-linkable sub-routes, and Story 1's push-notification
  companion (spec Assumptions) needs a stable route
  (`/admin/disputes/:id`) to deep-link into from a tapped notification —
  the same pattern `tracking/:id` already established.

## 2. Bottom-nav shell shape

- **Decision**: 4-tab `AdminShell` — Disputes, Oversight, Moderation,
  Profile — mirroring `ProviderShell`'s existing 4-destination
  `NavigationBar` pattern exactly (icon + label pairs).
- **Rationale**: One tab per prioritized user story (P1 Disputes, P2
  Oversight, P3 Moderation) plus the `Profile` tab every other shell
  already has (reuses the existing `ProfileScreen`, no new profile
  logic). `NotificationsScreen` (existing, reused by `ProviderShell`) is
  reachable from `Oversight`'s app bar rather than getting its own tab —
  admins primarily arrive at a dispute via a push tap (deep link), not by
  browsing a notification list, so a 5th tab would cost a permanent slot
  for a rarely-browsed screen.
- **Alternatives considered**: 5 tabs (adding `Notifications` to match
  `ProviderShell` 1:1). Rejected as a flagged simplification, not a hard
  requirement — noted here so it's an easy follow-up if real usage shows
  admins do browse notifications directly.

## 3. Dispute detail data — job/complainant readability (FR-002)

- **Decision**: Extend the existing, shared `DisputeSerializer`
  (`apps/admin_ops/serializers.py`) with four new read-only fields
  (`service_request_summary`, `raised_by_name`, `raised_by_email`,
  `resolved_by_name`) rather than adding a mobile-specific serializer or
  endpoint.
- **Rationale**: Confirmed by reading `web/src/components/admin/DisputeManager.tsx`
  — the existing web admin console has the identical gap today (it only
  renders a truncated `service_request` UUID substring and never renders
  `raised_by` at all). Since FR-008 requires web and mobile to never
  diverge, fixing the shared serializer benefits both surfaces from a
  single change instead of building parallel, and possibly
  inconsistent, lookup logic in two places.
- **Alternatives considered**: A mobile-only nested-detail endpoint
  (`GET /admin/disputes/{id}` returning expanded data). Rejected: DRF's
  existing `AdminDisputeListView` already returns full `Dispute` objects
  (no separate detail endpoint exists or is needed) — the mobile detail
  screen can read the same list-item shape the list screen already
  fetched, once the shared serializer carries enough data.

## 4. Locating a specific account for moderation (FR-005)

- **Decision**: Add `rest_framework.filters.SearchFilter` to the
  existing `AdminUserListView` (`apps/users/views.py`), searching
  `email` and `full_name` — DRF core, no new dependency.
- **Rationale**: `GET /admin/users` already exists, is already
  `IsAdmin`-gated, and already returns `AdminUserListSerializer`
  (id/email/phone/full_name/role/is_active/is_verified/created_at) — the
  exact fields a moderation search result needs. It's missing only the
  ability to filter by a typed query rather than an exact `role`/
  `is_active`/`is_verified` match.
- **Alternatives considered**: A bespoke `?q=` param handled manually
  in the view. Rejected: `SearchFilter` is the already-idiomatic DRF way
  every other search-like admin surface in this codebase would use, and
  it's a one-line addition (`filter_backends`, `search_fields`).

## 5. Suspend/reinstate action (FR-005, FR-007)

- **Decision**: New `PATCH /admin/users/{id}/status` endpoint —
  `UpdateAPIView`, `IsAdmin`, a one-field `AdminUserStatusSerializer`
  (`is_active`) — structurally identical to the existing
  `AdminUserRoleUpdateView`/`PATCH /admin/users/{id}/role`.
- **Rationale**: See plan.md's Complexity Tracking — folding this into
  `/role` was rejected as a URL/semantics mismatch. This is the smallest
  possible new surface: same view base class, same permission, same
  one-field-serializer shape already proven at `/role`.
- **Alternatives considered**: none beyond what's in Complexity
  Tracking — the existing `/role` endpoint is the only real reuse
  candidate and was rejected for the reason given there.

## 6. Manual payout trigger (FR-006)

- **Decision**: Reuse `POST /admin/payouts/{provider_id}/trigger`
  as-is — already exists, already `IsAdmin`-gated, already returns
  404 with a clear message when there's nothing to pay out (spec's edge
  case: "manual payout triggered for a provider with no outstanding
  completed jobs" — already handled server-side by
  `AdminPayoutTriggerView`'s existing `if not payouts: 404` branch).
- **Rationale**: Zero backend change needed here — full reuse. The
  mobile screen only needs a provider picker (reusing the
  `AdminUserListView` search from #4, filtered client-side to
  `role in {MECHANIC, RECOVERY}`) and the FR-007 confirmation dialog
  before the `POST`.
- **Alternatives considered**: none — this is the cleanest case of
  Constitution III's "reuse before new endpoints" working exactly as
  intended.

## 7. Oversight / system health (FR-004)

- **Decision**: Extend `AdminAnalyticsView` (`apps/admin_ops/views.py`)
  with two additional aggregates — `failed_notifications_recent` (count
  of `Notification.delivery_status = FAILED` in the trailing 24 hours)
  and `failed_payments_recent` (count of `Payment.status = FAILED` in the
  same 24h window) — plus a single computed `has_alert` boolean
  (`true` when either count exceeds 5) the client reads directly rather
  than each client re-implementing its own threshold. Both the window
  (24h) and the threshold (5) were confirmed with the user via
  `/speckit-clarify` (2026-08-31), matching this project's established
  pattern of confirming launch-default numbers rather than picking them
  silently (e.g. Phase 4's 15% payout commission).
- **Rationale**: Both `DeliveryStatus.FAILED` (`apps/notifications/models.py`)
  and `PaymentStatus.FAILED` (`apps/orders/models.py`) already exist as
  queryable states — this is a new aggregation over existing data, not a
  new capability. Computing `has_alert` server-side (rather than the
  client picking its own "spike" threshold) matches Constitution V's
  spirit: business logic (what counts as abnormal) stays server-side, the
  client only displays the result — and keeps the eventual web-console
  reuse of the same field consistent with mobile (FR-008).
- **Alternatives considered**: Client-side threshold logic (e.g. "flag if
  more than N failures shown in the raw list"). Rejected: would let web
  and mobile disagree about what counts as "abnormal" if the web console
  is ever updated to show the same alert, and duplicates a decision that
  belongs in one place.

## 8. Staleness indicator (FR-009, edge case: no connectivity)

- **Decision**: Client-only concern — no backend change. Each admin
  screen records the wall-clock time of its last successful fetch; a
  shared `staleness_banner.dart` widget renders "last updated Xs/m ago"
  and switches to a visibly flagged "may be stale" state past a fixed
  threshold (proposed: 60s, matching SC-001's own 60s budget) or
  immediately on a failed refresh with cached data still shown.
- **Rationale**: This is purely a display/UX rule (spec's own wording:
  "MUST be clearly marked as possibly stale"), not new platform state —
  consistent with Constitution V ("display-only downstream") applied to
  freshness the same way it applies to currency/fares.
- **Alternatives considered**: A server-supplied "as of" timestamp per
  response. Not needed — every response already implies "current as of
  now" from the server's perspective; staleness is about the *client's*
  ability to reach the server, which the client already knows from its
  own fetch failing.

## 9. Confirmation gate (FR-007)

- **Decision**: One shared `ConfirmActionDialog` widget, invoked by
  every mutating action in this feature (dispute resolve, suspend/
  reinstate, manual payout trigger) before the API call fires — no
  per-screen bespoke confirmation UI.
- **Rationale**: SC-004 requires 100% of moderation actions and manual
  payouts to require confirmation; a single shared widget makes that
  provable by construction (one code path) rather than by auditing every
  screen individually. Dispute resolution is also gated through it even
  though the spec doesn't call it "destructive" — resolving forecloses
  the action for every other admin (edge case #1), which is exactly the
  kind of one-way action FR-007's spirit covers.
- **Alternatives considered**: `showDialog` calls duplicated per screen.
  Rejected for the auditability reason above.

## 10. Live-data refresh cadence (SC-005)

- **Decision**: `DisputeListScreen` and `OversightScreen` auto-refresh on
  a fixed 10-second timer while the screen is visible (cancelled on
  dispose), in addition to fetch-on-open and pull-to-refresh. Confirmed
  with the user via `/speckit-clarify` (2026-08-31).
- **Rationale**: SC-005 requires cross-surface state to converge within
  5 seconds; a manual-refresh-only design would only be true "if the
  admin happens to refresh," which doesn't actually satisfy the success
  criterion as a property of the app. A fixed poll matches the existing,
  proven precedent already in this codebase — `web/src/components/admin/FleetMap.tsx`
  and `AdminMapView`'s consumer both poll `GET /admin/map` every 10s — so
  this isn't a new pattern, it's this feature applying an established one
  to two more screens.
- **Alternatives considered**: Manual pull-to-refresh only (rejected —
  doesn't meet SC-005 as stated); a WebSocket channel like
  `apps.tracking`'s (rejected as disproportionate — that infra exists for
  continuous location streams, not an admin dashboard that's fine polling
  every 10s; adding a new Channels consumer for this would be a real new
  backend surface with no reuse candidate, unlike everything else in this
  feature).

## 11. Admin-broadcast notification on new dispute — explicitly deferred

- **Decision**: This feature does **not** build a "notify all admins when
  a dispute is raised" mechanism. Confirmed with the user via
  `/speckit-clarify` (2026-08-31) after discovering the spec's original
  Assumptions text was inaccurate — no such mechanism exists today
  (`ServiceRequestDisputeCreateView` only notifies the *other*
  participant; `apps.admin_ops`'s own code comments already flag "no
  all-admins broadcast primitive exists yet").
- **Rationale**: Building it would be a genuinely new backend capability
  (a new notification fan-out path, not a reuse of an existing one) and
  is separable from this feature's 3 stories, which are all fully
  testable via an admin opening the app and seeing current data (spec's
  own Independent Test criteria never require a push trigger). Keeping
  this feature backend-additive-only (research.md's 3 documented gaps,
  none of which are a new fan-out mechanism) stays consistent with
  Constitution III.
- **Alternatives considered**: Building a minimal broadcast now.
  Rejected per the user's explicit choice — left as a natural,
  separately-scoped follow-up feature instead.
