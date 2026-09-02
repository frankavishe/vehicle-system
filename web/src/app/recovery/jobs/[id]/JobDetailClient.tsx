"use client";

import { useState } from "react";

import { FareEstimateCard } from "@/components/recovery/FareEstimateCard";
import { JobStatusControl } from "@/components/mechanic/JobStatusControl";
import { ServiceRequestStatusBadge } from "@/components/tracking/ServiceRequestStatusBadge";
import { formatDate } from "@/lib/format";
import type { ServiceRequest } from "@/lib/types";

/** Mirrors web/src/app/mechanic/jobs/[id]/JobDetailClient.tsx — same
 * generic JobStatusControl (accept -> EN_ROUTE -> IN_PROGRESS ->
 * COMPLETED against /service-requests/{id}/accept|status, IsProvider on
 * the backend so it isn't mechanic-specific) wired in here too. Recovery
 * previously rendered FareEstimateCard alone with no way to actually
 * accept a job from the web portal. */
export function JobDetailClient({
  initialJob,
  currentUserId,
}: {
  initialJob: ServiceRequest;
  currentUserId: string;
}) {
  const [job, setJob] = useState(initialJob);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-start justify-between gap-4">
        <div className="flex flex-col gap-1">
          <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Job detail</h1>
          <span className="text-sm text-steel-soft">Requested {formatDate(job.created_at)}</span>
        </div>
        <ServiceRequestStatusBadge status={job.status} />
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
          <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Customer</h2>
          <p className="text-sm text-steel">
            {job.customer.full_name} · {job.customer.phone}
          </p>
        </div>
        <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
          <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Pickup</h2>
          <p className="text-sm text-steel">
            {job.pickup_location.lat.toFixed(5)}, {job.pickup_location.lng.toFixed(5)}
          </p>
        </div>
        <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
          <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Dropoff</h2>
          <p className="text-sm text-steel">
            {job.dropoff_location
              ? `${job.dropoff_location.lat.toFixed(5)}, ${job.dropoff_location.lng.toFixed(5)}`
              : "Not set"}
          </p>
        </div>
        <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
          <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Problem</h2>
          <p className="text-sm text-steel">{job.problem_description ?? "No description provided"}</p>
        </div>
      </div>

      <FareEstimateCard job={job} />

      <JobStatusControl job={job} currentUserId={currentUserId} onUpdated={setJob} />
    </div>
  );
}
