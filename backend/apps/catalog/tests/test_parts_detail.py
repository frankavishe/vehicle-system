import uuid

import pytest
from django.urls import reverse
from rest_framework import status

from apps.catalog.tests.factories import SparePartFactory

pytestmark = pytest.mark.django_db


def test_get_part_detail(api_client):
    part = SparePartFactory()
    response = api_client.get(reverse("parts-detail", args=[part.id]))
    assert response.status_code == status.HTTP_200_OK
    assert response.data["sku"] == part.sku
    assert "description" in response.data


def test_get_part_detail_404(api_client):
    response = api_client.get(reverse("parts-detail", args=[uuid.uuid4()]))
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_facets_lists_distinct_makes_and_models(api_client):
    SparePartFactory(compatible_make="Toyota", compatible_model="Hilux")
    SparePartFactory(compatible_make="Toyota", compatible_model="Corolla")
    SparePartFactory(compatible_make="Nissan", compatible_model="Navara")
    response = api_client.get(reverse("parts-facets"))
    assert response.status_code == status.HTTP_200_OK
    assert set(response.data["makes"]) == {"Toyota", "Nissan"}


def test_facets_filtered_by_make(api_client):
    SparePartFactory(compatible_make="Toyota", compatible_model="Hilux")
    SparePartFactory(compatible_make="Nissan", compatible_model="Navara")
    response = api_client.get(reverse("parts-facets"), {"make": "Toyota"})
    assert response.data["models"] == ["Hilux"]
