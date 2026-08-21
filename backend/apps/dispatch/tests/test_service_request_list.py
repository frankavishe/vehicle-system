import pytest
from django.urls import reverse
from rest_framework import status

from apps.dispatch.models import ServiceStatus, ServiceType
from apps.dispatch.tests.factories import ServiceRequestFactory

pytestmark = pytest.mark.django_db


def test_customer_sees_only_own_requests(auth_client, customer_user):
    mine = ServiceRequestFactory(customer=customer_user)
    ServiceRequestFactory()  # someone else's

    client = auth_client(customer_user)
    response = client.get(reverse("service-requests-list-create"))
    assert response.status_code == status.HTTP_200_OK
    ids = [row["id"] for row in response.data]
    assert str(mine.id) in ids
    assert len(ids) == 1


def test_mechanic_sees_pending_mechanic_requests_and_own_accepted(auth_client, mechanic_user):
    pending_mechanic = ServiceRequestFactory(service_type=ServiceType.MECHANIC, status=ServiceStatus.PENDING)
    ServiceRequestFactory(service_type=ServiceType.RECOVERY, status=ServiceStatus.PENDING)
    my_accepted = ServiceRequestFactory(
        service_type=ServiceType.MECHANIC, status=ServiceStatus.ACCEPTED, provider=mechanic_user
    )

    client = auth_client(mechanic_user)
    response = client.get(reverse("service-requests-list-create"))
    ids = {row["id"] for row in response.data}
    assert str(pending_mechanic.id) in ids
    assert str(my_accepted.id) in ids
    assert len(ids) == 2


def test_admin_sees_all(auth_client, admin_user):
    ServiceRequestFactory()
    ServiceRequestFactory()
    client = auth_client(admin_user)
    response = client.get(reverse("service-requests-list-create"))
    assert len(response.data) == 2


def test_status_query_param_filters(auth_client, admin_user):
    ServiceRequestFactory(status=ServiceStatus.PENDING)
    ServiceRequestFactory(status=ServiceStatus.COMPLETED)
    client = auth_client(admin_user)
    response = client.get(reverse("service-requests-list-create"), {"status": "PENDING"})
    assert len(response.data) == 1
    assert response.data[0]["status"] == ServiceStatus.PENDING


def test_detail_visible_to_owner(auth_client, customer_user):
    sr = ServiceRequestFactory(customer=customer_user)
    client = auth_client(customer_user)
    response = client.get(reverse("service-requests-detail", args=[sr.id]))
    assert response.status_code == status.HTTP_200_OK


def test_detail_404_for_unrelated_customer(auth_client, customer_user):
    sr = ServiceRequestFactory()
    client = auth_client(customer_user)
    response = client.get(reverse("service-requests-detail", args=[sr.id]))
    assert response.status_code == status.HTTP_404_NOT_FOUND
