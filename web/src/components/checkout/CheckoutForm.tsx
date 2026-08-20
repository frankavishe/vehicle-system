"use client";

import { useState } from "react";

import { Button } from "@/components/ui/Button";
import { Field, Textarea } from "@/components/ui/Field";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import { PAYMENT_METHODS, type InitiatePaymentResult, type Order, type PaymentMethod } from "@/lib/types";

/** Delivery address → payment-method picker → create the order → initiate
 * the gateway charge → redirect to its hosted checkout_url. PLAN.md §5.3:
 * the gateway is chosen internally from `payment_method`, invisible to
 * the customer beyond which wallet they picked. */
export function CheckoutForm() {
  const [address, setAddress] = useState("");
  const [method, setMethod] = useState<PaymentMethod>("MPESA");
  const [status, setStatus] = useState<"idle" | "submitting">("idle");
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setStatus("submitting");
    setError(null);
    try {
      const order = await apiFetch<Order>("/orders", {
        method: "POST",
        body: { delivery_address: address },
      });
      const payment = await apiFetch<InitiatePaymentResult>(`/orders/${order.id}/pay`, {
        method: "POST",
        body: { payment_method: method },
      });
      window.location.href = payment.checkout_url;
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Checkout failed. Please try again.");
      setStatus("idle");
    }
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-6">
      <Field label="Delivery address" htmlFor="address">
        <Textarea
          id="address"
          required
          rows={3}
          placeholder="Street, ward, district, city"
          value={address}
          onChange={(e) => setAddress(e.target.value)}
        />
      </Field>

      <fieldset className="flex flex-col gap-2">
        <legend className="mb-1 text-xs font-semibold uppercase tracking-wide text-steel">
          Pay with
        </legend>
        {PAYMENT_METHODS.map((option) => (
          <label
            key={option.value}
            className="flex cursor-pointer items-center gap-3 border border-line bg-surface-raised px-3 py-2.5 text-sm has-[:checked]:border-asphalt"
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
        {status === "submitting" ? "Taking you to payment…" : "Pay now"}
      </Button>
    </form>
  );
}
