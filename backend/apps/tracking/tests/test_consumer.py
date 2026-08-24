"""WebsocketCommunicator tests for TrackingConsumer. `transaction=True` on
the db mark (rather than the default rollback-wrapped fixture) because
`database_sync_to_async` calls run on a different thread than the test
coroutine — a plain non-transactional `django_db` fixture's connection
isn't safely shared across that boundary."""

import pytest
from asgiref.sync import sync_to_async
from channels.routing import URLRouter
from channels.testing import WebsocketCommunicator
from rest_framework_simplejwt.tokens import RefreshToken

from apps.dispatch.models import ServiceStatus
from apps.dispatch.tests.factories import ServiceRequestFactory
from apps.providers.models import ProviderProfile
from apps.tracking.middleware import JWTAuthMiddleware
from apps.tracking.routing import websocket_urlpatterns
from apps.users.models import UserRole
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db(transaction=True)

application = JWTAuthMiddleware(URLRouter(websocket_urlpatterns))


def _token(user) -> str:
    return str(RefreshToken.for_user(user).access_token)


async def _connect(user, service_request_id):
    url = f"/ws/api/v1/tracking/{service_request_id}/"
    if user is not None:
        url += f"?token={_token(user)}"
    communicator = WebsocketCommunicator(application, url)
    connected, _ = await communicator.connect()
    return communicator, connected


async def test_customer_and_assigned_provider_can_connect():
    mechanic = await sync_to_async(UserFactory)(role=UserRole.MECHANIC)
    sr = await sync_to_async(ServiceRequestFactory)(
        provider=mechanic, status=ServiceStatus.ACCEPTED
    )

    customer_comm, connected = await _connect(sr.customer, sr.id)
    assert connected
    await customer_comm.disconnect()

    provider_comm, connected = await _connect(mechanic, sr.id)
    assert connected
    await provider_comm.disconnect()


async def test_non_participant_is_refused():
    stranger = await sync_to_async(UserFactory)()
    sr = await sync_to_async(ServiceRequestFactory)()

    _comm, connected = await _connect(stranger, sr.id)
    assert not connected


async def test_unauthenticated_is_refused():
    sr = await sync_to_async(ServiceRequestFactory)()

    _comm, connected = await _connect(None, sr.id)
    assert not connected


async def test_provider_location_broadcasts_to_customer_and_persists():
    mechanic = await sync_to_async(UserFactory)(role=UserRole.MECHANIC)
    sr = await sync_to_async(ServiceRequestFactory)(
        provider=mechanic, status=ServiceStatus.ACCEPTED
    )

    customer_comm, _ = await _connect(sr.customer, sr.id)
    provider_comm, _ = await _connect(mechanic, sr.id)

    await provider_comm.send_json_to({"lat": -6.8, "lng": 39.28})

    message = await customer_comm.receive_json_from()
    assert message["lat"] == -6.8
    assert message["lng"] == 39.28
    assert message["service_request_id"] == str(sr.id)

    profile = await sync_to_async(ProviderProfile.objects.get)(user=mechanic)
    assert profile.current_location is not None
    assert round(profile.current_location.y, 2) == -6.8  # GEOS Point.y == lat
    assert round(profile.current_location.x, 2) == 39.28  # Point.x == lng

    await customer_comm.disconnect()
    await provider_comm.disconnect()


async def test_customer_cannot_publish_a_location():
    mechanic = await sync_to_async(UserFactory)(role=UserRole.MECHANIC)
    sr = await sync_to_async(ServiceRequestFactory)(
        provider=mechanic, status=ServiceStatus.ACCEPTED
    )

    customer_comm, _ = await _connect(sr.customer, sr.id)
    provider_comm, _ = await _connect(mechanic, sr.id)

    await customer_comm.send_json_to({"lat": -6.8, "lng": 39.28})

    # receive_nothing (not receive_json_from + pytest.raises(TimeoutError))
    # deliberately — the latter's internal asyncio.wait_for cancellation
    # leaves the communicator's own task in a state where a later
    # disconnect() re-raises that CancelledError instead of cleaning up.
    assert await provider_comm.receive_nothing(timeout=0.5) is True

    await customer_comm.disconnect()
    await provider_comm.disconnect()
