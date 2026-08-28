"use client";

import { useEffect, useState } from "react";
import type { FormEvent } from "react";

import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Field, Input, Select } from "@/components/ui/Field";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import type { PartsSourcingRequest, PartsSourcingStatus, ServiceRequestStatus, SparePart } from "@/lib/types";

const statusTone: Record<PartsSourcingStatus, "go" | "stop" | "signal" | "neutral"> = {
  PENDING: "neutral",
  APPROVED: "signal",
  REJECTED: "stop",
  ORDERED: "go",
};

// FR-010's edge case: no new parts request against a job that's no
// longer active. The server doesn't reject by status on this endpoint
// today (only assigned-provider + MECHANIC-service-type checks — see
// specs/001-mechanic-web-portal/data-model.md), so this is a UI-only
// guard layered on top.
const TERMINAL_STATUSES: ServiceRequestStatus[] = ["COMPLETED", "CANCELLED"];

export function PartsSourcingRequestForm({
  serviceRequestId,
  jobStatus,
}: {
  serviceRequestId: string;
  jobStatus: ServiceRequestStatus;
}) {
  const [requests, setRequests] = useState<PartsSourcingRequest[]>([]);
  const [loadError, setLoadError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    apiFetch<PartsSourcingRequest[]>(`/service-requests/${serviceRequestId}/parts-requests`)
      .then((data) => {
        if (!cancelled) setRequests(data);
      })
      .catch((err) => {
        if (!cancelled) setLoadError(err instanceof ApiError ? err.message : "Couldn't load parts requests.");
      });
    return () => {
      cancelled = true;
    };
  }, [serviceRequestId]);

  const isActive = !TERMINAL_STATUSES.includes(jobStatus);

  return (
    <div className="flex flex-col gap-4">
      <h2 className="font-display text-xl font-bold uppercase tracking-tight text-asphalt">
        Parts sourcing
      </h2>

      {isActive ? (
        <RequestForm
          serviceRequestId={serviceRequestId}
          onCreated={(created) => setRequests([created, ...requests])}
        />
      ) : (
        <p className="border border-line bg-surface-raised p-4 text-sm text-steel-soft">
          This job is no longer active — new parts requests can&apos;t be submitted against it.
        </p>
      )}

      {loadError && <p className="text-sm text-stop">{loadError}</p>}

      <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
        {requests.length === 0 && (
          <p className="p-4 text-sm text-steel-soft">No parts requested for this job yet.</p>
        )}
        {requests.map((request) => (
          <div key={request.id} className="flex items-center justify-between gap-4 p-4">
            <span className="text-sm text-steel">Qty {request.quantity}</span>
            <Badge tone={statusTone[request.status]}>{request.status}</Badge>
          </div>
        ))}
      </div>
    </div>
  );
}

function RequestForm({
  serviceRequestId,
  onCreated,
}: {
  serviceRequestId: string;
  onCreated: (request: PartsSourcingRequest) => void;
}) {
  const [parts, setParts] = useState<SparePart[]>([]);
  const [sparePartId, setSparePartId] = useState("");
  const [quantity, setQuantity] = useState(1);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    apiFetch<{ results: SparePart[] }>("/parts")
      .then((page) => setParts(page.results))
      .catch(() => setParts([]));
  }, []);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (!sparePartId) {
      setError("Choose a spare part.");
      return;
    }
    setSubmitting(true);
    setError(null);
    try {
      const created = await apiFetch<PartsSourcingRequest>(
        `/service-requests/${serviceRequestId}/parts-requests`,
        { method: "POST", body: { spare_part_id: sparePartId, quantity } },
      );
      onCreated(created);
      setSparePartId("");
      setQuantity(1);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't submit this parts request.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="flex flex-col gap-3 border border-line bg-surface-raised p-4 sm:flex-row sm:items-end"
    >
      <Field label="Spare part" htmlFor="parts-request-part">
        <Select
          id="parts-request-part"
          required
          value={sparePartId}
          onChange={(e) => setSparePartId(e.target.value)}
        >
          <option value="">Select a part…</option>
          {parts.map((part) => (
            <option key={part.id} value={part.id}>
              {part.title} ({part.sku})
            </option>
          ))}
        </Select>
      </Field>
      <Field label="Quantity" htmlFor="parts-request-quantity">
        <Input
          id="parts-request-quantity"
          type="number"
          min={1}
          required
          value={quantity}
          onChange={(e) => setQuantity(Number(e.target.value))}
        />
      </Field>
      <Button type="submit" disabled={submitting}>
        {submitting ? "Submitting…" : "Request part"}
      </Button>
      {error && <p className="text-sm text-stop">{error}</p>}
    </form>
  );
}
