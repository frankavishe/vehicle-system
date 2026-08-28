"use client";

import { useState } from "react";

import { Button } from "@/components/ui/Button";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import type { ServiceRequest, ServiceRequestStatus } from "@/lib/types";

// The forward-only slice of apps/dispatch/services/transitions.py's
// ALLOWED_TRANSITIONS + _ROLES_BY_TARGET that a MECHANIC drives from the
// portal (FR-005): ACCEPTED -> EN_ROUTE -> IN_PROGRESS -> COMPLETED.
// CANCELLED is a real allowed target too, but no acceptance scenario or
// FR asks the portal to offer it, so it's deliberately left out here.
const NEXT_STATUS: Partial<Record<ServiceRequestStatus, ServiceRequestStatus>> = {
  ACCEPTED: "EN_ROUTE",
  EN_ROUTE: "IN_PROGRESS",
  IN_PROGRESS: "COMPLETED",
};

const NEXT_LABEL: Partial<Record<ServiceRequestStatus, string>> = {
  ACCEPTED: "Mark en route",
  EN_ROUTE: "Start job",
  IN_PROGRESS: "Mark completed",
};

export function JobStatusControl({
  job,
  currentUserId,
  onUpdated,
}: {
  job: ServiceRequest;
  currentUserId: string;
  onUpdated: (job: ServiceRequest) => void;
}) {
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const isAssignedToMe = job.provider?.id === currentUserId;

  async function accept() {
    setSubmitting(true);
    setError(null);
    try {
      const updated = await apiFetch<ServiceRequest>(`/service-requests/${job.id}/accept`, {
        method: "POST",
      });
      onUpdated(updated);
    } catch (err) {
      setError(
        err instanceof ApiError
          ? err.status === 409
            ? "Someone else already accepted this job."
            : err.message
          : "Couldn't accept this job.",
      );
    } finally {
      setSubmitting(false);
    }
  }

  async function advance(target: ServiceRequestStatus) {
    setSubmitting(true);
    setError(null);
    try {
      const updated = await apiFetch<ServiceRequest>(`/service-requests/${job.id}/status`, {
        method: "PATCH",
        body: { status: target },
      });
      onUpdated(updated);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't update this job's status.");
    } finally {
      setSubmitting(false);
    }
  }

  const nextTarget = NEXT_STATUS[job.status];

  return (
    <div className="flex flex-col gap-2">
      <div className="flex gap-3">
        {job.status === "PENDING" && !job.provider && (
          <Button disabled={submitting} onClick={accept}>
            {submitting ? "Accepting…" : "Accept job"}
          </Button>
        )}
        {isAssignedToMe && nextTarget && (
          <Button disabled={submitting} onClick={() => advance(nextTarget)}>
            {submitting ? "Updating…" : NEXT_LABEL[job.status]}
          </Button>
        )}
      </div>
      {error && <p className="text-sm text-stop">{error}</p>}
    </div>
  );
}
