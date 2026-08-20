import factory
from factory.django import DjangoModelFactory

from apps.catalog.tests.factories import SparePartFactory
from apps.orders.models import Cart, CartItem, Order, OrderItem, OrderShipment, Payment


class CartFactory(DjangoModelFactory):
    class Meta:
        model = Cart

    customer = factory.SubFactory("apps.users.tests.factories.UserFactory")


class CartItemFactory(DjangoModelFactory):
    class Meta:
        model = CartItem

    cart = factory.SubFactory(CartFactory)
    spare_part = factory.SubFactory(SparePartFactory)
    quantity = 1


class OrderFactory(DjangoModelFactory):
    class Meta:
        model = Order

    customer = factory.SubFactory("apps.users.tests.factories.UserFactory")
    total_amount = "0.00"
    delivery_address = "123 Uhuru St, Dar es Salaam"


class OrderItemFactory(DjangoModelFactory):
    class Meta:
        model = OrderItem

    order = factory.SubFactory(OrderFactory)
    spare_part = factory.SubFactory(SparePartFactory)
    quantity = 1
    unit_price = "25000.00"


class OrderShipmentFactory(DjangoModelFactory):
    class Meta:
        model = OrderShipment

    order = factory.SubFactory(OrderFactory)


class PaymentFactory(DjangoModelFactory):
    class Meta:
        model = Payment

    order = factory.SubFactory(OrderFactory)
    payment_method = "CARD"
    provider_gateway = "FLUTTERWAVE"
    amount = "25000.00"
    transaction_ref = factory.Sequence(lambda n: f"tx-ref-{n}")
