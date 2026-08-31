---

description: "Task list template for feature implementation"
---

# Tasks: Recovery & Towing Web Portal

**Input**: Design documents from `/specs/002-recovery-towing-web-portal/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/rest.md, contracts/websocket.md, quickstart.md

**Tests**: Backend test tasks are included because plan.md's Technical Context explicitly commits the one backend addition to `pytest-django` tests (Constitution Principle IV). No frontend test framework exists in this repo and this feature does not introduce one — frontend tasks have no accompanying automated test tasks; `quickstart.md` is the frontend validation method.

**Organization**: Tasks are grouped by user story (spec.md) to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Every task lists its exact file path

## Path Conventions

Web application, existing single projects (plan.md Structure Decision):

- Frontend: `web/src/app/recovery/`, `web/src/components/recovery/`, `web/src/lib/types.ts`
- Backend: `backend/apps/dispatch/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Scaffold the new route/component directories. No new dependency is added anywhere in this feature (plan.md Technical Context) — Next.js 16.3.1, React 19, Tailwind 4, `leaflet`/`react-leaflet`, DRF, Django Channels, and `rest_framework_simplejwt` are already installed and unchanged.

- [X] T001 Create the empty `web/src/app/recovery/` and `web/src/components/recovery/` directories that the rest of this plan fills in, matching the layout of `web/src/app/mechanic/` and `web/src/components/admin/`

**Checkpoint**: Directory scaffolding exists — no build/dependency changes needed before Foundational work starts.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The role/verification gate every `/recovery/*` page sits behind. **MUST** complete before any user story's pages are reachable.

**⚠️ CRITICAL**: No user story page can be manually verified until this phase is complete.

- [X] T002 Create `web/src/app/recovery/layout.tsx` — Server Component gate: redirect to `/login?next=...` if no session, redirect to `/` if `role !== "RECOVERY"`, call `GET /users/me` and redirect/block if `is_verified` is false (FR-001), plus a nav shell with links for the dispatch dashboard and performance view — mirrors `web/src/app/mechanic/layout.tsx` (itself mirroring `web/src/app/admin/layout.tsx`)

**Checkpoint**: Foundation ready — user story pages can now be built and will correctly gate access.

---

## Phase 3: User Story 1 - See and track every active tow at a glance (Priority: P1) 🎯 MVP

**Goal**: A logged-in, verified recovery operator sees every one of their active tow jobs at once, each with live status and position, updating without a manual refresh, and dropping off once completed/cancelled.

**Independent Test**: Log in as a recovery operator with 2+ active tow jobs and confirm the portal shows all of them simultaneously with correct live status and position, distinct from each other.

### Implementation for User Story 1

- [X] T003 [P] [US1] Create `web/src/components/recovery/ActiveTowMap.tsx` — Leaflet map rendering one marker per active job; for each job, opens (or reuses) a `ws://.../tracking/{service_request_id}/` connection and updates that job's marker from `location_update` events, adapting the multi-marker pattern of `web/src/components/admin/FleetMap.tsx` (one marker per job here, not per provider — per research.md)
- [X] T004 [P] [US1] Create `web/src/components/recovery/ActiveJobList.tsx` — list of active jobs (status, customer, pickup/dropoff) kept in sync with the same job set rendered on `ActiveTowMap.tsx`
- [X] T005 [US1] Add client-side staleness detection to `web/src/components/recovery/ActiveTowMap.tsx`: track time since each job's last `location_update`/`ProviderProfile.updated_at` change and show an explicit "stale" indicator on that marker past a fixed threshold, rather than silently freezing it (edge case, depends on T003)
- [X] T006 [US1] Ensure overlapping-route jobs stay individually selectable/identifiable on `ActiveTowMap.tsx` and distinct in `ActiveJobList.tsx` (SC-005 edge case, depends on T003, T004)
- [X] T007 [US1] Create `web/src/app/recovery/page.tsx` — dispatch dashboard: fetch `GET /service-requests`, client-side filter to `status in {ACCEPTED, EN_ROUTE, IN_PROGRESS}` as the active set, render `ActiveTowMap` + `ActiveJobList` inside the `recovery/layout.tsx` shell (depends on T002, T003, T004)
- [X] T008 [US1] Wire the `status_update` WS event (already broadcast by `ServiceRequestAcceptView`/`ServiceRequestStatusUpdateView` for every role) into `recovery/page.tsx`/`ActiveJobList.tsx` so a job's displayed status updates live, and remove a job from the active set the instant it transitions to `COMPLETED`/`CANCELLED` (FR-003, FR-004, depends on T007)

**Checkpoint**: User Story 1 is fully functional and independently testable per quickstart.md Story 1.

---

## Phase 4: User Story 2 - Estimate a tow's fare before committing (Priority: P2)

**Goal**: The operator sees a pending job's `estimated_fare` before accepting it, and both `estimated_fare` and `final_fare` together once it's completed — no client-side fare computation.

**Independent Test**: Enter/select a pending tow request's detail page and confirm the shown estimate matches the fare the job was created with, independent of the live multi-tow view.

### Implementation for User Story 2

- [X] T009 [P] [US2] Create `web/src/components/recovery/FareEstimateCard.tsx` — renders `estimated_fare` alone while `PENDING`, or `estimated_fare` + `final_fare` together once `COMPLETED` (FR-005, FR-006), reading both straight off the `ServiceRequest` object with no client-side recomputation
- [X] T010 [US2] Create `web/src/app/recovery/jobs/[id]/page.tsx` — job detail page: fetch `GET /service-requests/{id}` (already visible pre-accept while `PENDING` per existing visibility rule), render `FareEstimateCard` inside the `recovery/layout.tsx` shell (depends on T002, T009)
- [X] T011 [US2] Link each entry in `web/src/components/recovery/ActiveJobList.tsx` to its `web/src/app/recovery/jobs/[id]` detail page (depends on T004, T010)

**Checkpoint**: User Stories 1 AND 2 both work independently, per quickstart.md Story 2.

---

## Phase 5: User Story 3 - Review driver/vehicle performance over time (Priority: P3)

**Goal**: The operator selects a period and sees their own completed-tow count, average rating, and typical response time for it, with "no completions" visibly distinct from "no data" (FR-008), strictly self-scoped (FR-009).

**Independent Test**: Select a date range and confirm the shown completed-tow count, average rating, and response-time figures match that operator's actual job history for the period, independent of the live dispatch view and the fare estimator.

### Backend for User Story 3

- [X] T012 [P] [US3] Add nullable `accepted_at`/`completed_at` `DateTimeField`s to `ServiceRequest` in `backend/apps/dispatch/models.py` and generate the migration `backend/apps/dispatch/migrations/0003_servicerequest_accepted_completed_at.py`
- [X] T013 [US3] Set `accepted_at` in `ServiceRequestAcceptView.post()`'s existing status-flip update call in `backend/apps/dispatch/views.py` (depends on T012)
- [X] T014 [US3] Set `completed_at` in `ServiceRequestStatusUpdateView.patch()`'s existing `COMPLETED` branch, alongside the existing `final_fare` assignment, in `backend/apps/dispatch/views.py` (depends on T012)
- [X] T015 [P] [US3] Add read-only `accepted_at`/`completed_at` fields to `ServiceRequestSerializer` in `backend/apps/dispatch/serializers.py` (depends on T012)
- [X] T016 [US3] Implement `ProviderPerformanceView` in `backend/apps/dispatch/views.py` — `GET /providers/me/performance`, `IsRecovery`, `period_start`/`period_end` query params (default trailing 30 days), returning `period_start`, `period_end`, `completed_count`, `cancelled_count`, `average_rating` (`null` if empty), `average_response_time_seconds` (`null` if empty), `400` if `period_start > period_end`, per contracts/rest.md's queryset shape (depends on T013, T014)
- [X] T017 [US3] Register `GET /providers/me/performance` → `ProviderPerformanceView` in `backend/apps/dispatch/urls.py` (depends on T016)

### Tests for User Story 3

- [X] T018 [P] [US3] Extend `backend/apps/dispatch/tests/test_status_transitions.py` to assert `accepted_at`/`completed_at` are set exactly once, at the expected transition, and never on any other transition (depends on T013, T014)
- [X] T019 [P] [US3] Create `backend/apps/dispatch/tests/test_performance.py` — happy path (hand-computed `completed_count`/`cancelled_count`/`average_rating`/`average_response_time_seconds` against fixture data), RBAC (`401` unauthenticated, `403` non-`RECOVERY`, another operator's jobs never counted), and the FR-008 zero-data-distinction cases (all-cancelled period, empty period), per quickstart.md "Verifying the new backend surface directly" (depends on T016, T017)

### Frontend for User Story 3

- [X] T020 [P] [US3] Add a `ProviderPerformance` interface to `web/src/lib/types.ts` (`period_start`, `period_end`, `completed_count`, `cancelled_count`, `average_rating: number | null`, `average_response_time_seconds: number | null`) matching contracts/rest.md's response shape, and add `accepted_at: string | null` / `completed_at: string | null` to the existing `ServiceRequest` interface
- [X] T021 [P] [US3] Create `web/src/components/recovery/PerformanceSummary.tsx` — period selector plus `completed_count`/`cancelled_count`/`average_rating`/`average_response_time_seconds`, with an explicit empty state (not `0` or a broken chart) when `average_rating`/`average_response_time_seconds` are `null` (FR-008, depends on T020)
- [X] T022 [US3] Create `web/src/app/recovery/performance/page.tsx` — fetch `GET /providers/me/performance` for the selected period, render `PerformanceSummary` inside the `recovery/layout.tsx` shell (depends on T002, T017, T021)

**Checkpoint**: All three user stories are independently functional, per quickstart.md Story 3.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final wiring and validation across all three stories.

- [X] T023 Wire nav links for `/recovery` (dispatch) and `/recovery/performance` into `web/src/app/recovery/layout.tsx`'s nav shell, if not already completed in T002
- [X] T024 Run `pytest backend/apps/dispatch/tests/test_performance.py backend/apps/dispatch/tests/test_status_transitions.py` and confirm all pass
- [X] T025 Execute quickstart.md's full manual validation (Stories 1-3 scenarios plus the FR-009 second-operator isolation check)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user story pages (T007, T010, T022 each need `recovery/layout.tsx` from T002)
- **User Story 1 (Phase 3)**: Depends on Foundational only
- **User Story 2 (Phase 4)**: Depends on Foundational only; T011 also depends on US1's `ActiveJobList.tsx` (T004) for the detail-page link, but US2's own independent test does not require US1's map/live-update wiring
- **User Story 3 (Phase 5)**: Depends on Foundational only — fully independent of US1/US2 (own backend migration, own view, own page)
- **Polish (Phase 6)**: Depends on all three user stories being complete

### User Story Dependencies

- **US1 (P1)**: No dependency on US2 or US3
- **US2 (P2)**: Independently testable via direct navigation to `/recovery/jobs/[id]`; T011 is a convenience link from US1's list, not a hard dependency
- **US3 (P3)**: No dependency on US1 or US2 — separate backend migration/view/page

### Within Each User Story

- US1: models/components (T003, T004) before staleness/edge-case handling (T005, T006) before the page that composes them (T007) before live-update wiring (T008)
- US2: component (T009) before the page (T010) before the cross-story link (T011)
- US3 backend: model+migration (T012) before the two timestamp-write sites (T013, T014) and the serializer fields (T015) before the view (T016) before the URL registration (T017) before its tests (T018, T019); frontend: types (T020) before the component (T021) before the page (T022)

### Parallel Opportunities

- T003 and T004 (US1 map + list components) in parallel
- T012 and T015 cannot run in parallel with each other in practice (T015 reads the fields T012 adds), but T018/T019 (US3 tests) can run in parallel with each other once T016/T017 land
- T020 and T021 (US3 frontend types + component) in parallel
- Once Foundational (Phase 2) is done, US1, US2, and US3 can proceed in parallel if staffed — they touch disjoint files (US1: `ActiveTowMap.tsx`/`ActiveJobList.tsx`/`recovery/page.tsx`; US2: `FareEstimateCard.tsx`/`recovery/jobs/[id]/page.tsx`; US3: `backend/apps/dispatch/*` + `PerformanceSummary.tsx`/`recovery/performance/page.tsx`)

---

## Parallel Example: User Story 1

```bash
# Launch both new components for User Story 1 together (different files):
Task: "Create web/src/components/recovery/ActiveTowMap.tsx"
Task: "Create web/src/components/recovery/ActiveJobList.tsx"
```

## Parallel Example: User Story 3 backend

```bash
# After T012 (migration) lands, tests can be written in parallel once the view exists:
Task: "Extend backend/apps/dispatch/tests/test_status_transitions.py for accepted_at/completed_at"
Task: "Create backend/apps/dispatch/tests/test_performance.py"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002) — CRITICAL, blocks all stories
3. Complete Phase 3: User Story 1 (T003-T008)
4. **STOP and VALIDATE**: run quickstart.md Story 1 manually
5. Demo: multi-tow dispatch view with live status/position, no fare estimator or performance view yet

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. Add User Story 1 → validate independently → demo (MVP)
3. Add User Story 2 → validate independently → demo
4. Add User Story 3 → validate independently → demo
5. Polish (T023-T025) → full quickstart.md pass

### Parallel Team Strategy

With three developers, after Setup + Foundational (T001-T002) complete:

- Developer A: User Story 1 (T003-T008)
- Developer B: User Story 2 (T009-T011, after T004 lands for the T011 link)
- Developer C: User Story 3 (T012-T022, backend then frontend)

---

## Notes

- [P] tasks touch different files with no unmet dependency
- [Story] labels map every user-story-phase task to US1/US2/US3 for traceability
- No test tasks exist for Setup/Foundational/US1/US2 — no frontend test framework exists in this repo (plan.md Technical Context) and those stories add no backend surface; only US3's backend addition gets `pytest-django` coverage (T018, T019), per Constitution Principle IV
- Verify T018/T019 fail before T012-T017 land, then pass after — standard TDD framing for the one backend addition
- Commit after each task or logical group
- Stop at any checkpoint to validate a story independently before continuing

## Extension Hooks

No `.specify/extensions.yml` found — before/after-tasks hooks skipped.
