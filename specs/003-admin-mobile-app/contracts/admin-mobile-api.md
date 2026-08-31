# API Contract: Admin Mobile App

All endpoints are under `/api/v1/`, `IsAuthenticated + IsAdmin` (existing
`apps.common.permissions`), token via the existing JWT flow (`/auth/login`,
`Authorization: Bearer <access>`). Endpoints marked **(reused, unchanged)**
already exist and ship no code change. Endpoints marked **(extended)** or
**(new)** are this feature's backend deltas — see `research.md` §3-7 and
`plan.md`'s Complexity Tracking for why each is justified.

## Disputes — Story 1 (P1)

### `GET /admin/disputes` — (extended response, same endpoint/params)

Query params (unchanged): `?status=OPEN|RESOLVED`

Response item (additive fields marked ✨):

```json
{
  "id": "uuid",
  "service_request": "uuid",
  "raised_by": "uuid",
  "reason": "string",
  "status": "OPEN | RESOLVED",
  "resolved_by": "uuid | null",
  "created_at": "iso8601",
  "service_request_summary": {
    "id": "uuid",
    "service_type": "MECHANIC | RECOVERY",
    "status": "PENDING | ACCEPTED | EN_ROUTE | IN_PROGRESS | COMPLETED | CANCELLED",
    "customer_name": "string",
    "provider_name": "string | null"
  },
  "raised_by_name": "string | null",
  "raised_by_email": "string | null",
  "resolved_by_name": "string | null"
}
```

Errors: `401` unauthenticated, `403` non-admin (existing behavior).

### `PATCH /admin/disputes/{id}/resolve` — (reused, unchanged)

No request body. Response: the updated `Dispute` (same shape as above).

Errors: `404` unknown id, `400` `{"detail": "This dispute is already
resolved."}` when called twice (this is what satisfies FR-003's
"prevent resolving a dispute another admin already resolved" and SC-002
— the client shows this as "already resolved," it does not need to
pre-check status itself), `401`/`403` as above.

## Oversight — Story 2 (P2)

### `GET /admin/analytics` — (extended response, same endpoint)

```json
{
  "orders_by_status": {"PENDING": 3, "...": 0},
  "service_requests_by_status": {"PENDING": 2, "...": 0},
  "revenue": "125000.00",
  "active_providers": 7,
  "open_disputes": 2,
  "failed_notifications_recent": 0,
  "failed_payments_recent": 0,
  "has_alert": false
}
```

`failed_notifications_recent`/`failed_payments_recent` are counts over a
trailing 24-hour window; `has_alert` is `true` when either exceeds `5`
(the new `FAILURE_ALERT_THRESHOLD` setting). This is the single field the
mobile (and, later, web) UI reads to decide whether to render the alert
state — no client-side threshold logic (research.md §7).

`GET /admin/analytics`, and `GET /admin/disputes`, are polled every 10
seconds by the mobile client while their screen is open (research.md
§10) — this is a client-side polling cadence, not a server push; the
endpoint itself is unchanged by this.

Errors: `401`/`403` as above.

## Moderation — Story 3 (P3)

### `GET /admin/users` — (extended: search added, same endpoint)

Query params: `?role=CUSTOMER|MECHANIC|RECOVERY|ADMIN` (existing),
`&is_active=true|false` (existing), `&is_verified=true|false` (existing),
**`&search=<text>`** ✨ new — matches against `email` or `full_name`
(DRF `SearchFilter`, case-insensitive substring).

Response item (unchanged `AdminUserListSerializer` shape):

```json
{
  "id": "uuid",
  "email": "string",
  "phone": "string",
  "full_name": "string",
  "role": "CUSTOMER | MECHANIC | RECOVERY | ADMIN",
  "is_active": true,
  "is_verified": true,
  "created_at": "iso8601"
}
```

### `PATCH /admin/users/{id}/status` — **(new)**

Request:

```json
{"is_active": false}
```

Response: `200`, the updated user (same shape as the list item above).

Errors: `404` unknown id, `400` invalid body (non-boolean), `403` when
the target user's `role == "ADMIN"` (spec.md FR-005 — ADMIN accounts
aren't a valid moderation target through this endpoint), `401`/generic
`403` as above. No "already suspended" 400 — unlike `Dispute`'s one-way
transition, toggling `is_active` to its current value is idempotent, not
an error (setting a suspended account to suspended again is a no-op, not
a conflict — there's no "who suspended it first" race to protect against
the way dispute-resolution has).

### `POST /admin/payouts/{provider_id}/trigger` — (reused, unchanged)

No request body. Response: `201` with the created `Payout` list (or
`404 {"detail": "No unpaid completed requests for this provider."}` —
this is what satisfies the spec's "prevent or clearly explain a zero/
invalid payout" edge case, already server-enforced).

### `GET /admin/payouts` — (reused, unchanged)

Query params: `?status=`, `?provider=`, `?is_manual=`. Used by the
moderation screen to show a provider's payout history for context before
triggering a new manual one.

## Confirmation semantics (client-side contract, FR-007)

Every mutating call above (`PATCH .../resolve`, `PATCH .../status`,
`POST .../trigger`) is fired only after `ConfirmActionDialog` returns
`true` — this is enforced entirely in `mobile/lib/features/admin/`, not
by the API (the API has no "are you sure" concept; SC-004's 100% is a
client-side invariant made provable by routing every one of these three
calls through the one shared dialog widget, per research.md §9).
