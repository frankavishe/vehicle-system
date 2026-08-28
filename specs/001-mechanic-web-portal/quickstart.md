# Quickstart: Validating the Mechanic Web Portal

Manual end-to-end validation, one scenario per user story plus the two
new-surface additions. Assumes the existing local dev setup (Postgres +
PostGIS, Redis, Django backend on `:8000` with Channels, Next.js `web/`
on `:3000`) already runs the other portals (`/admin`, `/track`) —
if not, follow `web/README`/`backend/README` (or `PLAN.md` §2) first.

## Prerequisites

- A `MECHANIC`-role user with `is_verified=True` (create via Django
  admin or `is_verified` factory default, per
  `backend/apps/users/tests/factories.py`) and its `ProviderProfile`
  (auto-created by `apps/providers/signals.py` on user creation).
- A `CUSTOMER`-role user, logged in on a second browser/incognito
  session, for the live-status-push check.
- At least one `SpareVehiclePart`/spare part in the catalog, for the
  parts-sourcing step.

## Story 1 — Manage today's jobs (P1)

1. Log in as the mechanic at `/login`, land on `/mechanic`.
2. Toggle online (`PATCH /providers/me/availability`) — confirm the UI
   reflects `is_available: true`.
3. As the customer (second session), create a `MECHANIC`-type service
   request (`POST /service-requests`) — confirm it appears in the
   mechanic's job queue within one refresh/poll cycle.
4. Accept the job from the portal — confirm: (a) the job now shows
   `ACCEPTED`, (b) re-querying `/service-requests` no longer shows it as
   available to a second mechanic (SC-004).
5. Advance status `EN_ROUTE → IN_PROGRESS → COMPLETED` from the portal.
   **With the customer's `/track/{id}` page open in the other session**,
   confirm each status change appears there **without a manual
   refresh**, within ~5s (SC-002; validates the new `status.update`
   WebSocket event — contracts/websocket.md).
6. Separately, have the customer create a second job; from the
   mechanic's queue, decline it — confirm it's gone from this mechanic's
   queue but (per research.md's decision) reappears on a hard refresh,
   and remains offered to any other mechanic throughout.

**Expected outcome**: SC-001 (login→job detail <10s) and SC-004 (zero
double-accepts) both hold; customer sees every status change live.

## Story 2 — Earnings and job history (P2)

1. With at least one `COMPLETED` job and a `Payout` row created for this
   mechanic (via the existing payout batch/Celery task, or a manual
   admin-created `Payout`+`PayoutItem` for test data), open
   `/mechanic/earnings`.
2. Confirm the default period shows a non-zero total, and changing the
   period (`GET /providers/me/payouts?period_start=&period_end=`) updates
   it (SC-003: ≤3 interactions from login to seeing the total).
3. Open `/mechanic/history`, then a specific completed job's detail —
   confirm fare, any parts-sourcing amounts, and payout status
   (pending/paid) all show correctly.
4. Log in as a mechanic with **no** completed jobs — confirm
   `/mechanic/earnings` and `/mechanic/history` show an empty state, not
   an error (spec.md edge case).

**Expected outcome**: `GET /providers/me/payouts` returns only this
mechanic's own payouts (FR-011) — confirm by checking a second
mechanic's earnings never appear.

## Story 3 — Certifications and parts-sourcing (P3)

1. On `/mechanic/documents`, upload a certification file — confirm it
   appears with status "pending verification" (`verified: false`).
2. Simulate a failed upload (e.g. kill the network mid-request) —
   confirm the form surfaces a clear failure and retrying doesn't create
   a duplicate/partial document entry.
3. While working an active (`ACCEPTED`/`EN_ROUTE`/`IN_PROGRESS`) job,
   submit a parts-sourcing request (part + quantity) from the job detail
   view — confirm it appears as `PENDING`.
4. As the customer, approve it (`PATCH /parts-requests/{id}/approve`) —
   confirm the mechanic's view reflects `APPROVED` without re-submitting
   anything.
5. Attempt to submit a new parts-sourcing request against a
   `COMPLETED`/`CANCELLED` job — confirm the portal prevents it
   (FR-010's edge case; a UI-level guard per data-model.md).

**Expected outcome**: SC-005 (parts request submitted in <1 minute).

## Verifying the two new backend surfaces directly

- `pytest backend/apps/providers/tests/test_payouts.py` — happy path
  (own payouts returned) + RBAC (`403` for a non-mechanic, another
  mechanic's payouts never appear).
- `pytest backend/apps/dispatch/tests/test_status_broadcast.py` — asserts
  `channel_layer.group_send` is called with a `status.update` event on
  accept and on each allowed status transition (using Channels'
  `channels.testing` utilities, matching `apps/tracking/tests/
  test_consumer.py`'s existing pattern).
