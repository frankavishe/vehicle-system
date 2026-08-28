"use client";

import { useState } from "react";

import { JobStatusControl } from "@/components/mechanic/JobStatusControl";
import { PartsSourcingRequestForm } from "@/components/mechanic/PartsSourcingRequestForm";
import { ServiceRequestStatusBadge } from "@/components/tracking/ServiceRequestStatusBadge";
import { formatDate } from "@/lib/format";
import type { ServiceRequest } from "@/lib/types";

/** Holds the mutable job state across accept/status updates — a Server
 * Component page can't hold state, so this thin client wrapper is what
 * `page.tsx` renders. */
export function JobDetailClient({
  initialJob,
  currentUserId,
}: {
  initialJob: ServiceRequest;
  currentUserId: string;
}) {
  const [job, setJob] = useState(initialJob);
  const isAssignedToMe = job.provider?.id === currentUserId;

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
          <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Problem</h2>
          <p className="text-sm text-steel">{job.problem_description ?? "No description provided"}</p>
        </div>
        <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
          <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Customer</h2>
          <p className="text-sm text-steel">{job.customer.full_name} · {job.customer.phone}</p>
        </div>
        <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
          <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Pickup</h2>
          <p className="text-sm text-steel">
            {job.pickup_location.lat.toFixed(5)}, {job.pickup_location.lng.toFixed(5)}
          </p>
        </div>
        <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
          <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Fare</h2>
          <p className="text-sm text-steel">
            {job.final_fare ?? job.estimated_fare ?? "Not yet estimated"}
          </p>
        </div>
      </div>

      <JobStatusControl job={job} currentUserId={currentUserId} onUpdated={setJob} />

      {isAssignedToMe && (
        <PartsSourcingRequestForm serviceRequestId={job.id} jobStatus={job.status} />
      )}
    </div>
  );
}
