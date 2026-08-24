import factory
from django.contrib.gis.geos import Point
from factory.django import DjangoModelFactory

from apps.catalog.tests.factories import SparePartFactory
from apps.dispatch.models import PartsSourcingRequest, ServiceRequest, ServiceType

# Dar es Salaam coordinates, matching apps/providers' existing test fixtures.
DAR_ES_SALAAM = Point(39.2083, -6.7924, srid=4326)


class ServiceRequestFactory(DjangoModelFactory):
    class Meta:
        model = ServiceRequest

    customer = factory.SubFactory("apps.users.tests.factories.UserFactory")
    service_type = ServiceType.MECHANIC
    pickup_location = DAR_ES_SALAAM
    problem_description = "Car won't start."


class PartsSourcingRequestFactory(DjangoModelFactory):
    class Meta:
        model = PartsSourcingRequest

    service_request = factory.SubFactory(ServiceRequestFactory)
    requested_by = factory.SubFactory("apps.users.tests.factories.UserFactory")
    spare_part = factory.SubFactory(SparePartFactory)
    quantity = 1
