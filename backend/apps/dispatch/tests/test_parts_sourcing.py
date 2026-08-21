import pytest
from django.urls import reverse
from rest_framework import status

from apps.catalog.tests.factories import SparePartFactory
from apps.dispatch.models import PartsSourcingStatus, ServiceStatus, ServiceType
from apps.dispatch.tests.factories import PartsSourcingRequestFactory, ServiceRequestFactory
from apps.orders.models import Order

pytestmark = pytest.mark.django_db


def test_assigned_mechanic_creates_parts_request(auth_client, mechanic_user, customer_user):
    sr = ServiceRequestFactory(
        service_type=ServiceType.MECHANIC,
        status=ServiceStatus.ACCEPTED,
        provider=mechanic_user,
        customer=customer_user,
    )
    part = SparePartFactory(stock_quantity=10)
    client = auth_client(mechanic_user)
    response = client.post(
        reverse("parts-requests-list-create", args=[sr.id]),
        {"spare_part_id": str(part.id), "quantity": 2},
    )
    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["status"] == PartsSourcingStatus.PENDING
    assert response.data["quantity"] == 2


def test_unassigned_mechanic_cannot_create(auth_client, mechanic_user):
    sr = ServiceRequestFactory(service_type=ServiceType.MECHANIC, status=ServiceStatus.ACCEPTED)
    part = SparePartFactory()
    client = auth_client(mechanic_user)
    response = client.post(
        reverse("parts-requests-list-create", args=[sr.id]),
        {"spare_part_id": str(part.id), "quantity": 1},
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_cannot_create_for_recovery_request(auth_client, mechanic_user):
    sr = ServiceRequestFactory(service_type=ServiceType.RECOVERY, provider=mechanic_user)
    part = SparePartFactory()
    client = auth_client(mechanic_user)
    response = client.post(
        reverse("parts-requests-list-create", args=[sr.id]),
        {"spare_part_id": str(part.id), "quantity": 1},
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_customer_cannot_create(auth_client, customer_user):
    sr = ServiceRequestFactory(service_type=ServiceType.MECHANIC, customer=customer_user)
    part = SparePartFactory()
    client = auth_client(customer_user)
    response = client.post(
        reverse("parts-requests-list-create", args=[sr.id]),
        {"spare_part_id": str(part.id), "quantity": 1},
    )
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_customer_approves_request(auth_client, customer_user):
    sr = ServiceRequestFactory(customer=customer_user)
    psr = PartsSourcingRequestFactory(service_request=sr)
    client = auth_client(customer_user)
    response = client.patch(reverse("parts-requests-approve", args=[psr.id]), {"approved": True})
    assert response.status_code == status.HTTP_200_OK
    assert response.data["status"] == PartsSourcingStatus.APPROVED


def test_customer_rejects_request(auth_client, customer_user):
    sr = ServiceRequestFactory(customer=customer_user)
    psr = PartsSourcingRequestFactory(service_request=sr)
    client = auth_client(customer_user)
    response = client.patch(reverse("parts-requests-approve", args=[psr.id]), {"approved": False})
    assert response.status_code == status.HTTP_200_OK
    assert response.data["status"] == PartsSourcingStatus.REJECTED


def test_other_customer_cannot_approve(auth_client, customer_user):
    psr = PartsSourcingRequestFactory()  # different customer
    client = auth_client(customer_user)
    response = client.patch(reverse("parts-requests-approve", args=[psr.id]), {"approved": True})
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_convert_to_order_decrements_stock(auth_client, customer_user):
    sr = ServiceRequestFactory(customer=customer_user)
    part = SparePartFactory(price="1000.00", stock_quantity=5)
    psr = PartsSourcingRequestFactory(
        service_request=sr, spare_part=part, quantity=2, status=PartsSourcingStatus.APPROVED
    )
    client = auth_client(customer_user)
    response = client.post(
        reverse("parts-requests-order", args=[psr.id]), {"delivery_address": "123 Uhuru St"}
    )
    assert response.status_code == status.HTTP_201_CREATED
    order = Order.objects.get(pk=response.data["order_id"])
    assert order.total_amount == 2000
    part.refresh_from_db()
    assert part.stock_quantity == 3
    psr.refresh_from_db()
    assert psr.status == PartsSourcingStatus.ORDERED
    assert psr.order == order


def test_convert_rejects_non_approved(auth_client, customer_user):
    sr = ServiceRequestFactory(customer=customer_user)
    psr = PartsSourcingRequestFactory(service_request=sr, status=PartsSourcingStatus.PENDING)
    client = auth_client(customer_user)
    response = client.post(reverse("parts-requests-order", args=[psr.id]))
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_parts_request_list_visible_to_customer_and_provider(auth_client, mechanic_user, customer_user):
    sr = ServiceRequestFactory(
        service_type=ServiceType.MECHANIC, provider=mechanic_user, customer=customer_user
    )
    PartsSourcingRequestFactory(service_request=sr, requested_by=mechanic_user)

    client_customer = auth_client(customer_user)
    response = client_customer.get(reverse("parts-requests-list-create", args=[sr.id]))
    assert response.status_code == status.HTTP_200_OK
    assert len(response.data) == 1

    client_mechanic = auth_client(mechanic_user)
    response = client_mechanic.get(reverse("parts-requests-list-create", args=[sr.id]))
    assert response.status_code == status.HTTP_200_OK
    assert len(response.data) == 1
