import pytest
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.users.models import UserRole
from apps.users.tests.factories import UserFactory


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def auth_client():
    """Usage: `client = auth_client(user)` -> authenticated APIClient."""

    def _make(user):
        client = APIClient()
        token = RefreshToken.for_user(user).access_token
        client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        return client

    return _make


@pytest.fixture
def customer_user(db):
    return UserFactory(role=UserRole.CUSTOMER)


@pytest.fixture
def mechanic_user(db):
    return UserFactory(role=UserRole.MECHANIC)


@pytest.fixture
def recovery_user(db):
    return UserFactory(role=UserRole.RECOVERY)


@pytest.fixture
def admin_user(db):
    return UserFactory(role=UserRole.ADMIN, is_staff=True)
