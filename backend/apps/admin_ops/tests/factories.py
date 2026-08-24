import factory
from factory.django import DjangoModelFactory

from apps.admin_ops.models import Dispute, Payout, PayoutItem
from apps.dispatch.tests.factories import ServiceRequestFactory


class DisputeFactory(DjangoModelFactory):
    class Meta:
        model = Dispute

    service_request = factory.SubFactory(ServiceRequestFactory)
    raised_by = factory.SubFactory("apps.users.tests.factories.UserFactory")
    reason = "Provider never showed up."


class PayoutFactory(DjangoModelFactory):
    class Meta:
        model = Payout

    provider = factory.SubFactory("apps.users.tests.factories.UserFactory")
    amount = "4250.00"
    provider_gateway = "FLUTTERWAVE"


class PayoutItemFactory(DjangoModelFactory):
    class Meta:
        model = PayoutItem

    payout = factory.SubFactory(PayoutFactory)
    service_request = factory.SubFactory(ServiceRequestFactory)
    amount = "4250.00"
