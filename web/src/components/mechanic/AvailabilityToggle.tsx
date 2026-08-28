"use client";

import { useState } from "react";

import { Button } from "@/components/ui/Button";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";

export function AvailabilityToggle({ initialIsAvailable }: { initialIsAvailable: boolean }) {
  const [isAvailable, setIsAvailable] = useState(initialIsAvailable);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function toggle() {
    setSaving(true);
    setError(null);
    const next = !isAvailable;
    try {
      const updated = await apiFetch<{ is_available: boolean }>("/providers/me/availability", {
        method: "PATCH",
        body: { is_available: next },
      });
      setIsAvailable(updated.is_available);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't update your availability.");
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="flex items-center justify-between gap-4 border border-line bg-surface-raised p-4">
      <div className="flex flex-col gap-0.5">
        <span className="text-xs font-semibold uppercase tracking-wide text-steel">Availability</span>
        <span className="text-sm text-steel">
          {isAvailable ? "You're online — new jobs can reach you." : "You're offline — no new jobs will be offered."}
        </span>
      </div>
      <Button variant={isAvailable ? "danger" : "primary"} disabled={saving} onClick={toggle}>
        {saving ? "Saving…" : isAvailable ? "Go offline" : "Go online"}
      </Button>
      {error && <p className="text-sm text-stop">{error}</p>}
    </div>
  );
}
