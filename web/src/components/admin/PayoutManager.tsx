"use client";

import { useState } from "react";

import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Field, Input } from "@/components/ui/Field";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import { formatDate, formatTZS } from "@/lib/format";
import type { Payout, PayoutStatus } from "@/lib/types";

const statusTone: Record<PayoutStatus, "go" | "stop" | "signal" | "neutral"> = {
  PENDING: "neutral",
  PROCESSING: "signal",
  PAID: "go",
  FAILED: "stop",
};

export function PayoutManager({ initialPayouts }: { initialPayouts: Payout[] }) {
  const [payouts, setPayouts] = useState(initialPayouts);

  return (
    <div className="flex flex-col gap-6">
      <ManualTriggerForm onTriggered={(created) => setPayouts([...created, ...payouts])} />

      <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
        {payouts.length === 0 && <p className="p-4 text-sm text-steel-soft">No payouts yet.</p>}
        {payouts.map((payout) => (
          <div key={payout.id} className="flex items-center justify-between gap-4 p-4">
            <div className="flex flex-col gap-0.5">
              <span className="font-mono text-xs text-steel-soft">
                Provider {payout.provider.slice(0, 8)} · {formatDate(payout.created_at)}
                {payout.is_manual ? " · manual" : ""}
              </span>
              <span className="text-sm text-steel">{payout.items.length} completed job(s)</span>
            </div>
            <div className="flex items-center gap-3">
              <span className="font-mono text-sm text-asphalt">{formatTZS(payout.amount)}</span>
              <Badge tone={statusTone[payout.status]}>{payout.status}</Badge>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function ManualTriggerForm({ onTriggered }: { onTriggered: (payouts: Payout[]) => void }) {
  const [providerId, setProviderId] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const created = await apiFetch<Payout[]>(`/admin/payouts/${providerId}/trigger`, {
        method: "POST",
      });
      onTriggered(created);
      setProviderId("");
    } catch (err) {
      setError(
        err instanceof ApiError ? err.message : "Couldn't trigger a payout for that provider.",
      );
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="flex flex-col gap-3 border border-line bg-surface-raised p-4 sm:flex-row sm:items-end"
    >
      <Field label="Provider ID (manual / off-cycle payout)" htmlFor="manual-payout-provider">
        <Input
          id="manual-payout-provider"
          required
          value={providerId}
          onChange={(e) => setProviderId(e.target.value)}
          placeholder="Provider's UUID"
        />
      </Field>
      <Button type="submit" disabled={submitting}>
        {submitting ? "Triggering…" : "Trigger payout"}
      </Button>
      {error ? <p className="text-sm text-stop">{error}</p> : null}
    </form>
  );
}
