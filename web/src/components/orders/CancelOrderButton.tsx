"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";

import { Button } from "@/components/ui/Button";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import type { Order } from "@/lib/types";

export function CancelOrderButton({ orderId }: { orderId: string }) {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleCancel() {
    setSubmitting(true);
    setError(null);
    try {
      await apiFetch<Order>(`/orders/${orderId}/cancel`, { method: "POST" });
      router.refresh();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't cancel that order.");
      setSubmitting(false);
    }
  }

  return (
    <div className="flex flex-col items-end gap-1">
      <Button variant="danger" onClick={handleCancel} disabled={submitting}>
        {submitting ? "Cancelling…" : "Cancel order"}
      </Button>
      {error ? <p className="text-xs text-stop">{error}</p> : null}
    </div>
  );
}
