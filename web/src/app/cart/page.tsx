import { redirect } from "next/navigation";

import { CartTable } from "@/components/cart/CartTable";
import { apiFetch } from "@/lib/api/server";
import { getSession } from "@/lib/auth/session";
import type { Cart } from "@/lib/types";

export default async function CartPage() {
  const user = await getSession();
  if (!user) redirect("/login?next=/cart");
  if (user.role !== "CUSTOMER") redirect("/");

  const cart = await apiFetch<Cart>("/cart");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Your cart</h1>
      <CartTable initialCart={cart} />
    </div>
  );
}
