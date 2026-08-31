# Implementation Plan: Recovery & Towing Web Portal

**Branch**: `002-recovery-towing-web-portal` | **Date**: 2026-08-28 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-recovery-towing-web-portal/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command; its definition describes the execution workflow.

## Summary

A new role-gated section of the existing `web/` Next.js app (`/recovery/*`,
mirroring the established `/admin/*` and `/mechanic/*` pattern) giving a
verified `RECOVERY` operator a desktop operational surface: a live
multi-tow dispatch view (status + position for every active job at once,
reusing the admin fleet map's Leaflet pattern and the per-job tracking
WebSocket), a fare estimate shown before committing to a pending job
(already-computed data, purely surfaced), and a driver-performance view
(completed count, average rating, response time) over a selectable
period. Stories 1 and 2 are pure frontend onto already-running backend
capability (`apps/dispatch`'s `/service-requests` + `apps/tracking`'s
WebSocket). Story 3 needs the two small, explicitly-justified backend
additions recorded in spec.md's Clarifications: two new nullable
timestamp columns on `ServiceRequest` (`accepted_at`, `completed_at`)
and one new self-scoped performance-aggregation endpoint.

## Technical Context

**Language/Version**: TypeScript 5 (frontend, `web/`); Python 3.11+ /
Django (backend, `backend/`) — both already fixed by the running stack,
no new language.

**Primary Dependencies**: Next.js **16.3.1** App Router, React 19,
Tailwind CSS 4, `leaflet` + `react-leaflet` (frontend — all already in
`web/package.json`; the map libraries are exactly what
`web/src/components/admin/FleetMap.tsx` already uses for the admin fleet
map, reused here rather than adding a mapping dependency. Per
`web/AGENTS.md`, consult `node_modules/next/dist/docs/` for 16.x API
differences before writing route/layout code). Backend: Django REST
Framework, Django Channels (WebSocket), `rest_framework_simplejwt` — all
already in use, no new dependency.

**Storage**: PostgreSQL 16 + PostGIS (existing `service_requests`,
`provider_profiles`, `reviews` tables) — read via existing Django models
for Stories 1-2; Story 3 adds two nullable `DateTimeField` columns
(`accepted_at`, `completed_at`) to the existing `service_requests` table
via one migration — no new table.

**Testing**: `pytest-django` for the new timestamp-population paths and
the new performance endpoint (happy path + RBAC 401/403 + period edge
cases per FR-008), matching the existing `backend/apps/*/tests/`
convention (Constitution Principle IV). No frontend test framework
exists in this repo yet and this feature does not introduce one (raise
via `/speckit-clarify` if later needed, not decided silently here).

**Target Platform**: Server-rendered web app (desktop/tablet browser),
same as the rest of `web/`; Django backend already deployed for the
existing mobile + web clients.

**Project Type**: Web application — new routes/components inside the
existing single `web/` Next.js project, plus one small addition inside
the existing single `backend/` Django project. Not a new project.

**Performance Goals**: SC-001/SC-002 — every active job's status and
position visible within 5s of opening the portal, and every change
visible within 5s of occurring (met by reusing the already-open
per-job tracking WebSocket's `status_update`/`location_update` events
rather than polling — the same mechanism `web/src/app/track/[id]`
already uses, extended to render N simultaneous jobs instead of one).
SC-003/SC-004 are UX flow-length goals (fare estimate <10s, performance
lookup in ≤3 interactions), not raw throughput targets. FR-010 (status
changes reach the customer's tracking view) is already met by the
existing `status.update` broadcast added in 001-mechanic-web-portal —
this feature emits no new broadcast event, it only adds two `.save()`
field writes alongside the existing one.

**Constraints**: Every view MUST enforce FR-009 (an operator only ever
sees their own jobs/performance data) — already the enforcement shape of
every reused endpoint (`request.user`-scoped querysets); the one new
endpoint follows the same shape. No client-side reimplementation of fare
computation, currency formatting, or notification delivery (Constitution
Principle V) — `estimated_fare`/`final_fare` are displayed exactly as
`ServiceRequestSerializer` returns them, never recomputed client-side.

**Scale/Scope**: 3 user stories, ~5 screens/views (dispatch dashboard
w/ multi-job map + list, job detail w/ fare estimate, performance view
w/ driver + period selector), 1 new backend endpoint, 2 new nullable
columns on an existing table, 0 new WebSocket event types (reuses
`status.update`/`location.update` as-is).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Result |
|---|---|---|
| I. Fixed Stack, No Re-Architecture | Next.js App Router (`web/`) + Django REST/Channels (`backend/`) only; reuses `leaflet`/`react-leaflet` already installed for `admin/map`. No new framework/DB/client tech proposed. | **PASS** |
| II. Four-Role RBAC via One Enum | All new/reused endpoints gate on the existing `RECOVERY` value via `IsRecovery`/`role_permission()`; no new role, no client-side auth scheme. | **PASS** |
| III. Frontend-Onto-Existing-Backend | Stories 1-2 (multi-tow dispatch view, fare estimate) are pure frontend onto existing endpoints (`GET /service-requests`, the tracking WebSocket, `estimated_fare`/`final_fare` already on `ServiceRequestSerializer`). The 1 gap found (self-scoped, period-aggregated performance data) is documented in spec.md's Clarifications with why reuse wasn't possible, per this principle's own escape hatch — not added silently. | **PASS (1 justified addition — see Complexity Tracking)** |
| IV. Test-First on the Backend | The backend addition gets `pytest-django` tests (happy path + RBAC + FR-008's zero-data-distinction case) written alongside it, matching `backend/apps/*/tests/`. No new frontend test framework invented. | **PASS** |
| V. Tanzania Market Constraints Are Display-Only | Fare amounts shown exactly as `ServiceRequestSerializer` returns them; no client-side recomputation of the fare formula (`apps/dispatch/services/fare.py` stays the only place that runs). | **PASS** |

No unresolved conflicts. Proceeding to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/002-recovery-towing-web-portal/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
backend/apps/dispatch/
├── models.py             # + ServiceRequest.accepted_at, .completed_at (nullable DateTimeField)
├── migrations/
│   └── 000N_servicerequest_accepted_completed_at.py   # new
├── views.py              # ServiceRequestAcceptView + .completed transition: set accepted_at/completed_at
│                          #   + new ProviderPerformanceView (self-scoped, IsRecovery)
├── urls.py                # + GET /providers/me/performance  (co-located here: reads ServiceRequest+Review,
│                           #   mirrors where PartsSourcingRequest/Review already live relative to their source table)
└── tests/
    └── test_performance.py   # new

web/src/app/recovery/
├── layout.tsx              # role+verification gate (IsRecovery && is_verified), nav — mirrors mechanic/layout.tsx
├── page.tsx                 # dispatch dashboard: multi-job map + active job list (Story 1)
├── jobs/[id]/page.tsx        # job detail: fare estimate (pending) / estimate+final (completed) (Story 2)
└── performance/page.tsx       # driver performance: period selector + completed/rating/response-time (Story 3)

web/src/components/recovery/
├── ActiveTowMap.tsx          # multi-marker Leaflet map — adapts FleetMap.tsx's single-provider-per-marker
│                              #   pattern to one-marker-per-active-job, reusing the same library, not duplicating
│                              #   a new mapping approach
├── ActiveJobList.tsx
├── FareEstimateCard.tsx
└── PerformanceSummary.tsx

web/src/lib/
└── types.ts               # + ProviderPerformance shape
```

**Structure Decision**: Web application option — new work lands inside
the existing single `web/` Next.js project (new `web/src/app/recovery/*`
route group, new `web/src/components/recovery/*`) and the existing
single `backend/` Django project (`apps/dispatch`), matching every prior
in-flight portal (`web/src/app/admin/*`, `web/src/app/mechanic/*`,
`web/src/app/track/*`). No new project, package, or service is created.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| New columns: `ServiceRequest.accepted_at`, `.completed_at` | FR-007's "typical response time" and FR-008's period-bounded completed count need per-job accept/complete timestamps; today only `created_at` exists. | Deriving response time from existing data was rejected — no other table records when a job was accepted or completed, so there is nothing to derive it from without a schema change. |
| New endpoint: `GET /providers/me/performance` | FR-007 requires a period-scoped, self-scoped aggregate (completed count, average rating, average response time). `AdminAnalyticsView` is `IsAdmin`-only, un-scoped to one provider, and not period-filterable; `ProviderProfile.rating` is a lifetime running average (`apps/providers/signals.py`), not period-filterable. | Reusing `AdminAnalyticsView` was rejected (wrong permission class, wrong shape — global not per-provider). Computing the average rating client-side was rejected — there is no endpoint that lists a provider's own `Review` rows at all, so the client has nothing to aggregate from without a new endpoint. |

## Extension Hooks

No `.specify/extensions.yml` found — before/after-plan hooks skipped.
