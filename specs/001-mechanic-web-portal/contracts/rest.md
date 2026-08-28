# REST Contract: Mechanic Web Portal

All paths are relative to the existing API root the rest of `web/`
already calls through `web/src/app/api/backend/[...path]/route.ts` (the
same-origin proxy that attaches the Bearer token — see
`web/src/lib/api/client.ts`). Every endpoint below except
`GET /providers/me/payouts` already exists and is used unchanged.

## Existing — reused as-is

| Method | Path | Used for | Role gate |
|---|---|---|---|
| GET | `/users/me` | Verification gate in `mechanic/layout.tsx` (`is_verified`) | any authenticated user |
| GET | `/providers/me/availability` | Read current online/offline state before rendering the toggle (Story 1, FR-002) — flagged addition, see research.md addendum | `IsMechanic`/`IsProvider` |
| PATCH | `/providers/me/availability` | Online/offline toggle (Story 1, FR-002) | `IsMechanic`/`IsProvider` |
| GET | `/service-requests?status=` | Job queue (no/`PENDING`/`ACCEPTED`/`EN_ROUTE`/`IN_PROGRESS`) and history (`COMPLETED`) (Stories 1–2, FR-003/FR-006) | authenticated, server-side scoped |
| GET | `/service-requests/{id}` | Job detail (Story 1) | authenticated, server-side scoped |
| POST | `/service-requests/{id}/accept` | Accept an offered job (FR-004) | `IsProvider` |
| PATCH | `/service-requests/{id}/status` | Advance status: `EN_ROUTE`→`IN_PROGRESS`→`COMPLETED` (FR-005) | party to the request, role-checked per target status |
| GET | `/service-requests/{id}/parts-requests` | List parts-sourcing requests for a job (FR-010) | party to the request |
| POST | `/service-requests/{id}/parts-requests` | Submit a parts-sourcing request (FR-009) | `IsMechanic`, must be assigned provider |
| GET | `/providers/me/documents` | List own certification documents + verification status (FR-008) | `IsProvider` |
| POST | `/providers/me/documents` (multipart) | Upload a certification document (FR-008) | `IsProvider` |

**Decline** (FR-004's other half) has no endpoint — it's a client-side
removal from the visible queue for the current session (see research.md
"Declining a job").

## New — `GET /providers/me/payouts`

**Justification**: spec.md Clarifications (Session 2026-08-28) —
`GET /admin/payouts` is `IsAdmin`-only.

- **Method/Path**: `GET /providers/me/payouts`
- **Auth**: `IsMechanic` (this feature only needs the mechanic case;
  `IsProvider` would also cover `RECOVERY` but nothing in this spec asks
  for that — implementer's call whether to widen to `IsProvider` for
  symmetry with the sibling recovery portal, not required here).
- **Query params** (optional): `period_start`, `period_end` (ISO 8601
  dates) — filters `Payout.created_at` (or `period_start`/`period_end`
  overlap, implementer's choice consistent with how `AdminPayoutListView`
  would filter) between the two.
- **Response 200**: `generics.ListAPIView` inherits the project's global
  `DEFAULT_PAGINATION_CLASS` (`PageNumberPagination`, `PAGE_SIZE=20` —
  `config/settings/base.py`), same as `AdminPayoutListView` — so the
  body is the standard paginated envelope
  (`{count, next, previous, results}`), not a bare array. Every item in
  `results` has `PayoutSerializer`'s existing shape:

```json
{
  "count": 1,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": "uuid",
      "provider": "uuid",
      "amount": "125000.00",
      "period_start": "2026-08-01T00:00:00Z",
      "period_end": "2026-08-07T23:59:59Z",
      "is_manual": false,
      "provider_gateway": "SELCOM",
      "gateway_transaction_id": "txn_...",
      "status": "PAID",
      "created_at": "2026-08-08T02:00:00Z",
      "paid_at": "2026-08-08T02:00:15Z",
      "items": [
        { "id": "uuid", "service_request": "uuid", "amount": "80000.00" },
        { "id": "uuid", "service_request": "uuid", "amount": "45000.00" }
      ]
    }
  ]
}
```

  A frontend caller unwraps `.results`, exactly as
  `web/src/app/admin/payouts/page.tsx` already does for
  `GET /admin/payouts`.

- **Queryset**: `Payout.objects.filter(provider=request.user)
  .select_related("provider").prefetch_related("items")` — same
  `select_related`/`prefetch_related` shape as `AdminPayoutListView`, just
  scoped.
- **Errors**: `401` unauthenticated, `403` non-mechanic (standard
  `IsMechanic` behavior) — no `404`, an empty list is the "no payouts
  yet" case (spec.md edge case: empty state, not an error).
- **Backward compatibility**: additive only — `AdminPayoutListView` and
  its route are untouched.
