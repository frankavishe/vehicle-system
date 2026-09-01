---

description: "Task list for Admin Mobile App"
---

# Tasks: Admin Mobile App

**Input**: Design documents from `/specs/003-admin-mobile-app/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/admin-mobile-api.md, quickstart.md

**Tests**: Backend tests are **mandatory** (Constitution IV, NON-NEGOTIABLE — happy path + RBAC 401/403, written alongside each backend change, not after). Mobile stays on this app's already-documented "deliberately light" posture (`mobile/README.md`): only new pure-logic gets a `test/unit/` task; no new widget-test convention is introduced.

**Organization**: Tasks are grouped by user story (US1 = P1 Disputes, US2 = P2 Oversight, US3 = P3 Moderation), per spec.md.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to
- File paths are exact — this is an existing repo, not a scaffold

---

## Phase 1: Setup

**Purpose**: Directory scaffolding only — stack, dependencies, and lint config are all already in place (Constitution I; no new packages per plan.md's Technical Context).

- [X] T001 Create the `mobile/lib/features/admin/screens/` and `mobile/lib/features/admin/widgets/` directories (empty scaffolds ready for Phase 2/3+ files)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared mobile infrastructure every user story's screens plug into. No backend work is foundational — each backend change below is scoped to exactly one story (see contracts/admin-mobile-api.md), so backend tasks live in their story's phase, not here.

**⚠️ CRITICAL**: No user story screen work (Phase 3+) can begin until this phase is complete.

- [X] T002 [P] Create shared `ConfirmActionDialog` widget (FR-007's confirmation gate, used by every mutating action across US1/US3) in `mobile/lib/features/admin/widgets/confirm_action_dialog.dart`
- [X] T003 [P] Create shared `staleness_banner.dart` — a pure `isStale(DateTime lastFetched, {Duration threshold = const Duration(seconds: 60)})` helper plus the `StalenessBanner` widget that renders it (FR-009, used by US1 and US2) in `mobile/lib/features/admin/widgets/staleness_banner.dart`
- [X] T004 [P] Unit test the `isStale` helper (fresh timestamp → false, past-threshold timestamp → true, boundary case) in `mobile/test/unit/staleness_test.dart`
- [X] T005 Build the `AdminShell` bottom-nav scaffold — 4 destinations (Disputes, Oversight, Moderation, Profile), reusing the existing `ProfileScreen`, with placeholder bodies for the first 3 tabs (per research.md §2) in `mobile/lib/features/admin/screens/admin_shell.dart`
- [X] T006 Replace the `AdminHomeScreen` stub route with a nested `/admin` route tree — `AdminShell` at `/admin`, plus empty placeholder nested `GoRoute`s for `disputes/:id`, `moderation/accounts/:id`, and `moderation/payout` (to be wired to real screens in later phases) — in `mobile/lib/core/router/app_router.dart` (remove the now-unused `AdminHomeScreen` class)
- [X] T007 [P] Unit test the new `/admin` nested paths against the existing `computeRedirect`/`homeForRole` pure functions (an ADMIN-role user on `/admin/disputes/x` stays put; a non-admin is redirected away) in `mobile/test/unit/admin_router_test.dart`

**Checkpoint**: `AdminShell` renders with 4 tabs, `/admin/*` routes resolve, and the shared confirm/staleness widgets are ready to import — user story implementation can now begin.

---

## Phase 3: User Story 1 - Resolve an urgent dispute from a phone (Priority: P1) 🎯 MVP

**Goal**: An admin can see open disputes with enough detail to act, resolve one, and have that resolution be final and consistent with the web console.

**Independent Test**: Log in as admin on mobile, open the disputes list, open one dispute, resolve it, and confirm the result matches what resolving it from the web console would produce (quickstart.md §2).

### Backend (test-first, Constitution IV)

- [X] T008 [P] [US1] Write pytest coverage for `DisputeSerializer`'s new fields — `service_request_summary`, `raised_by_name`, `raised_by_email`, `resolved_by_name` populate correctly, and are `null`-safe when `raised_by`/`resolved_by` is `None` — extending `backend/apps/admin_ops/tests/test_disputes.py`
- [X] T009 [US1] Extend `DisputeSerializer` in `backend/apps/admin_ops/serializers.py` with the 4 additive read-only fields per data-model.md (implements T008; existing `service_request`/`raised_by`/`resolved_by` id fields stay unchanged)

### Mobile

- [X] T010 [P] [US1] Create `DisputeDto` (freezed + json_serializable, matching the contract in `contracts/admin-mobile-api.md`, including the nested `service_request_summary`) in `mobile/lib/shared/models/dispute_dto.dart`
- [X] T011 [US1] Add `listDisputes({String? status})` and `resolveDispute(String id)` methods to `mobile/lib/core/api/autoserve_api.dart`
- [X] T012 [US1] Build `DisputeListScreen` — fetches via `listDisputes` on open and on a fixed 10s auto-refresh timer while visible (cancelled on dispose, per research.md §10/SC-005), renders job/complainant/reason per item, explicit "nothing pending" empty state (edge case), `StalenessBanner` on fetch failure with cached data — in `mobile/lib/features/admin/screens/dispute_list_screen.dart`
- [X] T013 [US1] Build `DisputeDetailScreen` — full detail view, a Resolve action gated through `ConfirmActionDialog`, and explicit handling of the `400 "already resolved"` response (edge case #1 — show it as already-resolved, not a generic error) — in `mobile/lib/features/admin/screens/dispute_detail_screen.dart`
- [X] T014 [US1] Wire the Disputes tab in `AdminShell` to `DisputeListScreen`, and point the `disputes/:id` route (added in T006) to `DisputeDetailScreen`, in `mobile/lib/features/admin/screens/admin_shell.dart` and `mobile/lib/core/router/app_router.dart`

**Checkpoint**: Run `pytest` for `apps/admin_ops` (backend) and walk quickstart.md §2 end-to-end. User Story 1 is independently functional — this is a shippable MVP.

---

## Phase 4: User Story 2 - Check system health and act on it (Priority: P2)

**Goal**: An admin can see current platform figures and have any abnormal condition (failed notifications/payments) visibly flagged, not buried.

**Independent Test**: Open the oversight view in both a normal and a forced-failure-spike state and confirm the figures/alert match reality (quickstart.md §3).

### Backend (test-first, Constitution IV)

- [X] T015 [P] [US2] Write pytest coverage for `AdminAnalyticsView`'s new fields — `failed_notifications_recent`/`failed_payments_recent` count correctly over the trailing window, `has_alert` flips `true` past `FAILURE_ALERT_THRESHOLD` and stays `false` below it, plus RBAC 401/403 — extending `backend/apps/admin_ops/tests/test_analytics.py`
- [X] T016 [US2] Add the `FAILURE_ALERT_THRESHOLD = 5` setting (`backend/config/settings/base.py`, confirmed 2026-08-31, launch-default pattern matching `PLATFORM_COMMISSION_PCT`) and extend `AdminAnalyticsView` in `backend/apps/admin_ops/views.py` with the 3 new aggregate fields — `failed_notifications_recent`/`failed_payments_recent` over a trailing 24h window, `has_alert` when either exceeds the threshold — per data-model.md (implements T015)

### Mobile

- [X] T017 [P] [US2] Create `AdminAnalyticsDto` (freezed + json_serializable) in `mobile/lib/shared/models/admin_analytics_dto.dart`
- [X] T018 [US2] Add a `getAnalytics()` method to `mobile/lib/core/api/autoserve_api.dart`
- [X] T019 [US2] Build `OversightScreen` — stat tiles for active jobs/recent orders/revenue/active providers, fetched via `getAnalytics` on open and on a fixed 10s auto-refresh timer while visible (research.md §10/SC-005), a visibly distinct alert state driven by `has_alert` (not a client-computed threshold, per research.md §7), a bell icon linking to the existing `NotificationsScreen`, and `StalenessBanner` on fetch failure — in `mobile/lib/features/admin/screens/oversight_screen.dart`
- [X] T020 [US2] Wire the Oversight tab in `AdminShell` to `OversightScreen` in `mobile/lib/features/admin/screens/admin_shell.dart`

**Checkpoint**: Run `pytest` for `apps/admin_ops` and walk quickstart.md §3 end-to-end. User Stories 1 and 2 both work independently.

---

## Phase 5: User Story 3 - Take rapid moderation action (Priority: P3)

**Goal**: An admin can locate an account, suspend/reinstate it, and trigger an off-cycle payout, each behind an explicit confirmation.

**Independent Test**: Locate a specific account, take one moderation action, and trigger one manual payout, confirming both match what the web console would produce (quickstart.md §4).

### Backend (test-first, Constitution IV)

- [X] T021 [P] [US3] Write pytest coverage for `AdminUserListView`'s new `?search=` param — matches on `email` and `full_name` substrings (case-insensitive), combines with existing `role`/`is_active` filters, plus RBAC 401/403 — extending `backend/apps/users/tests/test_admin_users.py`
- [X] T022 [US3] Add `filter_backends`/`search_fields = ["email", "full_name"]` to `AdminUserListView` in `backend/apps/users/views.py` (implements T021)
- [X] T023 [P] [US3] Write pytest coverage for the new `PATCH /admin/users/{id}/status` endpoint — toggles `is_active` both directions, is idempotent (no "already suspended" error, per data-model.md), 404 on unknown id, **403 when the target user's `role == "ADMIN"` (spec.md FR-005)**, RBAC 401/403 — extending `backend/apps/users/tests/test_admin_users.py`
- [X] T024 [US3] Add `AdminUserStatusSerializer` (`is_active` only) to `backend/apps/users/serializers.py`, `AdminUserStatusUpdateView` (mirrors `AdminUserRoleUpdateView`, **plus a check rejecting `role == "ADMIN"` targets with 403 — server-side, not just hidden client-side, per FR-005**) to `backend/apps/users/views.py`, and the `admin/users/<uuid:pk>/status` route to `backend/apps/users/urls.py` (implements T023)

### Mobile

- [X] T025 [P] [US3] Create `AdminUserSummaryDto` in `mobile/lib/shared/models/admin_user_summary_dto.dart` and `PayoutDto`/`PayoutItemDto` in `mobile/lib/shared/models/payout_dto.dart` (freezed + json_serializable, matching contracts/admin-mobile-api.md)
- [X] T026 [US3] Add `searchUsers({String? search, String? role})`, `setUserStatus(String id, bool isActive)`, `triggerManualPayout(String providerId)`, and `listPayouts({String? provider})` methods to `mobile/lib/core/api/autoserve_api.dart`
- [X] T027 [US3] Build `ModerationScreen` — account search (debounced query against `searchUsers`, excluding `role == "ADMIN"` results and showing a clear no-matches state per FR-005), account detail showing name/email/role/active/verification state (enough to disambiguate similarly-named accounts before acting, per FR-005), Suspend/Reinstate action gated through `ConfirmActionDialog` and reflecting the account's current state rather than stale local state (edge case) — in `mobile/lib/features/admin/screens/moderation_screen.dart`
- [X] T028 [US3] Build `PayoutTriggerScreen` — provider picker (via `searchUsers`, filtered client-side to `role in {MECHANIC, RECOVERY}`), that provider's recent payout history via `listPayouts`, a Trigger action gated through `ConfirmActionDialog`, and clear surfacing of the 404 "nothing to pay out" response rather than a generic error (edge case) — in `mobile/lib/features/admin/screens/payout_trigger_screen.dart`
- [X] T029 [US3] Wire the Moderation tab in `AdminShell` to `ModerationScreen`, point the `moderation/accounts/:id` route (added in T006) at the account-detail view, add a `moderation/payout` entry point to `PayoutTriggerScreen`, in `mobile/lib/features/admin/screens/admin_shell.dart` and `mobile/lib/core/router/app_router.dart`

**Checkpoint**: Run `pytest` for `apps/users` and walk quickstart.md §4 end-to-end. All 3 user stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final verification across all 3 stories together.

- [X] T030 [P] Update `mobile/README.md`'s feature inventory and Testing section to list the new `features/admin/` module and its 2 new unit test files, matching this repo's existing per-phase documentation convention
- [X] T031 Run the full backend suite (`pytest`) and `manage.py check` inside Docker, and `flutter analyze` + `flutter test` for mobile — confirm all green, no regressions — **verified 2026-08-31: 251/251 backend passing (42 new), `manage.py check` clean, `flutter analyze` 0 issues, 30/30 Flutter tests passing (9 new)**
- [X] T032 Walk quickstart.md §5 (edge cases: stale data, zero open disputes, same-dispute race) end-to-end as final sign-off — **done 2026-08-31, backend live-verified via curl against the running Docker stack** (not pytest — genuine HTTP round-trips): resolve → double-resolve correctly returns `400 "This dispute is already resolved."`; resolved dispute's `raised_by_name`/`raised_by_email`/`resolved_by_name`/`service_request_summary` all populate correctly; `?search=` finds an account by name; self-suspend correctly rejected `403`; suspend/reinstate a non-admin account both `200`; a manual payout trigger with nothing outstanding correctly returns `404` with a clear message; `/admin/analytics` returns the new alert fields. **Note for whoever deploys this**: `daphne` (unlike `runserver`) does not autoreload — a code change requires `docker compose restart backend` to take effect; this was hit and fixed during this verification pass. Stale-data/zero-disputes states and the mobile-side rendering of all the above are verified by code inspection + the `isStale`/router unit tests, not a live emulator session — same category of gap this project's Phase 4 already flagged for its own WebSocket tracking flow, not unique to this feature.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Phase 1. **Blocks all of Phase 3-5** — `AdminShell`, the `/admin` route tree, and the shared confirm/staleness widgets are consumed by every story.
- **User Stories (Phase 3-5)**: All depend on Phase 2 only, not on each other — each story's backend change touches a different file/endpoint (Dispute vs. Analytics vs. Users), and each story's screen is a separate tab wired independently in `AdminShell`. They can be built in parallel or strictly in priority order (P1 → P2 → P3, recommended for solo/incremental delivery).
- **Polish (Phase 6)**: Depends on however many of Phase 3-5 are in scope for this delivery.

### Within Each User Story

- Backend test task before its corresponding backend implementation task (Constitution IV: tests are written alongside the change, and the implementation task explicitly "implements" its test task).
- DTO creation before the `autoserve_api.dart` methods that return it.
- API client methods before the screens that call them.
- Screens before the `AdminShell`/router wiring task that makes them reachable.

### Parallel Opportunities

- T002, T003, T004 (Phase 2 widgets/tests) — different files, no shared dependency.
- Within each story, the `[P]`-marked backend test task and the mobile DTO task touch entirely different files/languages and can run in parallel with each other (but each still precedes its own same-story implementation task).
- Once Phase 2 is checkpointed, Phase 3/4/5 as a whole can be staffed in parallel (e.g. one person per story) since they touch disjoint backend files (`admin_ops/serializers.py` vs. `admin_ops/views.py` analytics vs. `users/views.py`) and disjoint new mobile screens.

---

## Parallel Example: User Story 1

```bash
# Backend test + mobile DTO can start together — different files/stacks:
Task: "Write pytest coverage for DisputeSerializer's new fields in backend/apps/admin_ops/tests/test_disputes.py"
Task: "Create DisputeDto in mobile/lib/shared/models/dispute_dto.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1 (Setup) → Phase 2 (Foundational, blocking) → Phase 3 (US1).
2. **STOP and VALIDATE**: run quickstart.md §2 end-to-end. This alone is a shippable admin mobile app per the spec's own priority framing ("without this, the app has no reason to exist separately from the web console").

### Incremental Delivery

1. Setup + Foundational → shell/routes/shared widgets ready.
2. US1 (Disputes) → validate → MVP.
3. US2 (Oversight) → validate → adds monitoring value.
4. US3 (Moderation) → validate → adds rapid-action value.
5. Polish → full-suite regression check + edge-case sign-off.
