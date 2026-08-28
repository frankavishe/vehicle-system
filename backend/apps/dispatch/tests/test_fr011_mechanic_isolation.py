"""T030 (specs/001-mechanic-web-portal/tasks.md): spot-check FR-011 (tenant
isolation) across every endpoint the Mechanic Web Portal touches, using a
second mechanic account. PENDING/unclaimed jobs are intentionally visible
to every same-type provider (they're open offers, not private data) —
what must never leak is another mechanic's *own* assigned jobs, payouts,
documents, and parts-sourcing requests.
"""

import pytest
from django.urls import reverse
from rest_framework import status

from apps.admin_ops.tests.factories import PayoutFactory
from apps.dispatch.models import ServiceStatus
from apps.dispatch.tests.factories import PartsSourcingRequestFactory, ServiceRequestFactory
from apps.providers.models import ProviderDocument
from apps.users.tests.factories import UserFactory

pytestmark = pytest.mark.django_db


@pytest.fixture
def second_mechanic_user():
    return UserFactory(role="MECHANIC")


def test_service_request_list_hides_other_mechanics_assigned_jobs(
    auth_client, mechanic_user, second_mechanic_user
):
    mine = ServiceRequestFactory(provider=mechanic_user, status=ServiceStatus.ACCEPTED)
    theirs = ServiceRequestFactory(provider=second_mechanic_user, status=ServiceStatus.ACCEPTED)

    client = auth_client(mechanic_user)
    response = client.get(reverse("service-requests-list-create"))

    ids = {row["id"] for row in response.data}
    assert str(mine.id) in ids
    assert str(theirs.id) not in ids


def test_service_request_detail_404s_for_non_assigned_mechanic(
    auth_client, mechanic_user, second_mechanic_user
):
    theirs = ServiceRequestFactory(provider=second_mechanic_user, status=ServiceStatus.ACCEPTED)

    client = auth_client(mechanic_user)
    response = client.get(reverse("service-requests-detail", args=[theirs.id]))

    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_parts_requests_hidden_from_non_assigned_mechanic(
    auth_client, mechanic_user, second_mechanic_user
):
    theirs_sr = ServiceRequestFactory(provider=second_mechanic_user, status=ServiceStatus.ACCEPTED)
    PartsSourcingRequestFactory(service_request=theirs_sr, requested_by=second_mechanic_user)

    client = auth_client(mechanic_user)
    response = client.get(reverse("parts-requests-list-create", args=[theirs_sr.id]))

    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_payouts_hidden_from_other_mechanic(auth_client, mechanic_user, second_mechanic_user):
    PayoutFactory(provider=second_mechanic_user, amount="55555.00")

    client = auth_client(mechanic_user)
    response = client.get(reverse("provider-payouts"))

    assert response.data["count"] == 0


def test_documents_hidden_from_other_mechanic(auth_client, mechanic_user, second_mechanic_user):
    from django.core.files.uploadedfile import SimpleUploadedFile

    ProviderDocument.objects.create(
        provider=second_mechanic_user,
        doc_type="LICENSE",
        file=SimpleUploadedFile("theirs.pdf", b"%PDF-1.4 fake", content_type="application/pdf"),
    )

    client = auth_client(mechanic_user)
    response = client.get(reverse("provider-documents"))

    results = response.data["results"] if "results" in response.data else response.data
    assert len(results) == 0
