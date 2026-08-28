import { DocumentUploadList } from "@/components/mechanic/DocumentUploadList";
import { apiFetch } from "@/lib/api/server";
import type { ProviderDocument } from "@/lib/types";

export default async function MechanicDocumentsPage() {
  const page = await apiFetch<{ results: ProviderDocument[] }>("/providers/me/documents");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Documents</h1>
      <DocumentUploadList initialDocuments={page.results} />
    </div>
  );
}
