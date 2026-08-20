import { redirect } from "next/navigation";

import { CheckoutForm } from "@/components/checkout/CheckoutForm";
import { apiFetch } from "@/lib/api/server";
import { getSession } from "@/lib/auth/session";
import { formatTZS } from "@/lib/format";
import type { Cart } from "@/lib/types";

export default async function CheckoutPage() {
  const user = await getSession();
  if (!user) redirect("/login?next=/checkout");
  if (user.role !== "CUSTOMER") redirect("/");

  const cart = await apiFetch<Cart>("/cart");
  if (cart.items.length === 0) redirect("/cart");

  return (
    <div className="grid grid-cols-1 gap-10 sm:grid-cols-[1fr_320px]">
      <div className="flex flex-col gap-6">
        <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Checkout</h1>
        <CheckoutForm />
      </div>

      <aside className="flex h-fit flex-col gap-3 border border-line bg-surface-raised p-4">
        <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Order summary</h2>
        <ul className="flex flex-col gap-2 text-sm">
          {cart.items.map((item) => (
            <li key={item.id} className="flex justify-between gap-2">
              <span className="text-steel">
                {item.spare_part.title} × {item.quantity}
              </span>
              <span className="font-mono text-asphalt">
                {formatTZS(Number(item.spare_part.price) * item.quantity)}
              </span>
            </li>
          ))}
        </ul>
        <div className="flex justify-between border-t border-line pt-3 text-sm font-semibold">
          <span className="uppercase tracking-wide text-steel">Total</span>
          <span className="font-mono text-asphalt">{formatTZS(cart.total)}</span>
        </div>
      </aside>
    </div>
  );
}
