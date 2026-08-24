"""`ws://api/v1/tracking/{service_request_id}/` (PLAN.md §5.2) — the
provider assigned to a service_request publishes lat/lng roughly every
5s; every connected socket for that request (customer + provider's own
other devices) receives the broadcast over a Redis-backed Channels group
(`tracking_{id}`), and the last position is persisted to
`provider_profiles.current_location` so it survives disconnects and feeds
the admin fleet map (`GET /admin/map`, apps.admin_ops)."""

from channels.db import database_sync_to_async
from channels.generic.websocket import AsyncJsonWebsocketConsumer
from django.contrib.gis.geos import Point
from django.utils import timezone

from apps.dispatch.models import ServiceRequest
from apps.providers.models import ProviderProfile


class TrackingConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.service_request_id = self.scope["url_route"]["kwargs"]["service_request_id"]
        user = self.scope["user"]

        if not user or not user.is_authenticated:
            await self.close(code=4401)
            return

        sr = await self._get_service_request(self.service_request_id)
        if sr is None:
            await self.close(code=4404)
            return

        if user.id not in (sr["customer_id"], sr["provider_id"]):
            # Not a participant of this specific request — refused at
            # connect time, not just filtered after accepting.
            await self.close(code=4403)
            return

        self.is_provider = user.id == sr["provider_id"]
        self.group_name = f"tracking_{self.service_request_id}"
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, "group_name"):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive_json(self, content, **kwargs):
        if not getattr(self, "is_provider", False):
            # Only the assigned provider publishes; the customer side is
            # receive-only. Silently dropped rather than closing the
            # socket — a stray/malformed client message shouldn't kill
            # an otherwise-valid connection.
            return

        lat, lng = content.get("lat"), content.get("lng")
        if not isinstance(lat, (int, float)) or not isinstance(lng, (int, float)):
            await self.send_json({"error": "lat/lng must be numbers."})
            return

        await self._persist_location(self.scope["user"].id, lat, lng)
        await self.channel_layer.group_send(
            self.group_name,
            {
                "type": "location.update",
                "lat": lat,
                "lng": lng,
                "service_request_id": str(self.service_request_id),
            },
        )

    async def location_update(self, event):
        await self.send_json(
            {
                "lat": event["lat"],
                "lng": event["lng"],
                "service_request_id": event["service_request_id"],
            }
        )

    @database_sync_to_async
    def _get_service_request(self, pk):
        sr = (
            ServiceRequest.objects.filter(pk=pk)
            .values("id", "customer_id", "provider_id")
            .first()
        )
        return sr

    @database_sync_to_async
    def _persist_location(self, provider_user_id, lat, lng):
        ProviderProfile.objects.filter(user_id=provider_user_id).update(
            current_location=Point(lng, lat, srid=4326), updated_at=timezone.now()
        )
