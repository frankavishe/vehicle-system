"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";

import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Field";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import { useCartCount } from "@/lib/cart/CartCountProvider";
import { formatTZS } from "@/lib/format";
import type { Cart, CartItem } from "@/lib/types";

export function CartTable({ initialCart }: { initialCart: Cart }) {
  const router = useRouter();
  const { setCount } = useCartCount();
  const [cart, setCart] = useState(initialCart);
  const [error, setError] = useState<string | null>(null);
  const [pendingId, setPendingId] = useState<string | null>(null);

  function syncCount(items: CartItem[]) {
    setCount(items.reduce((sum, item) => sum + item.quantity, 0));
  }

  async function updateQuantity(item: CartItem, quantity: number) {
    if (quantity < 1) return;
    setPendingId(item.id);
    setError(null);
    try {
      await apiFetch<CartItem>(`/cart/items/${item.id}`, { method: "PATCH", body: { quantity } });
      const items = cart.items.map((i) => (i.id === item.id ? { ...i, quantity } : i));
      setCart({ ...cart, items });
      syncCount(items);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't update that line.");
    } finally {
      setPendingId(null);
    }
  }

  async function remove(item: CartItem) {
    setPendingId(item.id);
    setError(null);
    try {
      await apiFetch(`/cart/items/${item.id}`, { method: "DELETE" });
      const items = cart.items.filter((i) => i.id !== item.id);
      setCart({ ...cart, items });
      syncCount(items);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't remove that line.");
    } finally {
      setPendingId(null);
    }
  }

  if (cart.items.length === 0) {
    return (
      <div className="border border-dashed border-line bg-surface-raised p-10 text-center">
        <p className="text-sm text-steel">Your cart is empty.</p>
        <Link href="/catalog" className="mt-3 inline-block text-sm font-semibold text-signal hover:text-signal-dark">
          Browse the catalog →
        </Link>
      </div>
    );
  }

  const total = cart.items.reduce((sum, item) => sum + Number(item.spare_part.price) * item.quantity, 0);

  return (
    <div className="flex flex-col gap-4">
      {error ? <p className="text-sm text-stop">{error}</p> : null}

      <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
        {cart.items.map((item) => (
          <div key={item.id} className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between">
            <div className="flex flex-col gap-0.5">
              <Link href={`/catalog/${item.spare_part.id}`} className="text-sm font-semibold text-asphalt hover:text-signal">
                {item.spare_part.title}
              </Link>
              <span className="font-mono text-xs text-steel-soft">
                SKU {item.spare_part.sku} · {formatTZS(item.spare_part.price)} each
              </span>
            </div>
            <div className="flex items-center gap-3">
              <Input
                type="number"
                min={1}
                max={item.spare_part.stock_quantity}
                value={item.quantity}
                disabled={pendingId === item.id}
                onChange={(e) => updateQuantity(item, Number(e.target.value))}
                className="w-20"
                aria-label={`Quantity for ${item.spare_part.title}`}
              />
              <span className="w-28 text-right font-mono text-sm font-semibold text-asphalt">
                {formatTZS(Number(item.spare_part.price) * item.quantity)}
              </span>
              <Button variant="ghost" disabled={pendingId === item.id} onClick={() => remove(item)}>
                Remove
              </Button>
            </div>
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between border border-line bg-surface-raised p-4">
        <span className="text-sm font-semibold uppercase tracking-wide text-steel">Total</span>
        <span className="font-mono text-xl font-semibold text-asphalt">{formatTZS(total)}</span>
      </div>

      <Button onClick={() => router.push("/checkout")} className="self-end">
        Proceed to checkout
      </Button>
    </div>
  );
}
