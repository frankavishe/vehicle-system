---

description: "Task list template for feature implementation"
---

# Tasks: Mechanic Web Portal

**Input**: Design documents from `/specs/001-mechanic-web-portal/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all present)

**Tests**: Included for the two backend additions only, per Constitution Principle IV
("Test-First on the Backend — NON-NEGOTIABLE"). No frontend test task is
included — this repo has no established frontend test framework yet and
Principle IV explicitly says not to invent one unprompted inside a
feature.

**Organization**: Tasks are grouped by user story (spec.md priorities
P1/P2/P3) to enable independent implementation and testing of each.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- File paths are exact and relative to the repo root

## Path Conventions

This feature adds to the existing single `web/` Next.js project and the
existing single `backend/` Django project — no new project. See plan.md
"Project Structure" for the full file map.

---

## Phase 1: Setup

**Purpose**: Scaffolding so every later task has somewhere to land.

- [X] T001 [P] Create the `web/src/app/mechanic/` and `web/src/components/mechanic/` directories (empty is fine — subsequent tasks populate them).
- [ ] T002 Confirm the local dev stack is running (Postgres+PostGIS, Redis, Django with Channels on `:8000`, Next.js `web/` on `:3000`) and seed one `MECHANIC`-role user with `is_verified=True` (its `ProviderProfile` auto-creates via `backend/apps/providers/signals.py`) — needed to manually exercise every task below as it lands, per quickstart.md's Prerequisites.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared infrastructure every user story's pages sit on top of.

**⚠️ CRITICAL**: No user-story page can be built until T005 exists — every `web/src/app/mechanic/**/page.tsx` renders inside this layout.

- [X] T003 [P] Add `MeResponse` (`id`, `role`, `full_name`, `email`, `is_active`, `is_verified`, `created_at` — matching `backend/apps/users/serializers.py`'s `MeSerializer`), `ProviderDocument` (`id`, `doc_type`, `file_url`, `verified`, `uploaded_at` — matching `ProviderDocumentSerializer`), `PartsSourcingStatus` (`"PENDING" | "APPROVED" | "REJECTED" | "ORDERED"`), and `PartsSourcingRequest` (`id`, `service_request`, `requested_by`, `spare_part`, `quantity`, `status`, `created_at` — matching `PartsSourcingRequestSerializer`) types to `web/src/lib/types.ts`.
- [X] T004 [P] Add a `user?.role === "MECHANIC"` branch to the role-conditional nav in `web/src/components/layout/SiteHeader.tsx`, linking to `/mechanic` — mirrors the existing `user?.role === "ADMIN"` branch in the same file.
- [X] T005 Create `web/src/app/mechanic/layout.tsx`: a Server Component that calls `getSession()` (redirect to `/login?next=/mechanic` if absent), redirects to `/` if `role !== "MECHANIC"`, calls `apiFetch<MeResponse>("/users/me")` and redirects to `/` if `!is_verified` (FR-001), and renders a nav (Dashboard `/mechanic`, Earnings `/mechanic/earnings`, History `/mechanic/history`, Documents `/mechanic/documents`) plus `{children}` — mirrors `web/src/app/admin/layout.tsx`. Depends on: T003.

**Checkpoint**: Foundation ready — user story work can begin.

---

## Phase 3: User Story 1 - Manage today's jobs from a desktop (Priority: P1) 🎯 MVP

**Goal**: A verified mechanic can go online, see incoming job requests, accept/decline them, and advance an accepted job through its status lifecycle — with the customer's tracking view reflecting each change live.

**Independent Test**: Log in as a verified mechanic, go online, receive a job alert, accept it, and move it through en route → in progress → completed; confirm a second mechanic never sees it as still acceptable, and a customer with the tracking page open sees each status change without refreshing.

### Backend (new WebSocket surface — see spec.md Clarifications, contracts/websocket.md)

- [X] T006 [US1] In `backend/apps/dispatch/views.py`, after a successful status write, add `async_to_sync(get_channel_layer().group_send)(f"tracking_{sr.id}", {"type": "status.update", "status": sr.status, "service_request_id": str(sr.id)})` to both `ServiceRequestAcceptView.post()` and `ServiceRequestStatusUpdateView.patch()`.
- [X] T007 [US1] In `backend/apps/tracking/consumers.py`, add a `status_update(self, event)` handler to `TrackingConsumer` that `await self.send_json({"event": "status_update", "status": event["status"], "service_request_id": event["service_request_id"]})` — mirrors the existing `location_update()` handler. Depends on: T006 (same event `type` string).
- [X] T008 [P] [US1] Write `backend/apps/dispatch/tests/test_status_broadcast.py` (pytest-django + `channels.testing`, matching `backend/apps/tracking/tests/test_consumer.py`'s pattern): assert `status.update` is sent on `/accept` and on each allowed `/status` transition, and NOT sent on a rejected transition. Depends on: T006, T007.

### Frontend

- [X] T009 [P] [US1] Create `web/src/components/mechanic/AvailabilityToggle.tsx` — a client component calling `PATCH /providers/me/availability` (via `apiFetch`) to flip `is_available`, showing the current state (FR-002).
- [X] T010 [P] [US1] Create `web/src/components/mechanic/JobQueueList.tsx` — fetches `GET /service-requests` (unfiltered — the `MECHANIC`-role scoping in `ServiceRequestListCreateView.get()` already returns every open mechanic job plus this mechanic's own active ones), lists each with problem description + pickup location, and Accept/Decline actions per row. Decline removes the row from local component state only — no backend call (research.md's "Declining a job" decision) — and links each row to `/mechanic/jobs/{id}` (FR-003, FR-004).
- [X] T011 [US1] Create `web/src/app/mechanic/page.tsx` (the dashboard) composing `AvailabilityToggle` and `JobQueueList`. Depends on: T009, T010, T005.
- [X] T012 [P] [US1] Create `web/src/components/mechanic/JobStatusControl.tsx` — for a `PENDING` job offered to this mechanic, an Accept button (`POST /service-requests/{id}/accept`); for an assigned job, buttons to advance `EN_ROUTE → IN_PROGRESS → COMPLETED` (`PATCH /service-requests/{id}/status`), each disabled unless it's a currently-allowed transition per `backend/apps/dispatch/services/transitions.py`'s `ALLOWED_TRANSITIONS`/`_ROLES_BY_TARGET` (FR-004, FR-005), surfacing the `409` "already accepted by another provider" response as a clear message rather than a crash (edge case).
- [X] T013 [US1] Create `web/src/app/mechanic/jobs/[id]/page.tsx` — fetches `GET /service-requests/{id}`, renders job detail + `JobStatusControl`, and leaves a mount point (e.g. a labeled section/comment) for the parts-sourcing form that Phase 5 (US3) wires in. Depends on: T012, T005.
- [X] T014 [US1] In `web/src/components/tracking/TrackingMap.tsx`, add an `initialStatus: ServiceRequestStatus` prop, hold it in `useState`, branch the existing `socket.onmessage` handler on `data.event === "status_update"` to update that state (leaving the existing `{lat,lng}`-shaped branch untouched), and render `<ServiceRequestStatusBadge status={status} />` from within this component (contracts/websocket.md).
- [X] T015 [US1] Update `web/src/components/tracking/TrackingMapClientOnly.tsx` to accept and forward `initialStatus`, and update `web/src/app/track/[serviceRequestId]/page.tsx` to pass `initialStatus={serviceRequest.status}` and remove the now-redundant static `<ServiceRequestStatusBadge>` it currently renders directly (SC-002). Depends on: T014, T006, T007.

**Checkpoint**: User Story 1 is fully functional and independently testable (quickstart.md Story 1).

---

## Phase 4: User Story 2 - Review earnings and job history (Priority: P2)

**Goal**: A mechanic can review completed jobs and what they were paid, over a selectable period.

**Independent Test**: Log in as a mechanic with completed job history, select a date range, and confirm the earnings total and per-job breakdown match what was actually paid.

### Backend (new self-scoped endpoint — see spec.md Clarifications, contracts/rest.md)

- [X] T016 [US2] In `backend/apps/providers/views.py`, add `ProviderPayoutListView` (`generics.ListAPIView`, `permission_classes = [IsAuthenticated, IsMechanic]`, `serializer_class = PayoutSerializer` imported from `apps.admin_ops.serializers`) whose `get_queryset()` returns `Payout.objects.filter(provider=self.request.user).select_related("provider").prefetch_related("items")`, optionally filtered by `period_start`/`period_end` query params.
- [X] T017 [US2] In `backend/apps/providers/urls.py`, add `path("providers/me/payouts", ProviderPayoutListView.as_view(), name="provider-payouts")`. Depends on: T016.
- [X] T018 [P] [US2] Write `backend/apps/providers/tests/test_payouts.py`: happy path (mechanic sees only their own payouts, with items), empty-list case (no payouts yet, not an error), and RBAC (`401` unauthenticated, `403` non-mechanic, another mechanic's payouts never appear). Depends on: T016, T017.

### Frontend

- [X] T019 [P] [US2] Create `web/src/components/mechanic/PayoutPeriodPicker.tsx` — a date-range selector defaulting to a recent period (e.g. last 30 days), calling back with `period_start`/`period_end`.
- [X] T020 [P] [US2] Create `web/src/components/mechanic/EarningsSummary.tsx` — fetches `GET /providers/me/payouts` (forwarding the selected period), shows the summed total plus each payout's status and itemized `service_request` amounts, and an empty state when the list is empty (FR-007, edge case).
- [X] T021 [US2] Create `web/src/app/mechanic/earnings/page.tsx` composing `PayoutPeriodPicker` + `EarningsSummary`. Depends on: T019, T020, T005, T017.
- [X] T022 [P] [US2] Create `web/src/components/mechanic/JobHistoryTable.tsx` — fetches `GET /service-requests?status=COMPLETED`, lists date, job reference, and final fare per row, linking to `/mechanic/history/{id}`, with an empty state for no completed jobs (FR-006, edge case).
- [X] T023 [US2] Create `web/src/app/mechanic/history/page.tsx` rendering `JobHistoryTable`. Depends on: T022, T005.
- [X] T024 [US2] Create `web/src/app/mechanic/history/[id]/page.tsx` — fetches `GET /service-requests/{id}` (fare) and `GET /service-requests/{id}/parts-requests` (any parts-sourcing amounts), and cross-references `GET /providers/me/payouts` for the payout item covering this `service_request` to show pending/paid status (FR-007). Depends on: T005, T017.

**Checkpoint**: User Stories 1 AND 2 both work independently (quickstart.md Story 2).

---

## Phase 5: User Story 3 - Upload certifications and manage parts-sourcing requests (Priority: P3)

**Goal**: A mechanic can upload certification documents and submit/track parts-sourcing requests against an active job.

**Independent Test**: Upload a document and confirm it shows "pending verification"; separately, submit a parts request against an active job and confirm it appears pending, then confirm its status updates once the customer acts on it.

- [X] T025 [P] [US3] Create `web/src/components/mechanic/DocumentUploadList.tsx` — a multipart upload form (`POST /providers/me/documents`) with a clear failure state and retry (without creating a duplicate/partial entry — edge case), plus a list from `GET /providers/me/documents` showing each document's `verified` status (FR-008).
- [X] T026 [US3] Create `web/src/app/mechanic/documents/page.tsx` rendering `DocumentUploadList`. Depends on: T025, T005.
- [X] T027 [P] [US3] Create `web/src/components/mechanic/PartsSourcingRequestForm.tsx` — a part + quantity form posting to `POST /service-requests/{id}/parts-requests`, disabled (with an explanatory message) once the parent job's `status` is `COMPLETED` or `CANCELLED` (FR-010 edge case — a UI-only guard per data-model.md, layered on top of the server's existing assigned-provider/service-type checks), plus a list from `GET /service-requests/{id}/parts-requests` showing each request's status (pending/approved/rejected/ordered) (FR-009, FR-010).
- [X] T028 [US3] Wire `PartsSourcingRequestForm` into the mount point left in `web/src/app/mechanic/jobs/[id]/page.tsx`. Depends on: T013, T027.

**Checkpoint**: All three user stories are independently functional (quickstart.md Story 3).

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T029 [P] Run quickstart.md's full manual validation end-to-end (all three stories plus the two "Verifying the two new backend surfaces directly" pytest commands). Pytest half done — both suites pass (8/8; fixed a UUID-vs-str assertion bug in `test_payouts.py` along the way). The three manual browser story walkthroughs are still outstanding.
- [X] T030 [P] Spot-check FR-011 across every reused and new endpoint this feature touches (`/service-requests*`, `/providers/me/*`, `/parts-requests/*`) with a second mechanic account — confirm the first mechanic's jobs, earnings, documents, and parts requests never appear. Automated as `backend/apps/dispatch/tests/test_fr011_mechanic_isolation.py` (5 tests, all passing).
- [X] T031 Review loading/empty/error states across all `web/src/app/mechanic/**` pages for consistency with the existing `web/src/app/admin/**` conventions (spinners, empty-state copy, `ApiError` handling via `web/src/lib/api/errors.ts`).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories (every page renders inside T005's layout).
- **User Stories (Phase 3-5)**: All depend on Foundational. US1, US2 are independent of each other. US3 depends on US1 only for T028 (wiring its form into US1's job-detail page) — T025-T027 have no such dependency.
- **Polish (Phase 6)**: Depends on whichever stories are in scope for a given delivery.

### Within Each User Story

- US1: T006 → T007 → T008 (backend chain, then its test); T009, T010 (parallel) → T011; T012 → T013; T014 → T015 (needs T006/T007 live to be meaningful end-to-end, though it can be coded against contracts/websocket.md's payload shape beforehand).
- US2: T016 → T017 → T018 (backend chain, then its test); T019, T020 (parallel) → T021 (needs T017); T022 (parallel with T019/T020) → T023; T024 (needs T017).
- US3: T025 → T026; T027 (parallel with T025); T028 needs both T013 (US1) and T027.

### Parallel Opportunities

- Setup: T001 [P] alone (T002 is a manual/verification step, not parallel-meaningful).
- Foundational: T003 and T004 in parallel (different files); T005 waits on T003.
- US1: T009 and T010 in parallel; T012 in parallel with T009/T010 (different files); T008 can be drafted in parallel with T009-T015 once T006/T007 land.
- US2: T019, T020, T022 in parallel; T018 in parallel with the frontend tasks once T016/T017 land.
- US3: T025 and T027 in parallel.
- Different user stories (Phase 3 vs 4 vs 5) can be staffed in parallel once Phase 2 is done, except for US3's T028 → US1's T013 dependency noted above.

---

## Parallel Example: User Story 1

```bash
# After T006-T008 (backend) land, launch these together:
Task: "Create AvailabilityToggle component in web/src/components/mechanic/AvailabilityToggle.tsx"
Task: "Create JobQueueList component in web/src/components/mechanic/JobQueueList.tsx"
Task: "Create JobStatusControl component in web/src/components/mechanic/JobStatusControl.tsx"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup
2. Phase 2: Foundational (blocks everything)
3. Phase 3: User Story 1
4. **STOP and VALIDATE**: run quickstart.md's Story 1 section independently
5. Demo/deploy — a mechanic can already work a full shift from the portal

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. + User Story 1 → validate → demo (MVP)
3. + User Story 2 → validate → demo (earnings/history added)
4. + User Story 3 → validate → demo (documents + parts-sourcing added)
5. Polish

### Suggested Team Split

Once Phase 2 is done: one dev on US1's backend WebSocket piece (T006-T008) while another starts US1's frontend (T009-T015) against contracts/websocket.md's documented payload shape; a second dev/pair can start US2 in full parallel (independent of US1 entirely); US3's T025-T027 can start any time after Phase 2, with only T028 waiting on US1's T013.
