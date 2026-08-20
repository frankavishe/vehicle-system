"use client";

import Link from "next/link";
import { useState } from "react";

import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Field";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import { useAuth } from "@/lib/auth/AuthProvider";
import { useCartCount } from "@/lib/cart/CartCountProvider";
import type { CartItem } from "@/lib/types";

export function AddToCart({ sparePartId, stockQuantity }: { sparePartId: string; stockQuantity: number }) {
  const { user } = useAuth();
  const { count, setCount } = useCartCount();
  const [quantity, setQuantity] = useState(1);
  const [status, setStatus] = useState<"idle" | "adding" | "added" | "error">("idle");
  const [error, setError] = useState<string | null>(null);

  if (stockQuantity === 0) {
    return <p className="text-sm font-semibold text-stop">Out of stock — check back soon.</p>;
  }

  if (!user) {
    return (
      <Link href={`/login?next=/catalog`} className="text-sm font-semibold text-signal hover:text-signal-dark">
        Sign in to add this to your cart
      </Link>
    );
  }

  if (user.role !== "CUSTOMER") {
    return <p className="text-sm text-steel-soft">Only customer accounts can buy parts.</p>;
  }

  async function handleAdd() {
    setStatus("adding");
    setError(null);
    try {
      await apiFetch<CartItem>("/cart/items", {
        method: "POST",
        body: { spare_part_id: sparePartId, quantity },
      });
      setCount(count + quantity);
      setStatus("added");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't add that to your cart.");
      setStatus("error");
    }
  }

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center gap-3">
        <Input
          type="number"
          min={1}
          max={stockQuantity}
          value={quantity}
          onChange={(e) => setQuantity(Math.max(1, Number(e.target.value)))}
          className="w-20"
          aria-label="Quantity"
        />
        <Button onClick={handleAdd} disabled={status === "adding"} className="flex-1">
          {status === "adding" ? "Adding…" : status === "added" ? "Added ✓" : "Add to cart"}
        </Button>
      </div>
      {error ? <p className="text-sm text-stop">{error}</p> : null}
    </div>
  );
}
