import factory
from factory.django import DjangoModelFactory

from apps.users.models import User, UserRole


class UserFactory(DjangoModelFactory):
    class Meta:
        model = User
        django_get_or_create = ("email",)
        skip_postgeneration_save = True

    email = factory.Sequence(lambda n: f"user{n}@example.com")
    phone = factory.Sequence(lambda n: f"25571000{n:04d}")
    full_name = factory.Faker("name")
    role = UserRole.CUSTOMER
    is_verified = True

    @factory.post_generation
    def password(self, create, extracted, **kwargs):
        self.set_password(extracted or "TestPass123!")
        if create:
            self.save()
