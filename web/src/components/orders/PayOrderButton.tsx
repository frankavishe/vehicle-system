"use client";

import { useState } from "react";
import type { FormEvent } from "react";

import { Button } from "@/components/ui/Button";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import { PAYMENT_METHODS, type InitiatePaymentResult, type PaymentMethod } from "@/lib/types";

/** Mirrors CheckoutForm's payment-method picker (web/src/components/checkout/CheckoutForm.tsx),
 * but against an order that already exists — used both by the normal
 * cart-checkout retry path and by orders created outside the cart (e.g.
 * a mechanic's approved parts-sourcing request, which bypasses /checkout
 * entirely). Without this, an order created that way had no way to be
 * paid from the web order page it lands on. */
export function PayOrderButton({ orderId }: { orderId: string }) {
  const [method, setMethod] = useState<PaymentMethod>("MPESA");
  const [expanded, setExpanded] = useState(false);
  const [status, setStatus] = useState<"idle" | "submitting">("idle");
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setStatus("submitting");
    setError(null);
    try {
      const payment = await apiFetch<InitiatePaymentResult>(`/orders/${orderId}/pay`, {
        method: "POST",
        body: { payment_method: method },
      });
      window.location.href = payment.checkout_url;
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't start payment. Please try again.");
      setStatus("idle");
    }
  }

  if (!expanded) {
    return (
      <Button type="button" onClick={() => setExpanded(true)}>
        Pay now
      </Button>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-3 rounded-2xl border border-line bg-surface-raised p-4 shadow-sm">
      <fieldset className="flex flex-col gap-2">
        <legend className="mb-1 text-xs font-medium text-steel">Pay with</legend>
        {PAYMENT_METHODS.map((option) => (
          <label
            key={option.value}
            className="flex cursor-pointer items-center gap-3 rounded-lg border border-line bg-surface px-3 py-2 text-sm has-[:checked]:border-primary has-[:checked]:ring-2 has-[:checked]:ring-primary/20"
          >
            <input
              type="radio"
              name="payment_method"
              value={option.value}
              checked={method === option.value}
              onChange={() => setMethod(option.value)}
            />
            {option.label}
          </label>
        ))}
      </fieldset>

      {error ? <p className="text-sm text-stop">{error}</p> : null}

      <Button type="submit" disabled={status === "submitting"}>
        {status === "submitting" ? "Taking you to payment…" : "Confirm and pay"}
      </Button>
    </form>
  );
}
