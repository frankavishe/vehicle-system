from decimal import Decimal

import pytest
from django.urls import reverse
from rest_framework import status

from apps.catalog.tests.factories import SparePartFactory
from apps.orders.models import Cart, CartItem
from apps.orders.tests.factories import CartFactory, CartItemFactory

pytestmark = pytest.mark.django_db


def test_get_cart_creates_empty_cart_lazily(auth_client, customer_user):
    client = auth_client(customer_user)
    response = client.get(reverse("cart"))
    assert response.status_code == status.HTTP_200_OK
    assert response.data["items"] == []
    assert response.data["total"] == 0
    assert Cart.objects.filter(customer=customer_user).exists()


def test_get_cart_requires_auth(api_client):
    response = api_client.get(reverse("cart"))
    assert response.status_code == status.HTTP_401_UNAUTHORIZED


def test_non_customer_cannot_access_cart(auth_client, mechanic_user):
    client = auth_client(mechanic_user)
    response = client.get(reverse("cart"))
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_add_item_creates_new_line(auth_client, customer_user):
    part = SparePartFactory(stock_quantity=10, price="5000.00")
    client = auth_client(customer_user)
    response = client.post(
        reverse("cart-items-create"), {"spare_part_id": str(part.id), "quantity": 2}
    )
    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["quantity"] == 2
    item = CartItem.objects.get(cart__customer=customer_user, spare_part=part)
    assert item.quantity == 2


def test_add_item_upserts_existing_line(auth_client, customer_user):
    part = SparePartFactory(stock_quantity=10)
    cart = CartFactory(customer=customer_user)
    CartItemFactory(cart=cart, spare_part=part, quantity=2)
    client = auth_client(customer_user)
    response = client.post(
        reverse("cart-items-create"), {"spare_part_id": str(part.id), "quantity": 3}
    )
    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["quantity"] == 5
    assert CartItem.objects.filter(cart=cart, spare_part=part).count() == 1


def test_add_item_rejected_when_exceeds_stock(auth_client, customer_user):
    part = SparePartFactory(stock_quantity=3)
    client = auth_client(customer_user)
    response = client.post(
        reverse("cart-items-create"), {"spare_part_id": str(part.id), "quantity": 4}
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert not CartItem.objects.filter(spare_part=part).exists()


def test_add_item_upsert_rejected_when_combined_exceeds_stock(auth_client, customer_user):
    part = SparePartFactory(stock_quantity=5)
    cart = CartFactory(customer=customer_user)
    CartItemFactory(cart=cart, spare_part=part, quantity=3)
    client = auth_client(customer_user)
    response = client.post(
        reverse("cart-items-create"), {"spare_part_id": str(part.id), "quantity": 3}
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    # existing line must be untouched — the rejected upsert doesn't persist
    item = CartItem.objects.get(cart=cart, spare_part=part)
    assert item.quantity == 3


def test_update_item_quantity(auth_client, customer_user):
    part = SparePartFactory(stock_quantity=10)
    cart = CartFactory(customer=customer_user)
    item = CartItemFactory(cart=cart, spare_part=part, quantity=1)
    client = auth_client(customer_user)
    response = client.patch(
        reverse("cart-items-detail", args=[item.id]), {"quantity": 4}
    )
    assert response.status_code == status.HTTP_200_OK
    item.refresh_from_db()
    assert item.quantity == 4


def test_update_item_rejected_when_exceeds_stock(auth_client, customer_user):
    part = SparePartFactory(stock_quantity=5)
    cart = CartFactory(customer=customer_user)
    item = CartItemFactory(cart=cart, spare_part=part, quantity=1)
    client = auth_client(customer_user)
    response = client.patch(
        reverse("cart-items-detail", args=[item.id]), {"quantity": 6}
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    item.refresh_from_db()
    assert item.quantity == 1


def test_delete_item(auth_client, customer_user):
    cart = CartFactory(customer=customer_user)
    item = CartItemFactory(cart=cart)
    client = auth_client(customer_user)
    response = client.delete(reverse("cart-items-detail", args=[item.id]))
    assert response.status_code == status.HTTP_204_NO_CONTENT
    assert not CartItem.objects.filter(id=item.id).exists()


def test_cross_user_cart_item_access_is_404_not_403(auth_client, customer_user):
    other_cart = CartFactory()
    other_item = CartItemFactory(cart=other_cart)
    client = auth_client(customer_user)

    get_response = client.patch(
        reverse("cart-items-detail", args=[other_item.id]), {"quantity": 2}
    )
    delete_response = client.delete(reverse("cart-items-detail", args=[other_item.id]))

    assert get_response.status_code == status.HTTP_404_NOT_FOUND
    assert delete_response.status_code == status.HTTP_404_NOT_FOUND


def test_cart_total_sums_line_items(auth_client, customer_user):
    cart = CartFactory(customer=customer_user)
    part_a = SparePartFactory(price="1000.00")
    part_b = SparePartFactory(price="2500.00")
    CartItemFactory(cart=cart, spare_part=part_a, quantity=2)
    CartItemFactory(cart=cart, spare_part=part_b, quantity=1)
    client = auth_client(customer_user)
    response = client.get(reverse("cart"))
    assert response.status_code == status.HTTP_200_OK
    assert response.data["total"] == Decimal("4500.00")
