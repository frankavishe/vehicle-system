"use client";

import Link from "next/link";
import { useEffect, useRef, useState } from "react";

import { Button } from "@/components/ui/Button";
import { apiFetch } from "@/lib/api/client";
import type { Order } from "@/lib/types";

const POLL_INTERVAL_MS = 3000;
const MAX_POLLS = 40; // ~2 minutes — mobile money confirmations can lag

/** Polls GET /orders/{id} rather than trusting the gateway's own redirect
 * query string (PLAN.md §5.3: "Django never trusts the client-side
 * redirect result") — the webhook is the only thing that ever moves the
 * order out of PENDING, so this page just watches for that to happen. */
export function CheckoutStatus({ orderId }: { orderId: string }) {
  const [order, setOrder] = useState<Order | null>(null);
  const [pollCount, setPollCount] = useState(0);
  const [failed, setFailed] = useState(false);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function poll() {
      try {
        const latest = await apiFetch<Order>(`/orders/${orderId}`);
        if (cancelled) return;
        setOrder(latest);
        if (latest.status === "PENDING" && pollCount < MAX_POLLS) {
          timer.current = setTimeout(() => setPollCount((n) => n + 1), POLL_INTERVAL_MS);
        }
      } catch {
        if (!cancelled) setFailed(true);
      }
    }
    poll();

    return () => {
      cancelled = true;
      if (timer.current) clearTimeout(timer.current);
    };
  }, [orderId, pollCount]);

  if (failed) {
    return (
      <StatusCard tone="stop" title="We lost track of that order">
        <p>Check your order history to see the latest status.</p>
        <Link href="/orders" className="text-sm font-semibold text-signal hover:text-signal-dark">
          View my orders →
        </Link>
      </StatusCard>
    );
  }

  if (!order) {
    return <StatusCard tone="neutral" title="Checking payment status…" />;
  }

  if (order.status === "PENDING") {
    const stillWaiting = pollCount >= MAX_POLLS;
    return (
      <StatusCard tone={stillWaiting ? "stop" : "neutral"} title="Waiting for payment confirmation">
        <p>
          {stillWaiting
            ? "This is taking longer than usual — mobile money confirmations can lag a few minutes. Check your order history shortly."
            : "Complete payment in the window that opened. This page updates automatically."}
        </p>
        {stillWaiting && (
          <Button variant="ghost" onClick={() => setPollCount(0)}>
            Check again
          </Button>
        )}
      </StatusCard>
    );
  }

  if (order.status === "CANCELLED") {
    return (
      <StatusCard tone="stop" title="Order cancelled">
        <p>This order was cancelled before payment completed.</p>
        <Link href="/cart" className="text-sm font-semibold text-signal hover:text-signal-dark">
          Back to cart →
        </Link>
      </StatusCard>
    );
  }

  return (
    <StatusCard tone="go" title="Payment confirmed">
      <p>Order #{order.id.slice(0, 8)} is {order.status.toLowerCase()}. We&apos;ll keep you posted on delivery.</p>
      <Link href={`/orders/${order.id}`} className="text-sm font-semibold text-signal hover:text-signal-dark">
        View order →
      </Link>
    </StatusCard>
  );
}

function StatusCard({
  tone,
  title,
  children,
}: {
  tone: "go" | "stop" | "neutral";
  title: string;
  children?: React.ReactNode;
}) {
  const borders = { go: "border-go", stop: "border-stop", neutral: "border-line" };
  return (
    <div className={`flex flex-col items-center gap-3 border-2 bg-surface-raised p-10 text-center ${borders[tone]}`}>
      <h1 className="font-display text-2xl font-bold uppercase tracking-tight text-asphalt">{title}</h1>
      {children}
    </div>
  );
}
