# Feature Specification: Mechanic Web Portal

**Feature Branch**: `001-mechanic-web-portal`

**Created**: 2026-08-28

**Status**: Draft

**Input**: User description: "Mechanic web portal: operational dashboard, earnings analytics, job history, certification/document uploads, parts sourcing requests"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Manage today's jobs from a desktop (Priority: P1)

A mechanic who has signed up and is verified opens the web portal on a
desktop or tablet at the start of a shift, toggles online, and manages
incoming job requests without needing their phone: reviewing job details,
accepting or declining, and updating a job's status as work proceeds.

**Why this priority**: This is the operational core the role matrix
promises ("Operational portal") — without it, the web portal has no
reason to exist alongside the mobile app that already covers this flow.

**Independent Test**: Can be fully tested by logging in as a verified
mechanic, going online, receiving a job alert, accepting it, and moving it
through its status lifecycle to completion — deliverable and demoable on
its own even before earnings/history/documents/parts-sourcing exist.

**Acceptance Scenarios**:

1. **Given** a verified, logged-in mechanic, **When** they toggle
   themselves online, **Then** the portal shows their current
   availability state and they begin receiving new job requests.
2. **Given** an incoming job request, **When** the mechanic accepts it,
   **Then** the job moves to "accepted" and is no longer offered to other
   mechanics.
3. **Given** an accepted job, **When** the mechanic updates its status
   (en route → in progress → completed), **Then** the customer's own view
   of that job reflects the same status without delay.
4. **Given** a job the mechanic has not yet responded to, **When** they
   decline it, **Then** it is offered to another available mechanic
   instead.

---

### User Story 2 - Review earnings and job history (Priority: P2)

A mechanic reviews completed jobs and what they were paid for each, over a
selectable time period, to track income and reconcile against expectations
before a payout cycle.

**Why this priority**: Earnings visibility is explicitly promised in the
role matrix and is the main reason a mechanic would prefer the web portal
over the phone for a periodic review task — but the business runs fine
without it on day one; jobs already complete and payouts already happen
without this view.

**Independent Test**: Can be fully tested by logging in as a mechanic with
completed job history, selecting a date range, and confirming the
earnings total and per-job breakdown match what was actually paid —
independent of whether job management (Story 1) or document upload
(Story 3) exist yet.

**Acceptance Scenarios**:

1. **Given** a mechanic with completed jobs, **When** they open the
   earnings view, **Then** they see total earnings for a default recent
   period and can change the period.
2. **Given** a completed job, **When** the mechanic opens its detail from
   history, **Then** they see the fare, any parts-sourcing amounts tied
   to it, and its payout status (pending/paid).
3. **Given** a mechanic with no completed jobs yet, **When** they open
   earnings or history, **Then** they see an empty state rather than an
   error.

---

### User Story 3 - Upload certifications and manage parts-sourcing requests (Priority: P3)

A mechanic uploads certification/qualification documents for admin
verification, and — while working a job — requests specific spare parts
for the customer to approve and purchase.

**Why this priority**: Both are real promised capabilities (role matrix:
"certification uploads", "parts sourcing requests") but are periodic/
occasional actions, not the daily-use core — the portal is still useful
without them on day one.

**Independent Test**: Can be fully tested by uploading a document and
confirming it appears with a "pending verification" state, and separately
by submitting a parts request against an active job and confirming it
appears in a pending state visible to the customer — each independent of
the other stories.

**Acceptance Scenarios**:

1. **Given** a mechanic on their profile/documents view, **When** they
   upload a certification file, **Then** it appears in their document
   list as pending verification.
2. **Given** a mechanic working an active job, **When** they submit a
   parts-sourcing request (part + quantity), **Then** it appears as
   pending until the customer approves, rejects, or it converts to an
   order.
3. **Given** a previously submitted parts request, **When** its status
   changes (approved/rejected/ordered), **Then** the mechanic sees the
   updated status without having to re-submit anything.

### Edge Cases

- What happens when a mechanic tries to accept a job that another
  mechanic accepted a moment earlier? The portal MUST show the job as no
  longer available rather than letting the mechanic act on a stale job.
- What happens when a mechanic goes offline while a job is still
  in-progress? The in-progress job MUST remain assigned to them and
  actionable; only new job offers stop.
- What happens when a document upload fails partway (bad file, network
  drop)? The mechanic MUST see a clear failure state and be able to retry
  without duplicating a partial document entry.
- What happens when a mechanic requests parts for a job that has since
  been cancelled or completed? The portal MUST prevent submitting a new
  parts request against a job that's no longer active.
- What happens when a mechanic has never completed a job? Earnings/history
  MUST show a clear zero/empty state, not a broken chart or error.

## Clarifications

### Session 2026-08-28 (surfaced during `/speckit-plan`)

Per the constitution's Principle III ("Frontend-Onto-Existing-Backend"), a
new backend surface may only be added once the gap is documented here,
with why reuse isn't possible. Planning found exactly two:

- **Q: FR-007 needs each mechanic's own earnings/payouts. The only
  existing payout read endpoint (`GET /admin/payouts`,
  `apps/admin_ops`) is `IsAdmin`-only — an admin-wide list, not
  self-scoped. Reuse isn't possible as-is; how should the mechanic
  read their own payouts?**
  **A**: Add one new self-scoped endpoint, `GET /providers/me/payouts`,
  following the exact precedent already set by
  `GET /providers/me/documents` (a "flagged addition" self-scoped GET
  next to an admin-only equivalent, `apps/providers/views.py`). It
  reuses the existing `Payout`/`PayoutItem` models and
  `PayoutSerializer` (`apps/admin_ops`) unchanged, filtered to
  `provider=request.user`, `IsMechanic`-gated (a mechanic's own record
  only, per FR-011). No new model, no new admin-facing behavior.

- **Q: FR-012/SC-002 need job status changes to reach the customer's
  tracking view within 5s without a manual refresh. The existing
  tracking WebSocket (`apps/tracking`, `ws://.../tracking/{id}/`,
  already consumed by `web/src/app/track/[serviceRequestId]`) only
  ever broadcasts a `location.update` event (provider lat/lng) — a
  status change made via `PATCH /service-requests/{id}/status` or
  `POST /service-requests/{id}/accept` today reaches the customer only
  on their next full page load. Reuse isn't possible as-is (the
  channel exists but the event doesn't); how should status changes
  reach the open tracking view live?**
  **A**: Extend the same already-open `tracking_{service_request_id}`
  Channels group (no new channel, no new client connection) with a
  second server-initiated event type, `status.update`, sent via
  `channel_layer.group_send` (through `async_to_sync`, this codebase's
  first sync→async Channels call, needed because
  `ServiceRequestAcceptView`/`ServiceRequestStatusUpdateView` are
  regular sync DRF views) whenever those views change `.status`. The
  customer's already-connected tracking socket handles the new event
  type the same way it already handles `location_update`. Declining a
  job is not part of this: it stays a client-side dismissal (no
  backend "declined" state exists or is added — a declined job simply
  remains `PENDING` and continues to be offered to every other
  matching mechanic, which is already how `GET /service-requests`
  filters for the `MECHANIC` role today).

No other gap was found: job list/history reuses
`GET /service-requests` (already filters to `provider=request.user`
for the MECHANIC role); parts-sourcing reuses
`apps/dispatch`'s existing `parts-requests` endpoints unchanged;
certification uploads reuse `apps/providers`'s existing
`provider_documents` endpoints unchanged; and the "verified mechanic
account" gate in FR-001 reuses the existing `GET /users/me`
(`is_verified` is already one of `MeSerializer`'s fields) rather than
adding a JWT claim.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The portal MUST require the user to be logged in with a
  verified mechanic account before showing any operational content.
- **FR-002**: The portal MUST let the mechanic view and toggle their own
  online/offline availability.
- **FR-003**: The portal MUST show the mechanic incoming job requests
  matched to them, including problem description and pickup location.
- **FR-004**: The portal MUST let the mechanic accept or decline an
  offered job, and MUST prevent acting on a job that is no longer
  available (already taken, cancelled, or expired).
- **FR-005**: The portal MUST let the mechanic advance an accepted job
  through its status lifecycle (e.g. en route, in progress, completed).
- **FR-006**: The portal MUST show the mechanic a list of their completed
  jobs (history), each with date, customer-facing job reference, and
  final fare.
- **FR-007**: The portal MUST show the mechanic their earnings summed over
  a selectable period, and MUST show each job's payout status
  (pending/paid).
- **FR-008**: The portal MUST let the mechanic upload certification/
  qualification documents and see each document's verification status.
- **FR-009**: The portal MUST let the mechanic submit a parts-sourcing
  request (spare part + quantity) against an active job they are working.
- **FR-010**: The portal MUST show the mechanic the status of their
  parts-sourcing requests (pending, approved, rejected, ordered) and MUST
  prevent submitting a new one against a job that is no longer active.
- **FR-011**: The portal MUST only ever show a mechanic their own jobs,
  earnings, documents, and parts requests — never another mechanic's or
  another role's data.
- **FR-012**: Job status changes made from the portal MUST be reflected in
  the customer's own tracking view without the customer needing to
  refresh manually.

### Key Entities

- **Mechanic profile**: The logged-in mechanic's identity, availability
  state, and verification status.
- **Job (service request)**: A mechanic-service job — status, pickup
  location, problem description, assigned mechanic, fare.
- **Job history entry**: A completed job as shown in the mechanic's
  history/earnings view — read view onto completed jobs plus their
  payout linkage.
- **Payout**: A period's aggregated earnings for the mechanic, and the
  per-job amounts making it up.
- **Certification document**: A file the mechanic uploaded, plus its
  verification status.
- **Parts-sourcing request**: A specific part + quantity requested by the
  mechanic against a job, its status, and (once ordered) the resulting
  order.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A verified mechanic can go from login to viewing an
  incoming job's full detail in under 10 seconds.
- **SC-002**: 100% of job status changes made in the portal are visible
  in the customer's tracking view within 5 seconds.
- **SC-003**: A mechanic can find their total earnings for a given period
  in 3 or fewer interactions from login.
- **SC-004**: Zero job double-accepts are observable from the portal —
  a job already taken never appears acceptable to a second mechanic.
- **SC-005**: A mechanic can submit a parts-sourcing request against an
  active job in under 1 minute.

## Assumptions

- Mechanics already have verified accounts and a mobile app they use
  today for the same job lifecycle — this portal is an additional desktop
  surface for the same mechanic, not a new registration flow.
- All data shown (jobs, earnings, payouts, documents, parts requests) is
  sourced from the existing platform's already-running services for
  dispatch, payouts, document storage, and parts sourcing — this feature
  is a new way to see and act on existing capability, not a new backend
  system of record.
- "Earnings" in this feature means the mechanic's own payout history and
  totals as already computed by the platform, not a new compensation
  model or rate calculation.
- Document verification (approving/rejecting an uploaded certification)
  is performed by an admin elsewhere, not by the mechanic — this feature
  only covers the mechanic's upload and status-viewing side.
- Parts-sourcing approval is performed by the customer elsewhere — this
  feature only covers the mechanic's request-submission and
  status-viewing side.
