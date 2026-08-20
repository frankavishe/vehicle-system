import Link from "next/link";
import { redirect } from "next/navigation";

import { OrderStatusBadge } from "@/components/orders/OrderStatusBadge";
import { apiFetch } from "@/lib/api/server";
import { getSession } from "@/lib/auth/session";
import { formatDate, formatTZS } from "@/lib/format";
import type { Order } from "@/lib/types";

export default async function OrdersPage() {
  const user = await getSession();
  if (!user) redirect("/login?next=/orders");
  if (user.role !== "CUSTOMER") redirect("/");

  const orders = await apiFetch<Order[]>("/orders");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">My orders</h1>

      {orders.length === 0 ? (
        <div className="border border-dashed border-line bg-surface-raised p-10 text-center">
          <p className="text-sm text-steel">You haven&apos;t placed an order yet.</p>
          <Link href="/catalog" className="mt-3 inline-block text-sm font-semibold text-signal hover:text-signal-dark">
            Browse the catalog →
          </Link>
        </div>
      ) : (
        <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
          {orders.map((order) => (
            <Link
              key={order.id}
              href={`/orders/${order.id}`}
              className="flex flex-col gap-2 p-4 hover:bg-surface sm:flex-row sm:items-center sm:justify-between"
            >
              <div className="flex flex-col gap-0.5">
                <span className="font-mono text-sm text-asphalt">Order #{order.id.slice(0, 8)}</span>
                <span className="text-xs text-steel-soft">
                  {formatDate(order.created_at)} · {order.items.length} item{order.items.length === 1 ? "" : "s"}
                </span>
              </div>
              <div className="flex items-center gap-3">
                <span className="font-mono text-sm font-semibold text-asphalt">{formatTZS(order.total_amount)}</span>
                <OrderStatusBadge status={order.status} />
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
