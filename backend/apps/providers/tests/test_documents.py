import pytest
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from rest_framework import status

from apps.providers.models import ProviderDocument

pytestmark = pytest.mark.django_db


def _file(name="license.pdf"):
    return SimpleUploadedFile(name, b"%PDF-1.4 fake content", content_type="application/pdf")


def test_mechanic_uploads_document(auth_client, mechanic_user):
    client = auth_client(mechanic_user)
    response = client.post(
        reverse("provider-documents"),
        {"doc_type": "LICENSE", "file": _file()},
        format="multipart",
    )
    assert response.status_code == status.HTTP_201_CREATED
    assert response.data["doc_type"] == "LICENSE"
    assert response.data["verified"] is False
    assert response.data["file_url"]
    assert ProviderDocument.objects.filter(provider=mechanic_user).exists()


def test_missing_file_rejected(auth_client, mechanic_user):
    client = auth_client(mechanic_user)
    response = client.post(
        reverse("provider-documents"), {"doc_type": "LICENSE"}, format="multipart"
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_list_scoped_to_own_uploads(auth_client, mechanic_user, recovery_user):
    ProviderDocument.objects.create(provider=mechanic_user, doc_type="LICENSE", file=_file("a.pdf"))
    ProviderDocument.objects.create(provider=recovery_user, doc_type="LICENSE", file=_file("b.pdf"))

    client = auth_client(mechanic_user)
    response = client.get(reverse("provider-documents"))
    assert response.status_code == status.HTTP_200_OK
    results = response.data["results"] if "results" in response.data else response.data
    assert len(results) == 1


def test_customer_cannot_upload(auth_client, customer_user):
    client = auth_client(customer_user)
    response = client.post(
        reverse("provider-documents"), {"doc_type": "LICENSE", "file": _file()}, format="multipart"
    )
    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_documents_require_auth(api_client):
    response = api_client.get(reverse("provider-documents"))
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
