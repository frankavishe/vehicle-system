"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import type { FormEvent } from "react";

import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Field, Input } from "@/components/ui/Field";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import type { PartsSourcingRequest, PartsSourcingStatus } from "@/lib/types";

const statusTone: Record<PartsSourcingStatus, "go" | "stop" | "signal" | "neutral"> = {
  PENDING: "neutral",
  APPROVED: "signal",
  REJECTED: "stop",
  ORDERED: "go",
};

/** Customer-side counterpart to the mechanic's in-job "Parts sourcing"
 * picker (web/src/components/mechanic/PartsSourcingRequestForm.tsx) —
 * mirrors mobile's "Parts requested by your mechanic" section
 * (mobile/lib/features/customer/screens/request_detail_screen.dart).
 * Approve/reject a PENDING request, then convert an APPROVED one to a
 * real order and land on its (now payable) /orders/[id] page. */
export function PartsRequestApproval({ serviceRequestId }: { serviceRequestId: string }) {
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

  if (loadError) return <p className="text-sm text-stop">{loadError}</p>;
  if (requests.length === 0) return null;

  function updateRequest(updated: PartsSourcingRequest) {
    setRequests((current) => current.map((r) => (r.id === updated.id ? updated : r)));
  }

  return (
    <div className="flex flex-col gap-3">
      <h2 className="font-display text-xl font-bold text-asphalt">Parts requested by your mechanic</h2>
      <div className="flex flex-col gap-3">
        {requests.map((request) => (
          <PartsRequestRow key={request.id} request={request} onUpdated={updateRequest} />
        ))}
      </div>
    </div>
  );
}

function PartsRequestRow({
  request,
  onUpdated,
}: {
  request: PartsSourcingRequest;
  onUpdated: (updated: PartsSourcingRequest) => void;
}) {
  const router = useRouter();
  const [address, setAddress] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function respond(approved: boolean) {
    setBusy(true);
    setError(null);
    try {
      const updated = await apiFetch<PartsSourcingRequest>(`/parts-requests/${request.id}/approve`, {
        method: "PATCH",
        body: { approved },
      });
      onUpdated(updated);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't record your response.");
    } finally {
      setBusy(false);
    }
  }

  async function buyNow(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const result = await apiFetch<{ order_id: string; parts_request: PartsSourcingRequest }>(
        `/parts-requests/${request.id}/order`,
        { method: "POST", body: { delivery_address: address || undefined } },
      );
      onUpdated(result.parts_request);
      router.push(`/orders/${result.order_id}`);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't place that order.");
      setBusy(false);
    }
  }

  return (
    <div className="flex flex-col gap-3 rounded-2xl border border-line bg-surface-raised p-4 shadow-sm">
      <div className="flex items-center justify-between gap-4">
        <span className="text-sm text-steel">Qty {request.quantity}</span>
        <Badge tone={statusTone[request.status]}>{request.status}</Badge>
      </div>

      {request.status === "PENDING" && (
        <div className="flex gap-2">
          <Button onClick={() => respond(true)} disabled={busy}>
            Approve
          </Button>
          <Button variant="danger" onClick={() => respond(false)} disabled={busy}>
            Reject
          </Button>
        </div>
      )}

      {request.status === "APPROVED" && (
        <form onSubmit={buyNow} className="flex flex-col gap-3 sm:flex-row sm:items-end">
          <div className="flex-1">
            <Field label="Delivery address" htmlFor={`delivery-${request.id}`}>
              <Input
                id={`delivery-${request.id}`}
                required
                placeholder="Street, ward, district, city"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
              />
            </Field>
          </div>
          <Button type="submit" disabled={busy}>
            {busy ? "Placing order…" : "Buy now"}
          </Button>
        </form>
      )}

      {error && <p className="text-sm text-stop">{error}</p>}
    </div>
  );
}
