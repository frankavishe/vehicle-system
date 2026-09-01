# Implementation Plan: Admin Mobile App

**Branch**: `003-admin-mobile-app` | **Date**: 2026-08-31 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/003-admin-mobile-app/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command; its definition describes the execution workflow.

## Summary

Add a real ADMIN surface to the existing Flutter app (`mobile/`), replacing
today's profile-only stub (`AdminHomeScreen` in `core/router/app_router.dart`)
with a four-tab shell covering the three prioritized stories: resolve
disputes (P1), read platform oversight/health (P2), and take rapid
moderation actions — account suspend/reinstate and manual payout trigger
(P3). Per Constitution III, this is built almost entirely as a new
frontend surface onto `apps.admin_ops` and `apps.users`, which already
implement disputes, payouts, and analytics for the existing admin web
console. Three small, additive backend changes are required because the
existing endpoints don't yet carry enough detail or one missing action —
each is documented below rather than added silently (see Constitution
Check and Complexity Tracking).

## Technical Context

**Language/Version**: Dart 3.12 (`mobile/pubspec.yaml`'s `sdk: ^3.12.2`) for the app; Python 3.12 for the two backend apps touched.

**Primary Dependencies**: Flutter + `flutter_riverpod` (state), `go_router` (routing), `dio` (HTTP) — all already in `mobile/pubspec.yaml`, no new mobile packages needed. Backend: Django REST Framework (already installed); `rest_framework.filters.SearchFilter` is part of DRF core, not a new dependency.

**Storage**: PostgreSQL + PostGIS (existing `infra` stack). No new tables or migrations for `Dispute`/`Payout`/`PayoutItem` — they're consumed as-is. `apps.users.User.is_active` already exists as a column; exposing a way to PATCH it is a new *endpoint*, not a new *column*.

**Testing**: pytest-django for every backend change (Constitution IV — happy path + RBAC 401/403), added to the existing `apps/users/tests/test_admin_users.py` and `apps/admin_ops/tests/`. Mobile stays on this app's already-documented "deliberately light" posture (`mobile/README.md` Testing section): `test/unit/` coverage only for new pure logic (e.g. the stale-data/staleness helper and the confirmation-gate helper), no new widget-test convention introduced.

**Target Platform**: Android/iOS via Flutter (existing `mobile/` target); backend stays Linux/Docker (existing `infra/docker-compose.yml`, no new services).

**Project Type**: Mobile app feature addition, calling into an already-running Django REST API (matches the constitution's own "Admin mobile app" line in its Reuse Map).

**Performance Goals**: SC-001 (open app → resolve a dispute in <60s) and SC-003 (spot a flagged abnormal condition in <5s) are UX/latency budgets, not throughput targets — met by fetching the disputes list and oversight snapshot directly on screen-open (no client-side caching layer to warm first).

**Constraints**: SC-005 (an action taken on mobile is reflected on web within 5s, never conflicting) is satisfied by (a) never caching admin state beyond the current screen instance — every mutating action (resolve/suspend/reinstate/trigger payout) re-fetches its list from the server response rather than optimistically patching local state, and the server is the single arbiter of "already resolved"/"already suspended" (FR-003, edge case #1 and #3) — and (b) a fixed 10-second auto-refresh poll on the Disputes and Oversight screens while open (confirmed with the user via `/speckit-clarify` 2026-08-31; research.md §10), matching the existing `GET /admin/map` 10s-poll precedent already used by `web/`'s `FleetMap`/`AdminMapView`. FR-007's confirmation gate and FR-009's staleness indicator are both client-only UI rules with no new backend state. FR-004's abnormal-condition threshold is a confirmed launch default: more than 5 failed notifications or 5 failed payments in a trailing 24h window (research.md §7).

**Scale/Scope**: One new Flutter feature module (`features/admin/`, ~6 screens across the 3 stories) + 3 small additive backend changes (2 endpoint extensions, 1 new endpoint) across 2 existing Django apps. No new Django app.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Fixed Stack, No Re-Architecture** — PASS. Flutter (existing `mobile/`) + Django REST (existing `apps.admin_ops`/`apps.users`). No new framework, DB, or client technology.
- **II. Four-Role RBAC via One Enum** — PASS. Every screen and endpoint in this feature is admin-only, enforced via the existing `IsAdmin` permission class (`apps/common/permissions.py`) and the mobile router's existing `computeRedirect`/`homeForRole('ADMIN')`. No new role, no role logic duplicated client-side.
- **III. Frontend-Onto-Existing-Backend (Reuse Before New Endpoints)** — CONDITIONAL PASS, with 3 documented gaps (Constitution III explicitly permits new backend surface "only when the spec's Clarifications section explicitly documents the gap and why reuse isn't possible" — this spec predates this discovery, so the gaps are documented here, at plan time, as the equivalent explicit record; see Complexity Tracking):
  1. `GET /admin/users` has no search-by-name/email — needed for FR-005's "locate a specific user or provider account." *Fix*: add DRF `SearchFilter` (`email`, `full_name`) to the existing `AdminUserListView` — an additive, backward-compatible extension, not a new endpoint.
  2. No endpoint toggles `User.is_active` — needed for FR-005's suspend/reinstate. The sibling `PATCH /admin/users/{id}/role` endpoint exists but is role-only by name and by serializer; folding status into it would make `/role` a misnomer. *Fix*: one new endpoint, `PATCH /admin/users/{id}/status`, mirroring the exact shape of the existing `/role` endpoint (`UpdateAPIView`, `IsAdmin`, one-field serializer).
  3. `DisputeSerializer` only exposes raw FK ids (`service_request`, `raised_by`, `resolved_by`) — insufficient for FR-002's "job, complainant, reason" without a second lookup. The **existing web admin console has the same gap today** (`DisputeManager.tsx` only ever renders a truncated `service_request` UUID and never renders `raised_by` at all) — so this isn't a mobile-only need, it's a pre-existing shared-serializer gap. *Fix*: add read-only, additive fields to the shared `DisputeSerializer` (`service_request_summary`, `raised_by_name`, `raised_by_email`, `resolved_by_name`) — the existing `service_request`/`raised_by`/`resolved_by` id fields are left untouched so `web/`'s current code (which calls `.slice()` on `service_request` as a string) keeps working unmodified. This directly serves FR-008 (web and mobile must never diverge) by giving both surfaces the same richer data instead of building a mobile-only shape.
- **IV. Test-First on the Backend (NON-NEGOTIABLE)** — PASS, enforced in tasks: every backend change above ships with pytest-django tests (happy path + 401/403) alongside it, not after.
- **V. Tanzania Market Constraints Are Display-Only Downstream** — PASS. Payout amounts/currency and fare figures are read verbatim from `PayoutSerializer`/`AdminAnalyticsView`; the mobile app formats and displays them but computes none of the underlying commission/gateway logic itself.

*Post-Phase-1 re-check*: see bottom of this file.

## Project Structure

### Documentation (this feature)

```text
specs/003-admin-mobile-app/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md         # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
│   └── admin-mobile-api.md
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
backend/apps/users/
├── serializers.py        # + AdminUserStatusSerializer; AdminUserListSerializer unchanged
├── views.py               # + AdminUserStatusUpdateView; AdminUserListView + SearchFilter/search_fields
├── urls.py                 # + admin/users/<uuid:pk>/status
└── tests/test_admin_users.py   # + status-toggle tests, + search-query tests

backend/apps/admin_ops/
├── serializers.py         # DisputeSerializer + service_request_summary/raised_by_name/raised_by_email/resolved_by_name (additive)
├── views.py                 # AdminAnalyticsView + failed_notifications_recent/failed_payments_recent/has_alert
└── tests/
    ├── test_disputes.py     # + new-field assertions (existing file, extended)
    └── test_analytics.py    # + alert-flag tests (existing file, extended)

mobile/lib/
├── core/api/autoserve_api.dart          # + admin methods (disputes/oversight/moderation/payouts)
├── core/router/app_router.dart           # AdminHomeScreen stub replaced by nested /admin routes
├── shared/models/
│   ├── dispute_dto.dart                  # new (freezed + json_serializable, matches shared/models convention)
│   ├── admin_analytics_dto.dart          # new
│   ├── payout_dto.dart                   # new
│   └── admin_user_summary_dto.dart       # new
└── features/admin/
    ├── screens/
    │   ├── admin_shell.dart              # bottom-nav shell: Disputes / Oversight / Moderation / Profile
    │   ├── dispute_list_screen.dart      # Story 1
    │   ├── dispute_detail_screen.dart    # Story 1
    │   ├── oversight_screen.dart         # Story 2
    │   ├── moderation_screen.dart        # Story 3 — account search + suspend/reinstate
    │   └── payout_trigger_screen.dart    # Story 3 — manual payout by provider
    └── widgets/
        ├── confirm_action_dialog.dart    # shared FR-007 confirmation gate
        └── staleness_banner.dart         # shared FR-009 "data may be stale" indicator

mobile/test/unit/
├── staleness_test.dart                    # pure-logic test for the staleness helper
└── admin_router_test.dart                 # extends existing computeRedirect/homeForRole tests for the new nested /admin routes
```

**Structure Decision**: No new top-level project. This is a feature module inside the existing `mobile/lib/features/` tree (mirroring the existing `features/provider/` bottom-nav-shell pattern used by `ProviderShell`) plus small, additive extensions to two already-existing Django apps (`apps.users`, `apps.admin_ops`) — no new Django app, matching Constitution I/III.

## Complexity Tracking

> Three additive backend changes are required (none are a new Django app, model, or migration). Documented per Constitution III's explicit-justification carve-out.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| New endpoint: `PATCH /admin/users/{id}/status` | FR-005 (suspend/reinstate) has no existing endpoint — `User.is_active` exists as a column but nothing exposes writing it via REST. | Reusing `PATCH /admin/users/{id}/role` by adding `is_active` to its serializer was rejected: the endpoint is URL-named `/role`, so accepting an unrelated field there would be a surprising, undocumented side-channel — worse for future readers than one small sibling endpoint that mirrors the existing one exactly. |
| Extend `AdminUserListView` with `SearchFilter` | FR-005 ("locate a specific user or provider account") has no query path today — `filterset_fields` only supports exact-match `role`/`is_active`/`is_verified`. | A new dedicated search endpoint was rejected: `SearchFilter` is already a DRF core feature (no new dependency), and the existing view already returns the right serializer/permission — extending it in place keeps one list endpoint instead of two. |
| Extend `DisputeSerializer` with 4 read-only fields | FR-002 needs job/complainant detail; the existing serializer is FK-id-only, and — confirmed by reading `DisputeManager.tsx` — the web console has the same gap today, it just never surfaced it as a problem. | A mobile-only serializer/endpoint was rejected: it would let web and mobile diverge (violates FR-008) and duplicate the same lookup logic twice. Extending the shared serializer fixes both surfaces from one place. |

---

### Post-Phase-1 Constitution Re-Check

Data model (below) confirms no new tables/migrations are introduced — the
three changes above are all read/write extensions to existing models via
existing serializers/views. RBAC, stack, and test-first gates are
unaffected by the Phase 1 design. **Gate: PASS, no unresolved violations.**
