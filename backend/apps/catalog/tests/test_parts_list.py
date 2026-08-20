import pytest
from django.urls import reverse
from rest_framework import status

from apps.catalog.tests.factories import SparePartFactory

pytestmark = pytest.mark.django_db


def test_list_parts_is_public(api_client):
    SparePartFactory()
    response = api_client.get(reverse("parts-list"))
    assert response.status_code == status.HTTP_200_OK
    assert response.data["count"] == 1


def test_filter_by_make(api_client):
    SparePartFactory(compatible_make="Toyota")
    SparePartFactory(compatible_make="Nissan")
    response = api_client.get(reverse("parts-list"), {"make": "Toyota"})
    assert response.data["count"] == 1
    assert response.data["results"][0]["compatible_make"] == "Toyota"


def test_filter_by_model(api_client):
    SparePartFactory(compatible_model="Hilux")
    SparePartFactory(compatible_model="Navara")
    response = api_client.get(reverse("parts-list"), {"model": "Hilux"})
    assert response.data["count"] == 1


def test_filter_by_category(api_client):
    SparePartFactory(category="Brakes")
    SparePartFactory(category="Engine")
    response = api_client.get(reverse("parts-list"), {"category": "Engine"})
    assert response.data["count"] == 1
    assert response.data["results"][0]["category"] == "Engine"


def test_filter_by_year_within_range(api_client):
    SparePartFactory(year_start=2015, year_end=2020)
    response = api_client.get(reverse("parts-list"), {"year": 2018})
    assert response.data["count"] == 1


def test_filter_by_year_outside_range(api_client):
    SparePartFactory(year_start=2015, year_end=2020)
    response = api_client.get(reverse("parts-list"), {"year": 2022})
    assert response.data["count"] == 0


def test_filter_by_year_open_ended_still_in_production(api_client):
    # year_end=None means "still in production" -> any year >= year_start matches.
    SparePartFactory(year_start=2015, year_end=None)
    response = api_client.get(reverse("parts-list"), {"year": 2030})
    assert response.data["count"] == 1
