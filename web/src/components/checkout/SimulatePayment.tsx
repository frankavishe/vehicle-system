"use client";

import { useState } from "react";

import { Button } from "@/components/ui/Button";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";

type Outcome = "SUCCESSFUL" | "FAILED";

/** TEMPORARY stand-in for a real Flutterwave/Selcom hosted-checkout page —
 * see PAYMENT_SIMULATION_MODE's docstring in
 * backend/config/settings/base.py for the full removal list (this
 * component + its page.tsx are on it). Posts straight to
 * PaymentSimulateView (backend/apps/orders/views.py), which applies the
 * outcome the same way a real gateway webhook would, then follows the
 * gateway's own redirect_url on to /checkout/complete. */
export function SimulatePayment({ paymentId, redirectUrl }: { paymentId: string; redirectUrl: string }) {
  const [status, setStatus] = useState<"idle" | "submitting">("idle");
  const [error, setError] = useState<string | null>(null);

  async function resolve(outcome: Outcome) {
    setStatus("submitting");
    setError(null);
    try {
      await apiFetch(`/payments/${paymentId}/simulate`, { method: "POST", body: { outcome } });
      window.location.href = redirectUrl;
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't simulate that outcome.");
      setStatus("idle");
    }
  }

  return (
    <div className="flex flex-col items-center gap-4 border-2 border-line bg-surface-raised p-10 text-center">
      <p className="text-xs font-semibold uppercase tracking-wide text-steel">
        Simulated gateway — no real money moves
      </p>
      <h1 className="font-display text-2xl font-bold uppercase tracking-tight text-asphalt">Test payment</h1>
      <p className="text-sm text-steel">Standing in for the real Flutterwave/Selcom hosted checkout page.</p>
      {error ? <p className="text-sm text-stop">{error}</p> : null}
      <div className="flex flex-col gap-3 sm:flex-row">
        <Button onClick={() => resolve("SUCCESSFUL")} disabled={status === "submitting"}>
          Simulate successful payment
        </Button>
        <Button variant="danger" onClick={() => resolve("FAILED")} disabled={status === "submitting"}>
          Simulate failed payment
        </Button>
      </div>
    </div>
  );
}
