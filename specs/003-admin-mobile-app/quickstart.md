# Quickstart: Validating the Admin Mobile App

Prerequisites: the existing Docker stack running (`infra/docker-compose.yml`
— postgis, redis, backend/daphne, osrm) with this feature's backend changes
applied and migrated (no new migration expected — see data-model.md), and
`mobile/` pointed at that backend (`--dart-define` base URL, same as
existing dev setup). An admin account (`role=ADMIN`) with a known
password.

## 1. Backend contract sanity (curl), before touching the app

```bash
TOKEN=$(curl -s -X POST http://localhost:8000/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@example.com","password":"..."}' | jq -r .access)

# Story 1 — disputes list carries the new readable fields
curl -s http://localhost:8000/api/v1/admin/disputes?status=OPEN \
  -H "Authorization: Bearer $TOKEN" | jq '.[0] | {service_request_summary, raised_by_name}'

# Story 2 — analytics carries the new alert fields
curl -s http://localhost:8000/api/v1/admin/analytics \
  -H "Authorization: Bearer $TOKEN" | jq '{failed_notifications_recent, failed_payments_recent, has_alert}'

# Story 3 — search + status toggle
curl -s "http://localhost:8000/api/v1/admin/users?search=juma" \
  -H "Authorization: Bearer $TOKEN" | jq '.[0].id'

curl -s -X PATCH http://localhost:8000/api/v1/admin/users/<id>/status \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"is_active": false}' | jq '.is_active'
```

Expected: all three return `200` with the new fields populated (not
`null`/absent), and the status toggle flips `is_active` and — per
data-model.md — a subsequent login attempt with that account's
credentials is rejected (suspension takes effect at auth, not just as a
display flag).

## 2. Story 1 — resolve a dispute from the app (SC-001, SC-002)

1. Seed one `OPEN` dispute (via the web admin console's existing raise
   path, or `POST /service-requests/{id}/disputes` directly).
2. Log into the mobile app as the admin account → lands on `AdminShell`
   → `Disputes` tab (default).
3. Confirm the dispute appears with job/complainant/reason visible
   without navigating elsewhere (FR-002).
4. Open it, tap Resolve → confirm `ConfirmActionDialog` appears (FR-007)
   → confirm.
5. Confirm status flips to `RESOLVED` in the app, and
   `GET /admin/disputes` (or the web console) shows the same resolution
   (FR-008).
6. From a second admin session (or the web console), open the same
   dispute — confirm it shows as resolved, not actionable (edge case #1,
   SC-002).
7. Time steps 2-4 — should be under 60s (SC-001).

## 3. Story 2 — oversight/health (SC-003)

1. With the platform in a normal state, open the `Oversight` tab —
   confirm key figures show with no alert styling (Acceptance Scenario 1).
2. Force a failure spike (e.g. seed several `Payment` rows with
   `status=FAILED` past `FAILURE_ALERT_THRESHOLD`, or fail several
   notification sends) → reopen/refresh the tab → confirm the alert state
   is visibly distinct within 5 seconds of opening (Acceptance Scenario 2,
   SC-003) — not buried among the normal figures.

## 4. Story 3 — moderation + manual payout (SC-004)

1. `Moderation` tab → search for a known user/provider by name or email
   (FR-005) → open their account.
2. Tap Suspend → confirm `ConfirmActionDialog` appears → confirm →
   account's `is_active` flips (Acceptance Scenario 1). There's no
   equivalent web console screen to cross-check today (confirmed during
   planning — see spec.md Assumptions), so verify directly via
   `GET /admin/users/{id}` instead.
2a. Search for an ADMIN-role account — confirm it's excluded from
   results (or, if targeted directly via `PATCH .../status`, confirm a
   `403`) — FR-005's admin-lockout guard.
2b. Search for a name with no matches — confirm the app shows a clear
   "no results" state, not a blank/broken screen.
3. Attempt to log in as the now-suspended account (any surface) — confirm
   it's rejected.
4. Reinstate the same account the same way — confirm login succeeds
   again.
5. From a provider with at least one completed, unpaid job, trigger a
   manual payout — confirm the confirmation dialog appears, then confirm
   the resulting `Payout` appears in `GET /admin/payouts` with
   `is_manual: true` (Acceptance Scenario 2).
6. Attempt a manual payout for a provider with nothing outstanding —
   confirm the app surfaces the 404's message clearly rather than
   creating a zero payout or failing silently (edge case).
7. Confirm every one of steps 2/5/6 above required the confirmation step
   — this is SC-004's 100% claim, checked by inspection of
   `features/admin/` (every mutating call routes through
   `ConfirmActionDialog`, per contracts/admin-mobile-api.md's
   "Confirmation semantics" section) rather than by exhaustive manual
   re-testing of every path.

## 5. Edge cases

- **Stale data**: put the device in airplane mode after the disputes list
  has loaded once, reopen the tab — confirm `staleness_banner.dart`
  renders a "may be stale" state rather than presenting the cached list
  as live (FR-009).
- **Zero open disputes**: resolve or otherwise clear all open disputes —
  confirm the Disputes tab shows an explicit "nothing pending" state, not
  a blank screen indistinguishable from a loading failure (edge case).
- **Race on the same dispute**: resolve one dispute from the web console
  and, without refreshing, attempt to resolve it from mobile — confirm
  the mobile app surfaces the existing `400 "already resolved"` response
  rather than a generic error or a false success.
