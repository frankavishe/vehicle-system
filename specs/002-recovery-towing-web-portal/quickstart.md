# Quickstart: Validating the Recovery & Towing Web Portal

Manual end-to-end validation, one scenario per user story plus the one
new backend surface. Assumes the existing local dev setup (Postgres +
PostGIS, Redis, Django backend on `:8000` with Channels, Next.js `web/`
on `:3000`) already runs the other portals (`/admin`, `/mechanic`,
`/track`) — if not, follow `web/README`/`backend/README` (or `PLAN.md`
§2) first.

## Prerequisites

- A `RECOVERY`-role user with `is_verified=True` and its
  `ProviderProfile` (auto-created by `apps/providers/signals.py`).
- A `CUSTOMER`-role user, logged in on a second browser/incognito
  session, for creating tow requests and the live-status-push check.
- A second `RECOVERY`-role user, for confirming FR-009 isolation.

## Story 1 — Multi-tow dispatch view (P1)

1. Log in as the recovery operator at `/login`, land on `/recovery`.
2. As the customer (second session), create **two** `RECOVERY`-type
   service requests with distinct pickup/dropoff pairs
   (`POST /service-requests`).
3. Accept both from the operator's portal (or via
   `POST /service-requests/{id}/accept`) — confirm both now appear
   simultaneously on `/recovery`, each with its own status and a
   distinct, individually-selectable marker (SC-005; edge case:
   overlapping routes must not merge).
4. With the operator's mobile client (or a direct WS message) publishing
   `{lat, lng}` on one job's tracking socket, confirm that job's marker
   moves on the portal **without a manual refresh**, within ~5s (SC-002).
5. Advance one job to `COMPLETED` — confirm it drops off `/recovery`'s
   active view immediately (FR-004) while remaining reachable via
   `GET /service-requests?status=COMPLETED`.
6. Stop publishing position updates for the remaining active job for
   longer than the portal's staleness threshold — confirm the portal
   marks its position stale rather than showing a frozen point as
   current (edge case).

**Expected outcome**: SC-001 (all active jobs visible within 5s of
opening the portal) and SC-005 both hold.

## Story 2 — Fare estimate before committing (P2)

1. As the customer, create a `RECOVERY` service request — note the
   `estimated_fare` in the creation response.
2. As the operator, open that still-`PENDING` request's detail page
   (`/recovery/jobs/{id}`) **before** accepting — confirm the same
   `estimated_fare` is shown (SC-003: visible within 10s of opening).
3. Accept and drive the job through to `COMPLETED`.
4. Reopen the job detail — confirm `estimated_fare` and `final_fare` are
   both shown together (FR-006), not just the final one.
5. Repeat step 1 with a dropoff point in an area with no OSRM route
   available — confirm an estimate still shows (via the Haversine
   fallback already in `apps/dispatch/services/fare.py`), not an error
   (edge case).

**Expected outcome**: no portal-side fare computation is ever performed
— every value traces back to `ServiceRequestSerializer`'s existing
fields.

## Story 3 — Driver performance (P3)

1. With several `COMPLETED` and at least one `CANCELLED` recovery job in
   the last 30 days for this operator (create test data via accept →
   advance → complete/cancel flows, and one customer review per
   completed job via `POST /service-requests/{id}/review`), open
   `/recovery/performance`.
2. Confirm the default period shows `completed_count`,
   `average_rating`, and `average_response_time_seconds` matching what
   you created (SC-004: ≤3 interactions from login to seeing this).
3. Narrow the period (`GET /providers/me/performance?period_start=&period_end=`)
   to a window containing **only** the cancelled job — confirm the view
   shows `completed_count: 0` alongside a non-zero `cancelled_count`,
   distinguishing "no completions" from "no data" (FR-008, edge case).
4. Narrow the period to a window with **no** jobs at all — confirm
   `average_rating`/`average_response_time_seconds` render as an
   explicit empty state, not `0` or a broken chart (FR-008).
5. As the second `RECOVERY` operator, confirm their own
   `/recovery/performance` never reflects the first operator's numbers
   (FR-009).

**Expected outcome**: `GET /providers/me/performance` is strictly
self-scoped — confirmed by step 5.

## Verifying the new backend surface directly

- `pytest backend/apps/dispatch/tests/test_performance.py` — happy path
  (own completed/cancelled counts, average rating, average response time
  match hand-computed expectations for fixture data), RBAC (`403` for a
  non-`RECOVERY` user, another operator's jobs never counted), and the
  FR-008 zero-data-distinction case (all-cancelled period, and
  empty period, asserted separately).
- `pytest backend/apps/dispatch/tests/test_status_transitions.py` (or
  wherever `ServiceRequestAcceptView`/`ServiceRequestStatusUpdateView`
  are already covered) — extend to assert `accepted_at`/`completed_at`
  are set exactly once, at the expected transition, and never on any
  other transition.
