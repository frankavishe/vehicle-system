import { Badge } from "@/components/ui/Badge";
import type { ServiceRequestStatus } from "@/lib/types";

const tones: Record<ServiceRequestStatus, "go" | "stop" | "signal" | "neutral"> = {
  PENDING: "neutral",
  ACCEPTED: "signal",
  EN_ROUTE: "signal",
  IN_PROGRESS: "signal",
  COMPLETED: "go",
  CANCELLED: "stop",
};

export function ServiceRequestStatusBadge({ status }: { status: ServiceRequestStatus }) {
  return <Badge tone={tones[status]}>{status.replace("_", " ")}</Badge>;
}
