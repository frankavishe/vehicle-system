# Implementation Plan: Mechanic Web Portal

**Branch**: `001-mechanic-web-portal` | **Date**: 2026-08-28 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-mechanic-web-portal/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command; its definition describes the execution workflow.

## Summary

A new role-gated section of the existing `web/` Next.js app
(`/mechanic/*`, mirroring the established `/admin/*` pattern) giving a
verified `MECHANIC` a desktop operational surface: go online/offline,
manage incoming/active jobs through their status lifecycle, review
earnings and job history, upload certification documents, and submit
parts-sourcing requests. It is a pure frontend build onto already-running
backend capability (`apps/providers`, `apps/dispatch`,
`apps/admin_ops`), plus the two small, explicitly-justified backend
additions recorded in spec.md's Clarifications: one self-scoped payouts
read endpoint, and one new WebSocket event type on the already-open
tracking channel so job-status changes reach the customer's tracking view
live instead of only on next page load.

## Technical Context

**Language/Version**: TypeScript 5 (frontend, `web/`); Python 3.11+ /
Django (backend, `backend/`) — both already fixed by the running stack,
no new language.

**Primary Dependencies**: Next.js **16.3.1** App Router, React 19,
Tailwind CSS 4 (frontend — all already in `web/package.json`; note the
constitution's stack description says "Next.js 14" but the installed,
running version is 16.3.1 — an App Router upgrade already made
elsewhere in this repo, not a decision this feature makes. `web/AGENTS.md`
flags this explicitly: consult `node_modules/next/dist/docs/` for
16.x API differences before writing route/layout code). Backend: Django
REST Framework, Django Channels (WebSocket), `rest_framework_simplejwt`
— all already in use, no new dependency.

**Storage**: PostgreSQL 16 + PostGIS (existing `provider_profiles`,
`service_requests`, `parts_sourcing_requests`, `provider_documents`,
`payouts`, `payout_items` tables) — read/write via existing Django
models only; no new tables, no migration.

**Testing**: `pytest-django` for the one new backend view
(`GET /providers/me/payouts`) and the extended status-broadcast path,
matching the existing `backend/apps/*/tests/` convention (happy path +
RBAC 401/403, per Constitution Principle IV). No frontend test framework
exists in this repo yet and this feature does not introduce one
(Principle IV — raise via `/speckit-clarify` if that's later needed, not
decided silently here).

**Target Platform**: Server-rendered web app (desktop/tablet browser),
same as the rest of `web/`; Django backend already deployed for the
existing mobile + web clients.

**Project Type**: Web application — new routes/components inside the
existing single `web/` Next.js project, plus two small additions inside
the existing single `backend/` Django project. Not a new project.

**Performance Goals**: SC-002 — a job-status change is visible in the
customer's open tracking view within 5s (met by pushing over the
already-open WebSocket rather than polling). SC-001/SC-003/SC-005 are UX
flow-length goals (login→job detail <10s, earnings in ≤3 interactions,
parts request <1min), not raw throughput targets — no new backend load
profile beyond what `apps/dispatch`/`apps/providers` already serve for
the mobile app doing the same job lifecycle.

**Constraints**: Every view MUST enforce FR-011 (a mechanic only ever
sees their own jobs/earnings/documents/parts-requests) — already the
enforcement shape of every reused endpoint (`request.user`-scoped
querysets); the one new endpoint follows the same shape. No client-side
reimplementation of currency formatting, gateway selection, or
notification delivery (Constitution Principle V) — payout amounts,
statuses, and gateways are displayed as returned by
`PayoutSerializer`/`ServiceRequestSerializer`, not recomputed.

**Scale/Scope**: 3 user stories, ~9 screens/views (dashboard w/
availability toggle + job queue, job detail, earnings, job history +
history detail, documents/upload, parts-sourcing request form + list),
1 new backend endpoint, 1 new WebSocket event type on an existing
channel.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Result |
|---|---|---|
| I. Fixed Stack, No Re-Architecture | Next.js App Router (`web/`) + Django REST/Channels (`backend/`) only; no new framework/DB/client tech proposed. | **PASS** |
| II. Four-Role RBAC via One Enum | All new/reused endpoints gate on the existing `MECHANIC` value via `IsMechanic`/`role_permission()`; no new role, no client-side auth scheme. | **PASS** |
| III. Frontend-Onto-Existing-Backend | 4 of 5 capability areas (jobs, history, documents, parts-sourcing) are pure frontend onto existing endpoints. The 2 gaps found (self-scoped payouts read; live status push) are documented in spec.md's Clarifications with why reuse wasn't possible, per this principle's own escape hatch — not added silently. | **PASS (2 justified additions — see Complexity Tracking)** |
| IV. Test-First on the Backend | The 2 backend additions get `pytest-django` tests (happy path + RBAC) written alongside them, matching `backend/apps/*/tests/`. No new frontend test framework invented. | **PASS** |
| V. Tanzania Market Constraints Are Display-Only | Earnings/payout amounts, gateway, currency shown exactly as `PayoutSerializer`/`ServiceRequestSerializer` return them; no client-side recomputation. | **PASS** |

No unresolved conflicts. Proceeding to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/001-mechanic-web-portal/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
backend/apps/providers/
├── views.py             # + ProviderPayoutListView (new, self-scoped)
├── urls.py               # + GET /providers/me/payouts
└── tests/
    └── test_payouts.py   # new

backend/apps/dispatch/
├── views.py              # ServiceRequestAcceptView, ServiceRequestStatusUpdateView
│                          #   + group_send("status.update") on status change
└── tests/
    └── test_status_broadcast.py  # new

backend/apps/tracking/
└── consumers.py           # + status_update() handler (mirrors location_update())

web/src/app/mechanic/
├── layout.tsx             # role+verification gate (IsMechanic && is_verified), nav — mirrors admin/layout.tsx
├── page.tsx                # dashboard: availability toggle + incoming/active job queue (Story 1)
├── jobs/[id]/page.tsx       # job detail: accept/decline, status advance, parts-sourcing request form (Stories 1, 3)
├── earnings/page.tsx        # earnings summary + period selector (Story 2)
├── history/page.tsx         # completed job history list (Story 2)
├── history/[id]/page.tsx     # history detail: fare, parts amounts, payout status (Story 2)
└── documents/page.tsx        # certification upload + list w/ verification status (Story 3)

web/src/components/mechanic/
├── AvailabilityToggle.tsx
├── JobQueueList.tsx
├── JobStatusControl.tsx
├── PartsSourcingRequestForm.tsx
├── EarningsSummary.tsx
├── PayoutPeriodPicker.tsx
├── JobHistoryTable.tsx
└── DocumentUploadList.tsx

web/src/lib/
├── types.ts               # + Payout self-scoped shape reuse (already defined), MeResponse (is_verified)
└── ws/
    └── tracking.ts          # extend existing tracking socket handling (status.update alongside location_update) — used by web/src/app/track too, shared not duplicated
```

**Structure Decision**: Web application option — new work lands inside
the existing single `web/` Next.js project (new `web/src/app/mechanic/*`
route group, new `web/src/components/mechanic/*`) and the existing single
`backend/` Django project (`apps/providers`, `apps/dispatch`,
`apps/tracking`), matching every prior in-flight portal (`web/src/app/
admin/*`, `web/src/app/track/*`). No new project, package, or service is
created.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| New endpoint: `GET /providers/me/payouts` | FR-007 requires a mechanic to read their own earnings; the only existing payout-read endpoint (`GET /admin/payouts`) is `IsAdmin`-only. | Loosening `AdminPayoutListView`'s permission to also allow `IsMechanic` was rejected — it would let a mechanic pass `?provider=<other-id>` and read another mechanic's payouts (violates FR-011); a self-scoped view is the smaller, correctly-scoped change. |
| New WebSocket event: `status.update` on the existing tracking channel | FR-012/SC-002 require live status propagation to the customer's already-open tracking view; the channel exists but only ever sends `location.update`. | Polling `GET /service-requests/{id}` from the customer's tracking page every few seconds was rejected — it duplicates the real-time infra the constitution already commits to (Django Channels, Principle I) instead of extending the one connection that page already holds open. |

## Extension Hooks

No `.specify/extensions.yml` found — before/after-plan hooks skipped.
