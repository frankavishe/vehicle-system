# WebSocket Contract: Mechanic Web Portal

**Channel**: `ws://.../tracking/{service_request_id}/` — already exists
(`apps/tracking/consumers.py`, `TrackingConsumer`), already connected to
by `web/src/app/track/[serviceRequestId]` for the customer view. The
mechanic portal does **not** open this socket itself; it changes status
via the existing REST `PATCH .../status` / `POST .../accept`, same as
the mobile app does today. This contract only concerns the **new**
server→client event those two views cause.

## New event: `status.update`

**Justification**: spec.md Clarifications (Session 2026-08-28) — the
channel only ever sent `location.update` before this feature; FR-012/
SC-002 need status changes visible on the open tracking view within 5s.

- **Trigger**: `ServiceRequestAcceptView.post()` (on successful accept)
  and `ServiceRequestStatusUpdateView.patch()` (on successful transition)
  in `apps/dispatch/views.py`, after the DB write, call:

```python
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

async_to_sync(get_channel_layer().group_send)(
    f"tracking_{sr.id}",
    {
        "type": "status.update",
        "status": sr.status,
        "service_request_id": str(sr.id),
    },
)
```

- **Consumer handler** (new method on `TrackingConsumer`, mirrors the
  existing `location_update()`):

```python
async def status_update(self, event):
    await self.send_json({
        "event": "status_update",
        "status": event["status"],
        "service_request_id": event["service_request_id"],
    })
```

- **Client payload** (received by whatever already holds the socket
  open — customer and/or provider's other devices, per the existing
  group membership):

```json
{
  "event": "status_update",
  "status": "EN_ROUTE",
  "service_request_id": "uuid"
}
```

- **Client handling**: `web/src/app/track/[serviceRequestId]`'s socket
  listener (currently only expecting `{lat, lng, service_request_id}`
  location payloads) adds a branch: an incoming message with
  `event: "status_update"` updates the local status state driving
  `<ServiceRequestStatusBadge status={...} />` — no refetch of
  `GET /service-requests/{id}` needed, matching how `location_update`
  already updates the map without a refetch.
- **Distinguishing the two event shapes on the client**: `location_update`
  payloads have `lat`/`lng` and no `event` field (unchanged, for
  backward compatibility with the existing map component);
  `status_update` payloads have `event: "status_update"` and no
  `lat`/`lng`. The client checks for the `event` field first.
- **No new connection, no new permission check**: group membership and
  the connect-time participant check (`user.id in (customer_id,
  provider_id)`) are unchanged — a `status.update` reaches exactly the
  sockets that would already receive a `location.update` for the same
  request.
- **Failure mode**: if no socket is open for that group (customer not
  currently viewing tracking), `group_send` is a no-op — the customer
  simply sees the current status on their next page load, same behavior
  as today. This event is a live-update enhancement, not the source of
  truth (the DB row is); nothing depends on it being delivered.
