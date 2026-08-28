import { notFound } from "next/navigation";

import { Badge } from "@/components/ui/Badge";
import { ApiError } from "@/lib/api/errors";
import { apiFetch } from "@/lib/api/server";
import { formatDate, formatTZS } from "@/lib/format";
import type { PartsSourcingRequest, Payout, ServiceRequest } from "@/lib/types";

export default async function MechanicJobHistoryDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  let job: ServiceRequest;
  try {
    job = await apiFetch<ServiceRequest>(`/service-requests/${id}`);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  const [partsRequests, payoutsPage] = await Promise.all([
    apiFetch<PartsSourcingRequest[]>(`/service-requests/${id}/parts-requests`),
    // First page only (PAGE_SIZE=20) — matches how the rest of this app
    // (e.g. web/src/app/admin/payouts) reads a paginated list without
    // extra handling; fine for finding a recent job's own payout.
    apiFetch<{ results: Payout[] }>("/providers/me/payouts"),
  ]);

  const payoutItem = payoutsPage.results
    .flatMap((payout) => payout.items.map((item) => ({ item, payout })))
    .find(({ item }) => item.service_request === job.id);

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Job detail</h1>
      <span className="text-sm text-steel-soft">Completed {formatDate(job.created_at)}</span>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <div className="flex flex-col gap-1 border border-line bg-surface-raised p-4">
          <span className="text-xs font-semibold uppercase tracking-wide text-steel">Fare</span>
          <span className="font-mono text-lg text-asphalt">
            {job.final_fare ? formatTZS(job.final_fare) : "—"}
          </span>
        </div>
        <div className="flex flex-col gap-1 border border-line bg-surface-raised p-4">
          <span className="text-xs font-semibold uppercase tracking-wide text-steel">Payout status</span>
          {payoutItem ? (
            <Badge tone={payoutItem.payout.status === "PAID" ? "go" : "signal"}>
              {payoutItem.payout.status}
            </Badge>
          ) : (
            <span className="text-sm text-steel-soft">Not yet paid out</span>
          )}
        </div>
        <div className="flex flex-col gap-1 border border-line bg-surface-raised p-4">
          <span className="text-xs font-semibold uppercase tracking-wide text-steel">Payout amount</span>
          <span className="font-mono text-lg text-asphalt">
            {payoutItem ? formatTZS(payoutItem.item.amount) : "—"}
          </span>
        </div>
      </div>

      <div className="flex flex-col gap-3">
        <h2 className="font-display text-xl font-bold uppercase tracking-tight text-asphalt">
          Parts-sourcing requests
        </h2>
        <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
          {partsRequests.length === 0 && (
            <p className="p-4 text-sm text-steel-soft">No parts were requested for this job.</p>
          )}
          {partsRequests.map((request) => (
            <div key={request.id} className="flex items-center justify-between gap-4 p-4">
              <span className="text-sm text-steel">Qty {request.quantity}</span>
              <Badge tone={request.status === "ORDERED" ? "go" : request.status === "REJECTED" ? "stop" : "neutral"}>
                {request.status}
              </Badge>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
