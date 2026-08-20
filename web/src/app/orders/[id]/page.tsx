import { notFound, redirect } from "next/navigation";

import { CancelOrderButton } from "@/components/orders/CancelOrderButton";
import { OrderStatusBadge } from "@/components/orders/OrderStatusBadge";
import { apiFetch } from "@/lib/api/server";
import { ApiError } from "@/lib/api/errors";
import { getSession } from "@/lib/auth/session";
import { formatDate, formatTZS } from "@/lib/format";
import type { Order, OrderShipment } from "@/lib/types";

async function getShipment(orderId: string): Promise<OrderShipment | null> {
  try {
    return await apiFetch<OrderShipment>(`/orders/${orderId}/shipment`);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) return null;
    throw err;
  }
}

export default async function OrderDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const user = await getSession();
  if (!user) redirect("/login");

  const { id } = await params;

  let order: Order;
  try {
    order = await apiFetch<Order>(`/orders/${id}`);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  const shipment = await getShipment(id);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-start justify-between gap-4">
        <div className="flex flex-col gap-1">
          <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">
            Order #{order.id.slice(0, 8)}
          </h1>
          <span className="text-sm text-steel-soft">Placed {formatDate(order.created_at)}</span>
        </div>
        <OrderStatusBadge status={order.status} />
      </div>

      <div className="grid grid-cols-1 gap-6 sm:grid-cols-[1fr_280px]">
        <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
          {order.items.map((item) => (
            <div key={item.id} className="flex items-center justify-between p-4">
              <div className="flex flex-col gap-0.5">
                <span className="text-sm font-semibold text-asphalt">{item.spare_part.title}</span>
                <span className="font-mono text-xs text-steel-soft">
                  {formatTZS(item.unit_price)} × {item.quantity}
                </span>
              </div>
              <span className="font-mono text-sm text-asphalt">
                {formatTZS(Number(item.unit_price) * item.quantity)}
              </span>
            </div>
          ))}
          <div className="flex items-center justify-between p-4">
            <span className="text-sm font-semibold uppercase tracking-wide text-steel">Total</span>
            <span className="font-mono text-lg font-semibold text-asphalt">{formatTZS(order.total_amount)}</span>
          </div>
        </div>

        <aside className="flex flex-col gap-4">
          <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
            <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Delivery address</h2>
            <p className="text-sm text-steel">{order.delivery_address}</p>
          </div>

          {shipment && (
            <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
              <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Shipment</h2>
              {shipment.courier_name && <p className="text-sm text-steel">Courier: {shipment.courier_name}</p>}
              {shipment.tracking_ref && (
                <p className="font-mono text-xs text-steel-soft">Tracking ref {shipment.tracking_ref}</p>
              )}
              {shipment.dispatched_at && (
                <p className="text-xs text-steel-soft">Dispatched {formatDate(shipment.dispatched_at)}</p>
              )}
              {shipment.delivered_at && (
                <p className="text-xs text-steel-soft">Delivered {formatDate(shipment.delivered_at)}</p>
              )}
            </div>
          )}

          {order.status === "PENDING" && <CancelOrderButton orderId={order.id} />}
        </aside>
      </div>
    </div>
  );
}
