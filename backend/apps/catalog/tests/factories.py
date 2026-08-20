import factory
from factory.django import DjangoModelFactory

from apps.catalog.models import SparePart, Vendor


class VendorFactory(DjangoModelFactory):
    class Meta:
        model = Vendor

    name = factory.Sequence(lambda n: f"Vendor {n}")
    contact_email = factory.Sequence(lambda n: f"vendor{n}@example.com")
    contact_phone = factory.Sequence(lambda n: f"25571100{n:04d}")
    is_active = True


class SparePartFactory(DjangoModelFactory):
    class Meta:
        model = SparePart

    vendor = factory.SubFactory(VendorFactory)
    title = factory.Sequence(lambda n: f"Brake Pad {n}")
    sku = factory.Sequence(lambda n: f"SKU-{n:05d}")
    description = "A quality auto spare part."
    price = "25000.00"
    stock_quantity = 10
    category = "Brakes"
    compatible_make = "Toyota"
    compatible_model = "Hilux"
    year_start = 2015
    year_end = 2022
    image_url = "https://example.com/part.jpg"
