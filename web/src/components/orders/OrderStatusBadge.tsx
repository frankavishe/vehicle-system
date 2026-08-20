import { Badge } from "@/components/ui/Badge";
import type { OrderStatus } from "@/lib/types";

const tones: Record<OrderStatus, "go" | "stop" | "signal" | "neutral"> = {
  PENDING: "neutral",
  PAID: "signal",
  DISPATCHED: "signal",
  DELIVERED: "go",
  CANCELLED: "stop",
};

export function OrderStatusBadge({ status }: { status: OrderStatus }) {
  return <Badge tone={tones[status]}>{status}</Badge>;
}
