import pytest
from django.urls import reverse
from rest_framework import status

from apps.catalog.tests.factories import SparePartFactory

pytestmark = pytest.mark.django_db


def test_admin_can_increase_stock(auth_client, admin_user):
    part = SparePartFactory(stock_quantity=10)
    client = auth_client(admin_user)
    response = client.patch(reverse("admin-parts-stock", args=[part.id]), {"adjustment": 5})
    assert response.status_code == status.HTTP_200_OK
    assert response.data["stock_quantity"] == 15


def test_admin_can_decrease_stock(auth_client, admin_user):
    part = SparePartFactory(stock_quantity=10)
    client = auth_client(admin_user)
    response = client.patch(reverse("admin-parts-stock", args=[part.id]), {"adjustment": -3})
    assert response.status_code == status.HTTP_200_OK
    assert response.data["stock_quantity"] == 7


def test_adjustment_rejected_if_would_go_negative(auth_client, admin_user):
    part = SparePartFactory(stock_quantity=2)
    client = auth_client(admin_user)
    response = client.patch(reverse("admin-parts-stock", args=[part.id]), {"adjustment": -5})
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    part.refresh_from_db()
    assert part.stock_quantity == 2


def test_customer_cannot_adjust_stock(auth_client, customer_user):
    part = SparePartFactory(stock_quantity=10)
    client = auth_client(customer_user)
    response = client.patch(reverse("admin-parts-stock", args=[part.id]), {"adjustment": 5})
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_stock_adjust_requires_auth(api_client):
    part = SparePartFactory(stock_quantity=10)
    response = api_client.patch(reverse("admin-parts-stock", args=[part.id]), {"adjustment": 5})
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
