"use client";

import { useState } from "react";

import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Field";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import { formatTZS } from "@/lib/format";
import type { SparePart } from "@/lib/types";

export function InventoryTable({ initialParts }: { initialParts: SparePart[] }) {
  const [parts, setParts] = useState(initialParts);

  return (
    <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
      {parts.map((part) => (
        <InventoryRow
          key={part.id}
          part={part}
          onAdjusted={(updated) => setParts(parts.map((p) => (p.id === updated.id ? updated : p)))}
        />
      ))}
    </div>
  );
}

function InventoryRow({ part, onAdjusted }: { part: SparePart; onAdjusted: (part: SparePart) => void }) {
  const [adjustment, setAdjustment] = useState(0);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function apply() {
    if (adjustment === 0) return;
    setSaving(true);
    setError(null);
    try {
      const updated = await apiFetch<SparePart>(`/admin/parts/${part.id}/stock`, {
        method: "PATCH",
        body: { adjustment },
      });
      onAdjusted(updated);
      setAdjustment(0);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't adjust stock.");
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="flex flex-col gap-2 p-4 sm:flex-row sm:items-center sm:justify-between">
      <div className="flex flex-col gap-0.5">
        <span className="text-sm font-semibold text-asphalt">{part.title}</span>
        <span className="font-mono text-xs text-steel-soft">
          SKU {part.sku} · {formatTZS(part.price)}
        </span>
      </div>
      <div className="flex items-center gap-3">
        <Badge tone={part.stock_quantity === 0 ? "stop" : part.stock_quantity <= 3 ? "stop" : "go"}>
          {part.stock_quantity} in stock
        </Badge>
        <Input
          type="number"
          value={adjustment}
          onChange={(e) => setAdjustment(Number(e.target.value))}
          className="w-24"
          aria-label={`Stock adjustment for ${part.title}`}
        />
        <Button variant="ghost" onClick={apply} disabled={saving || adjustment === 0}>
          {saving ? "Saving…" : "Apply"}
        </Button>
      </div>
      {error ? <p className="text-xs text-stop">{error}</p> : null}
    </div>
  );
}
