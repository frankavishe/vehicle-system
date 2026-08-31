import { formatTZS } from "@/lib/format";
import type { ServiceRequest } from "@/lib/types";

/** Fare estimate before commitment (Story 2). Reads `estimated_fare`/
 * `final_fare` straight off the `ServiceRequest` object exactly as
 * `ServiceRequestSerializer` returns them — no client-side recomputation
 * (Constitution Principle V) — showing the estimate alone while `PENDING`
 * (FR-005), or both together once `COMPLETED` (FR-006). */
export function FareEstimateCard({ job }: { job: ServiceRequest }) {
  const isCompleted = job.status === "COMPLETED";

  return (
    <div className="flex flex-col gap-3 border border-line bg-surface-raised p-4">
      <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Fare</h2>
      <div className="flex flex-wrap items-baseline gap-x-6 gap-y-2">
        <div className="flex flex-col gap-0.5">
          <span className="text-xs text-steel-soft">Estimated</span>
          <span className="font-display text-2xl font-bold text-asphalt">
            {job.estimated_fare != null ? formatTZS(job.estimated_fare) : "Not yet estimated"}
          </span>
        </div>
        {isCompleted && (
          <div className="flex flex-col gap-0.5">
            <span className="text-xs text-steel-soft">Final</span>
            <span className="font-display text-2xl font-bold text-go">
              {job.final_fare != null ? formatTZS(job.final_fare) : "—"}
            </span>
          </div>
        )}
      </div>
    </div>
  );
}
