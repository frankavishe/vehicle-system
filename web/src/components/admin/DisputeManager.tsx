"use client";

import { useState } from "react";

import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import { formatDate } from "@/lib/format";
import type { Dispute } from "@/lib/types";

export function DisputeManager({ initialDisputes }: { initialDisputes: Dispute[] }) {
  const [disputes, setDisputes] = useState(initialDisputes);

  return (
    <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
      {disputes.length === 0 && <p className="p-4 text-sm text-steel-soft">No disputes on file.</p>}
      {disputes.map((dispute) => (
        <DisputeRow
          key={dispute.id}
          dispute={dispute}
          onResolved={(updated) =>
            setDisputes(disputes.map((d) => (d.id === updated.id ? updated : d)))
          }
        />
      ))}
    </div>
  );
}

function DisputeRow({
  dispute,
  onResolved,
}: {
  dispute: Dispute;
  onResolved: (dispute: Dispute) => void;
}) {
  const [resolving, setResolving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function resolve() {
    setResolving(true);
    setError(null);
    try {
      const updated = await apiFetch<Dispute>(`/admin/disputes/${dispute.id}/resolve`, {
        method: "PATCH",
      });
      onResolved(updated);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't resolve that dispute.");
    } finally {
      setResolving(false);
    }
  }

  return (
    <div className="flex items-center justify-between gap-4 p-4">
      <div className="flex flex-col gap-0.5">
        <span className="font-mono text-xs text-steel-soft">
          Service request {dispute.service_request.slice(0, 8)} · {formatDate(dispute.created_at)}
        </span>
        <span className="text-sm text-steel">{dispute.reason}</span>
      </div>
      <div className="flex items-center gap-3">
        <Badge tone={dispute.status === "OPEN" ? "stop" : "go"}>{dispute.status}</Badge>
        {dispute.status === "OPEN" && (
          <Button variant="secondary" disabled={resolving} onClick={resolve}>
            {resolving ? "Resolving…" : "Resolve"}
          </Button>
        )}
      </div>
      {error && <p className="text-sm text-stop">{error}</p>}
    </div>
  );
}
