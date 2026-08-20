import pytest
from django.urls import reverse
from rest_framework import status

from apps.catalog.tests.factories import SparePartFactory
from apps.orders.models import Order, OrderStatus
from apps.orders.tests.factories import (
    CartFactory,
    CartItemFactory,
    OrderFactory,
    OrderItemFactory,
)

pytestmark = pytest.mark.django_db


def test_checkout_happy_path_decrements_stock_and_clears_cart(auth_client, customer_user):
    cart = CartFactory(customer=customer_user)
    part_a = SparePartFactory(price="1000.00", stock_quantity=10)
    part_b = SparePartFactory(price="2500.00", stock_quantity=5)
    CartItemFactory(cart=cart, spare_part=part_a, quantity=2)
    CartItemFactory(cart=cart, spare_part=part_b, quantity=1)

    client = auth_client(customer_user)
    response = client.post(
        reverse("orders-list-create"), {"delivery_address": "123 Uhuru St"}
    )

    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["status"] == OrderStatus.PENDING
    assert response.data["total_amount"] == "4500.00"
    assert len(response.data["items"]) == 2

    part_a.refresh_from_db()
    part_b.refresh_from_db()
    assert part_a.stock_quantity == 8
    assert part_b.stock_quantity == 4
    assert cart.items.count() == 0


def test_checkout_rejects_empty_cart(auth_client, customer_user):
    CartFactory(customer=customer_user)
    client = auth_client(customer_user)
    response = client.post(
        reverse("orders-list-create"), {"delivery_address": "123 Uhuru St"}
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert not Order.objects.filter(customer=customer_user).exists()


def test_checkout_rejects_insufficient_stock_and_creates_no_partial_order(
    auth_client, customer_user
):
    cart = CartFactory(customer=customer_user)
    part_a = SparePartFactory(stock_quantity=10)
    part_b = SparePartFactory(stock_quantity=2)
    CartItemFactory(cart=cart, spare_part=part_a, quantity=1)
    CartItemFactory(cart=cart, spare_part=part_b, quantity=5)

    client = auth_client(customer_user)
    response = client.post(
        reverse("orders-list-create"), {"delivery_address": "123 Uhuru St"}
    )

    assert response.status_code == status.HTTP_400_BAD_REQUEST
    part_a.refresh_from_db()
    part_b.refresh_from_db()
    assert part_a.stock_quantity == 10  # untouched — no partial order
    assert part_b.stock_quantity == 2
    assert not Order.objects.filter(customer=customer_user).exists()
    assert cart.items.count() == 2  # cart not cleared on failure


def test_checkout_requires_delivery_address(auth_client, customer_user):
    cart = CartFactory(customer=customer_user)
    CartItemFactory(cart=cart)
    client = auth_client(customer_user)
    response = client.post(reverse("orders-list-create"), {})
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_list_orders_scoped_to_own_customer(auth_client, customer_user):
    mine = OrderFactory(customer=customer_user)
    OrderFactory()  # someone else's

    client = auth_client(customer_user)
    response = client.get(reverse("orders-list-create"))
    assert response.status_code == status.HTTP_200_OK
    ids = [row["id"] for row in response.data]
    assert str(mine.id) in ids
    assert len(ids) == 1


def test_order_detail_owner_can_view(auth_client, customer_user):
    order = OrderFactory(customer=customer_user)
    client = auth_client(customer_user)
    response = client.get(reverse("orders-detail", args=[order.id]))
    assert response.status_code == status.HTTP_200_OK


def test_order_detail_admin_can_view(auth_client, admin_user):
    order = OrderFactory()
    client = auth_client(admin_user)
    response = client.get(reverse("orders-detail", args=[order.id]))
    assert response.status_code == status.HTTP_200_OK


def test_order_detail_other_customer_gets_404(auth_client, customer_user):
    order = OrderFactory()  # belongs to a different customer
    client = auth_client(customer_user)
    response = client.get(reverse("orders-detail", args=[order.id]))
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_cancel_restores_stock_and_sets_cancelled(auth_client, customer_user):
    order = OrderFactory(customer=customer_user, status=OrderStatus.PENDING)
    part = SparePartFactory(stock_quantity=5)
    OrderItemFactory(order=order, spare_part=part, quantity=3)

    client = auth_client(customer_user)
    response = client.post(reverse("orders-cancel", args=[order.id]))

    assert response.status_code == status.HTTP_200_OK
    assert response.data["status"] == OrderStatus.CANCELLED
    part.refresh_from_db()
    assert part.stock_quantity == 8


def test_cancel_rejected_when_not_pending(auth_client, customer_user):
    order = OrderFactory(customer=customer_user, status=OrderStatus.PAID)
    client = auth_client(customer_user)
    response = client.post(reverse("orders-cancel", args=[order.id]))
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    order.refresh_from_db()
    assert order.status == OrderStatus.PAID


def test_cancel_requires_ownership(auth_client, customer_user):
    order = OrderFactory(status=OrderStatus.PENDING)  # different customer
    client = auth_client(customer_user)
    response = client.post(reverse("orders-cancel", args=[order.id]))
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_orders_endpoints_require_auth(api_client):
    response = api_client.get(reverse("orders-list-create"))
    assert response.status_code == status.HTTP_401_UNAUTHORIZED


def test_non_customer_cannot_checkout(auth_client, mechanic_user):
    client = auth_client(mechanic_user)
    response = client.post(
        reverse("orders-list-create"), {"delivery_address": "123 Uhuru St"}
    )
    assert response.status_code == status.HTTP_403_FORBIDDEN
