import pytest
from django.urls import reverse
from rest_framework import status

from apps.notifications.models import Notification
from apps.orders.models import OrderStatus
from apps.orders.tests.factories import OrderFactory, OrderShipmentFactory

pytestmark = pytest.mark.django_db


def test_shipment_404_before_dispatch(auth_client, customer_user):
    order = OrderFactory(customer=customer_user)
    client = auth_client(customer_user)
    response = client.get(reverse("orders-shipment", args=[order.id]))
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_shipment_visible_to_owner_once_created(auth_client, customer_user):
    order = OrderFactory(customer=customer_user)
    OrderShipmentFactory(order=order, courier_name="DHL")
    client = auth_client(customer_user)
    response = client.get(reverse("orders-shipment", args=[order.id]))
    assert response.status_code == status.HTTP_200_OK
    assert response.data["courier_name"] == "DHL"


def test_shipment_hidden_from_other_customer(auth_client, customer_user):
    order = OrderFactory()
    OrderShipmentFactory(order=order)
    client = auth_client(customer_user)
    response = client.get(reverse("orders-shipment", args=[order.id]))
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_admin_shipment_patch_sets_dispatched_on_first_courier_info(
    auth_client, admin_user
):
    order = OrderFactory(status=OrderStatus.PAID)
    client = auth_client(admin_user)
    response = client.patch(
        reverse("admin-orders-shipment", args=[order.id]),
        {"courier_name": "DHL", "tracking_ref": "TRK123"},
        format="json",
    )
    assert response.status_code == status.HTTP_200_OK
    assert response.data["dispatched_at"] is not None
    order.refresh_from_db()
    assert order.status == OrderStatus.DISPATCHED
    # Phase 4: dispatch cascades to an ORDER_UPDATE notification (§7).
    assert Notification.objects.filter(
        user=order.customer, category="ORDER_UPDATE", title="Your order is on its way"
    ).exists()


def test_admin_shipment_patch_sets_location(auth_client, admin_user):
    order = OrderFactory(status=OrderStatus.PAID)
    client = auth_client(admin_user)
    response = client.patch(
        reverse("admin-orders-shipment", args=[order.id]),
        {"lat": -6.7924, "lng": 39.2083},
        format="json",
    )
    assert response.status_code == status.HTTP_200_OK
    assert response.data["current_location"] == {"lat": -6.7924, "lng": 39.2083}


def test_admin_shipment_patch_lat_lng_must_be_paired(auth_client, admin_user):
    order = OrderFactory(status=OrderStatus.PAID)
    client = auth_client(admin_user)
    response = client.patch(
        reverse("admin-orders-shipment", args=[order.id]), {"lat": -6.7924}, format="json"
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_admin_shipment_mark_delivered_cascades_order_status(auth_client, admin_user):
    order = OrderFactory(status=OrderStatus.DISPATCHED)
    OrderShipmentFactory(order=order, courier_name="DHL")
    client = auth_client(admin_user)
    response = client.patch(
        reverse("admin-orders-shipment", args=[order.id]),
        {"mark_delivered": True},
        format="json",
    )
    assert response.status_code == status.HTTP_200_OK
    assert response.data["delivered_at"] is not None
    order.refresh_from_db()
    assert order.status == OrderStatus.DELIVERED
    assert Notification.objects.filter(
        user=order.customer, category="ORDER_UPDATE", title="Your order was delivered"
    ).exists()


def test_customer_cannot_patch_shipment(auth_client, customer_user):
    order = OrderFactory(customer=customer_user, status=OrderStatus.PAID)
    client = auth_client(customer_user)
    response = client.patch(
        reverse("admin-orders-shipment", args=[order.id]),
        {"courier_name": "DHL"},
        format="json",
    )
    assert response.status_code == status.HTTP_403_FORBIDDEN
