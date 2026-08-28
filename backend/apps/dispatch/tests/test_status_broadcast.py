"""Integration tests for the `status.update` Channels broadcast added in
specs/001-mechanic-web-portal (contracts/websocket.md): a mechanic
accepting or advancing a service request pushes an event that a
connected tracking WebSocket receives, mirroring how `location.update`
already works end-to-end in apps/tracking/tests/test_consumer.py.
`transaction=True` for the same reason that file uses it — the REST call
below runs on a different thread than the test coroutine via
`sync_to_async`, so a plain rollback-wrapped `django_db` connection can't
safely be shared across that boundary."""

import pytest
from asgiref.sync import sync_to_async
from channels.routing import URLRouter
from channels.testing import WebsocketCommunicator
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.dispatch.models import ServiceStatus, ServiceType
from apps.dispatch.tests.factories import ServiceRequestFactory
from apps.tracking.middleware import JWTAuthMiddleware
from apps.tracking.routing import websocket_urlpatterns
from apps.users.models import UserRole
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db(transaction=True)

application = JWTAuthMiddleware(URLRouter(websocket_urlpatterns))


def _token(user) -> str:
    return str(RefreshToken.for_user(user).access_token)


async def _connect(user, service_request_id):
    url = f"/ws/api/v1/tracking/{service_request_id}/?token={_token(user)}"
    communicator = WebsocketCommunicator(application, url)
    connected, _ = await communicator.connect()
    assert connected
    return communicator


def _auth_client(user) -> APIClient:
    client = APIClient()
    token = RefreshToken.for_user(user).access_token
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
    return client


async def _available_mechanic():
    mechanic = await sync_to_async(UserFactory)(role=UserRole.MECHANIC)

    def _mark_available():
        mechanic.provider_profile.is_available = True
        mechanic.provider_profile.save()

    await sync_to_async(_mark_available)()
    return mechanic


async def test_accept_broadcasts_status_update():
    mechanic = await _available_mechanic()
    sr = await sync_to_async(ServiceRequestFactory)(service_type=ServiceType.MECHANIC)

    customer_comm = await _connect(sr.customer, sr.id)

    client = _auth_client(mechanic)
    response = await sync_to_async(client.post)(reverse("service-requests-accept", args=[sr.id]))
    assert response.status_code == 200

    message = await customer_comm.receive_json_from()
    assert message == {
        "event": "status_update",
        "status": ServiceStatus.ACCEPTED,
        "service_request_id": str(sr.id),
    }

    await customer_comm.disconnect()


async def test_status_patch_broadcasts_status_update():
    mechanic = await sync_to_async(UserFactory)(role=UserRole.MECHANIC)
    sr = await sync_to_async(ServiceRequestFactory)(
        service_type=ServiceType.MECHANIC, provider=mechanic, status=ServiceStatus.ACCEPTED
    )

    customer_comm = await _connect(sr.customer, sr.id)

    client = _auth_client(mechanic)
    response = await sync_to_async(client.patch)(
        reverse("service-requests-status", args=[sr.id]), {"status": "EN_ROUTE"}
    )
    assert response.status_code == 200

    message = await customer_comm.receive_json_from()
    assert message == {
        "event": "status_update",
        "status": ServiceStatus.EN_ROUTE,
        "service_request_id": str(sr.id),
    }

    await customer_comm.disconnect()


async def test_rejected_transition_does_not_broadcast():
    """COMPLETED is terminal (services/transitions.py) — the PATCH is
    rejected before any status write, so no broadcast should fire."""
    mechanic = await sync_to_async(UserFactory)(role=UserRole.MECHANIC)
    sr = await sync_to_async(ServiceRequestFactory)(
        service_type=ServiceType.MECHANIC, provider=mechanic, status=ServiceStatus.COMPLETED
    )

    customer_comm = await _connect(sr.customer, sr.id)

    client = _auth_client(mechanic)
    response = await sync_to_async(client.patch)(
        reverse("service-requests-status", args=[sr.id]), {"status": "EN_ROUTE"}
    )
    assert response.status_code == 400

    assert await customer_comm.receive_nothing(timeout=0.5) is True

    await customer_comm.disconnect()
