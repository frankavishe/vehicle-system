# WebSocket Contract: Recovery & Towing Web Portal

No new event types. This feature is a second, multi-instance consumer of
the same `ws://.../tracking/{service_request_id}/` channel
001-mechanic-web-portal's `status.update` addition and the pre-existing
`location.update` already fully specify — see
`specs/001-mechanic-web-portal/contracts/websocket.md` for the wire
format of both events. Reproduced here only for what differs.

## What this feature does differently

- **One connection per active job, not one.** `web/src/app/track/[id]`
  and `web/src/app/mechanic` each ever hold at most one job's tracking
  socket open at a time. `web/src/components/recovery/ActiveTowMap.tsx`
  opens **one socket per currently-active job** shown on the dispatch
  view (Story 1) — each connects independently to its own
  `tracking_{service_request_id}` group, since `TrackingConsumer` scopes
  groups per-request, not per-provider. A job leaving the active set
  (completed/cancelled, FR-004) closes its socket.
- **No new outbound message.** This portal's operator role never sends
  `{lat, lng}` itself over this channel — `TrackingConsumer.receive_json`
  already restricts publishing to `self.is_provider` (the assigned
  provider's own device/app), and the portal only ever renders positions
  the provider's other connected client publishes. The portal is
  receive-only here, same as the customer's `/track` page.
- **Both events already role-agnostic.** `_broadcast_status_update()`
  (`apps/dispatch/views.py`) fires regardless of which role's action
  changed the status, so a `RECOVERY` operator's own
  `PATCH .../status` call already reaches every open socket for that
  job — including the operator's own other tab, and the customer's
  `/track` page — with zero code change required by this feature.

## Connection lifecycle (unchanged from `apps.tracking.consumers.TrackingConsumer`)

- Auth: JWT-authenticated user must be `sr.customer_id` or
  `sr.provider_id` for that specific `service_request_id`, or the socket
  is closed at connect (`4401`/`4403`/`4404`).
- Events received: `{event: "status_update", status, service_request_id}`
  and `{lat, lng, service_request_id}` (no `event` key — the
  `location_update` shape predates the `status_update` addition, kept
  as-is for backward compatibility, per 001's contract).
