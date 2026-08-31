# REST Contract: Recovery & Towing Web Portal

All paths are relative to the existing API root the rest of `web/`
already calls through `web/src/app/api/backend/[...path]/route.ts` (the
same-origin proxy that attaches the Bearer token — see
`web/src/lib/api/client.ts`). Every endpoint below except
`GET /providers/me/performance` already exists and is used unchanged.

## Existing — reused as-is

| Method | Path | Used for | Role gate |
|---|---|---|---|
| GET | `/users/me` | Verification gate in `recovery/layout.tsx` (`is_verified`) | any authenticated user |
| GET | `/service-requests` | Multi-tow dispatch view (Story 1, FR-002/FR-003/FR-004): all rows, client-side filtered to `status in {ACCEPTED, EN_ROUTE, IN_PROGRESS}` for the active view | authenticated, server-side scoped to `provider=request.user`-or-`PENDING` for `RECOVERY` |
| GET | `/service-requests/{id}` | Job detail incl. fare estimate/final fare (Story 2, FR-005/FR-006) | authenticated, server-side scoped — visible pre-accept while `PENDING` |
| WS | `ws://.../tracking/{service_request_id}/` | Live status (`status_update`) + position (`location_update`) per active job (Story 1, FR-003) | participant of that specific request (`apps.tracking.consumers.TrackingConsumer.connect`) |

No mutation endpoints are newly *used* by this portal beyond what a
recovery operator's mobile app already calls (`POST .../accept`,
`PATCH .../status`) — this spec's Stories are read/observe-focused; job
lifecycle actions themselves aren't reintroduced as new portal-specific
endpoints, they're the same existing ones.

## New — `GET /providers/me/performance`

**Justification**: spec.md Clarifications (Session 2026-08-28) — no
existing endpoint is both self-scoped to one provider and
period-filterable; `provider_profiles.rating` has no period dimension.

- **Method/Path**: `GET /providers/me/performance`
- **Auth**: `IsRecovery` (self-scoped; this feature only needs the
  recovery case, mirroring 001-mechanic-web-portal's payouts endpoint
  choosing `IsMechanic` over the wider `IsProvider` for the same reason —
  nothing in this spec asks for the mechanic case).
- **Query params**: `period_start`, `period_end` (ISO 8601 dates,
  required — Story 3's Acceptance Scenario 1 is explicitly "for a
  selectable period"; if omitted, default to the trailing 30 days rather
  than erroring, so a first-touch call from the portal still renders
  something).
- **Response 200**:

```json
{
  "period_start": "2026-08-01T00:00:00Z",
  "period_end": "2026-08-28T23:59:59Z",
  "completed_count": 12,
  "cancelled_count": 2,
  "average_rating": 4.75,
  "average_response_time_seconds": 184
}
```

  `average_rating` and `average_response_time_seconds` are `null` (not
  `0`) when their respective underlying set is empty (FR-008) —
  `completed_count`/`cancelled_count` are always integers (`0` is a
  legitimate, meaningful count, not a missing-data signal, which is
  exactly why they're reported side by side per the Edge Cases section).

- **Queryset shape**:
  - `completed_count`: `ServiceRequest.objects.filter(provider=
    request.user, service_type=RECOVERY, status=COMPLETED,
    completed_at__range=(period_start, period_end)).count()`
  - `cancelled_count`: same filter, `status=CANCELLED`,
    `created_at__range=(period_start, period_end)` (a cancelled request
    has no `completed_at`).
  - `average_rating`: `Review.objects.filter(service_request__provider=
    request.user, service_request__service_type=RECOVERY,
    created_at__range=(period_start,
    period_end)).aggregate(Avg("rating"))["rating__avg"]`.
  - `average_response_time_seconds`: computed in Python over
    `ServiceRequest.objects.filter(provider=request.user,
    service_type=RECOVERY, completed_at__range=(period_start,
    period_end), accepted_at__isnull=False).values_list("created_at",
    "accepted_at")` — `avg((accepted - created).total_seconds())`, or
    `None` if the queryset is empty. (A DB-side `Avg(F("accepted_at") -
    F("created_at")))` is possible on Postgres but the small per-request
    row count here doesn't need it — Python-side keeps the query simple
    and the rounding/None-handling explicit.)
- **Errors**: `401` unauthenticated, `403` non-`RECOVERY` (standard
  `IsRecovery` behavior), `400` if `period_start > period_end`. No `404`
  — an all-zero/all-null response is the valid "nothing in this period"
  case (FR-008), not an error.
- **Backward compatibility**: purely additive — no existing endpoint or
  serializer changes shape. `ServiceRequestSerializer` gains two new
  read-only fields (`accepted_at`, `completed_at`) since they're plain
  model fields on an already-fully-serialized model; every existing
  caller of that serializer (mechanic portal, customer tracking page,
  mobile apps) ignores unknown-to-them extra fields, so this is additive
  there too.
