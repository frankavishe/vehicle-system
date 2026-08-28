"use client";

import { useState } from "react";
import type { FormEvent } from "react";

import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Field, Input } from "@/components/ui/Field";
import { apiUpload } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import { formatDate } from "@/lib/format";
import type { ProviderDocument } from "@/lib/types";

export function DocumentUploadList({ initialDocuments }: { initialDocuments: ProviderDocument[] }) {
  const [documents, setDocuments] = useState(initialDocuments);

  return (
    <div className="flex flex-col gap-6">
      <UploadForm onUploaded={(doc) => setDocuments([doc, ...documents])} />

      <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
        {documents.length === 0 && (
          <p className="p-4 text-sm text-steel-soft">No documents uploaded yet.</p>
        )}
        {documents.map((doc) => (
          <div key={doc.id} className="flex items-center justify-between gap-4 p-4">
            <div className="flex flex-col gap-0.5">
              <span className="text-sm font-semibold text-asphalt">{doc.doc_type ?? "Document"}</span>
              <span className="text-xs text-steel-soft">Uploaded {formatDate(doc.uploaded_at)}</span>
            </div>
            <Badge tone={doc.verified ? "go" : "neutral"}>
              {doc.verified ? "Verified" : "Pending verification"}
            </Badge>
          </div>
        ))}
      </div>
    </div>
  );
}

function UploadForm({ onUploaded }: { onUploaded: (doc: ProviderDocument) => void }) {
  const [docType, setDocType] = useState("");
  const [file, setFile] = useState<File | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (!file) {
      setError("Choose a file to upload.");
      return;
    }
    setSubmitting(true);
    setError(null);
    try {
      const formData = new FormData();
      formData.set("doc_type", docType);
      formData.set("file", file);
      const created = await apiUpload<ProviderDocument>("/providers/me/documents", formData);
      onUploaded(created);
      setDocType("");
      setFile(null);
    } catch (err) {
      // On failure the selected file/doc_type are left in place (not
      // cleared) so the mechanic can just retry — and since nothing was
      // added to `documents` above, retrying can't create a duplicate/
      // partial entry (edge case: a failed upload must be retryable
      // without duplicating a partial document).
      setError(err instanceof ApiError ? err.message : "Upload failed — check your connection and retry.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="flex flex-col gap-3 border border-line bg-surface-raised p-4 sm:flex-row sm:items-end"
    >
      <Field label="Document type" htmlFor="doc-type">
        <Input
          id="doc-type"
          required
          value={docType}
          onChange={(e) => setDocType(e.target.value)}
          placeholder="e.g. LICENSE"
        />
      </Field>
      <Field label="File" htmlFor="doc-file">
        <Input
          id="doc-file"
          type="file"
          required
          onChange={(e) => setFile(e.target.files?.[0] ?? null)}
        />
      </Field>
      <Button type="submit" disabled={submitting}>
        {submitting ? "Uploading…" : "Upload"}
      </Button>
      {error && <p className="text-sm text-stop">{error}</p>}
    </form>
  );
}
