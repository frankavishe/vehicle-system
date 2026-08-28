<!--
Sync Impact Report
- Version change: (none) → 1.0.0 (initial ratification)
- Principles established:
  1. Fixed Stack, No Re-Architecture
  2. Four-Role RBAC via One Enum
  3. Frontend-Onto-Existing-Backend (Reuse Before New Endpoints)
  4. Test-First on the Backend (NON-NEGOTIABLE)
  5. Tanzania Market Constraints Are Display-Only Downstream
- Added sections: Reuse Map for In-Flight Gaps, Spec-Kit Workflow, Governance
- Removed sections: none (initial document)
- Templates requiring follow-up: none — this file only governs new spec-kit
  work; existing `.specify/templates/*` are unmodified.
- Deferred TODOs: none
-->

# AutoServe Constitution

## Core Principles

### I. Fixed Stack, No Re-Architecture
The technology stack is locked by prior engineering decisions in `PLAN.md`
and already-shipped code: Django REST (`backend/`) on Postgres 16 +
PostGIS, Redis + Celery for async/queueing, Django Channels for
WebSockets, Next.js 14 App Router (`web/`), and Flutter (`mobile/`). New
work MUST build inside this stack. Proposing a different framework,
database, or client technology for a new feature requires a constitution
amendment first, not a unilateral choice inside a feature spec.

**Rationale**: Four Phases of this stack are already code-complete and
tested (see `phase.md`). Re-litigating stack choices per-feature would
fragment a system that has already paid its architecture cost once.

### II. Four-Role RBAC via One Enum
There are exactly four roles: `CUSTOMER`, `MECHANIC`, `RECOVERY` (display
name "Emergency Car Recovery & Towing"), `ADMIN` — the `user_role` enum in
`backend/apps/users`. All authorization MUST go through the existing RBAC
permission classes (`backend/apps/common/permissions.py`'s
`role_permission()` factory and its `IsAdmin`/`IsCustomer`/`IsMechanic`/
`IsRecovery`/`IsProvider` products), not a new auth scheme per portal. A
fifth role, or a role rename, requires a constitution amendment — it is
not a decision a single feature spec can make.

**Rationale**: JWT issuance, RBAC middleware, and every existing endpoint
already assume exactly these four roles; splitting or adding roles
silently inside a feature would desync the backend's actual enforcement
from what the spec claims.

### III. Frontend-Onto-Existing-Backend (Reuse Before New Endpoints)
New portals and screens are, by default, new frontend surfaces onto
capability the backend already exposes. A feature spec MUST identify
which existing endpoints/models it consumes (see "Reuse Map" below) before
proposing any new backend endpoint, model, or migration. A new backend
surface is permitted only when the spec's Clarifications section
explicitly documents the gap and why reuse isn't possible — it is never
added silently during planning or implementation.

**Rationale**: The backend (8 Django apps, Phases 1-4) already covers
auth, catalog, orders, dispatch, tracking, notifications, and admin ops.
Most remaining role/platform gaps are missing UI, not missing capability.

### IV. Test-First on the Backend (NON-NEGOTIABLE)
Any backend change (new endpoint, new field, new business logic) follows
the pattern already established in `backend/apps/*/tests/`: pytest-django
tests covering the happy path plus RBAC 401/403 negative paths, written
alongside the change, not deferred. This project has no established
frontend (Next.js/Flutter) test convention yet — do not invent one
unprompted inside a feature; if a spec needs frontend test coverage,
raise it explicitly via `/speckit-clarify` rather than assuming a
framework.

**Rationale**: Matches the existing bar (51/51 backend tests passing as
of Phase 2) rather than lowering it for new work, while not forcing an
unplanned frontend-testing framework choice into an unrelated feature.

### V. Tanzania Market Constraints Are Display-Only Downstream
Currency (TZS), the Flutterwave + Selcom dual payment-gateway split, and
FCM + Beem SMS notification delivery are fully implemented server-side
(`PLAN.md` §5.3-§5.4). New client surfaces (web or mobile) MUST treat
fares, payouts, and payment status as data to *display*, sourced from
existing endpoints — they MUST NOT re-implement gateway selection,
currency formatting rules, or notification delivery logic client-side.

**Rationale**: Duplicating this logic in a new portal risks drifting from
the single source of truth already tested and running in `apps/orders`,
`apps/admin_ops`, and `apps/notifications`.

## Reuse Map for In-Flight Gaps
<!-- Concrete pointer for the 3 currently-known role/platform gaps -->

- **Mechanic web portal**: `apps/providers` (`/providers/me/*`),
  `apps/dispatch` (`/service-requests`), `apps/orders`
  (`parts_sourcing_requests` endpoints), `apps/providers`
  (`provider_documents` upload), earnings via `apps/admin_ops` payout
  endpoints scoped to `request.user`.
- **Recovery/Towing web portal**: `/service-requests` + the tracking
  WebSocket (`apps/tracking`, already consumed by
  `web/src/app/track/[id]`) + the PostGIS live-position pattern already
  built for `web/src/app/admin/map`.
- **Admin mobile app**: `apps/admin_ops` (`/admin/disputes`,
  `/admin/analytics`, `/admin/payouts`) — the same endpoints the existing
  admin **web** console already calls.

This list is illustrative, not exhaustive — it exists so a feature spec
starts from "what do I reuse" rather than "what do I build."

## Spec-Kit Workflow

- Spec-kit (`/speckit-*`) governs **new and in-flight work only**.
  Phases 1-4 (already code-complete per `phase.md`) are not retroactively
  spec'd — `PLAN.md`, `phase.md`, and `work.md` remain the historical
  record for that work and stay authoritative for decisions already made
  there (payment routing, notification fallback rules, distance-calc
  fallback, etc.). A spec-kit feature MUST NOT silently re-decide
  something `PLAN.md` already settled; if it needs to, that's an
  amendment to `PLAN.md`/this constitution, called out explicitly.
- Each new feature (e.g. one of the 3 in-flight portal gaps) gets its own
  `/speckit-specify` → `/speckit-plan` → `/speckit-tasks` cycle on its own
  feature branch. `/speckit-clarify` runs before `/speckit-plan` whenever
  the spec has open ambiguity.
- `/speckit-implement` for a feature only runs after its spec, plan, and
  tasks have been reviewed — spec-kit's per-gate review is intentional,
  not a formality to skip for speed.

## Governance

This constitution supersedes ad-hoc practice for any new spec-kit feature.
`PLAN.md` is not overridden by this document — it remains the record of
architecture decisions already made (stack, market, payments,
notifications) and this constitution's principles exist to keep new work
consistent with it, not to replace it.

Amendments: proposed via `/speckit-constitution`, versioned per semantic
versioning (MAJOR: incompatible principle removal/redefinition; MINOR: new
principle or materially expanded guidance; PATCH: wording/clarification),
with a Sync Impact Report prepended to this file on every change.
Compliance: every `/speckit-plan` MUST check its approach against these
principles before tasks are generated; unresolved conflicts block
`/speckit-tasks`, not silently pass through to `/speckit-implement`.

**Version**: 1.0.0 | **Ratified**: 2026-08-28 | **Last Amended**: 2026-08-28
