import { ActiveJobList } from "@/components/recovery/ActiveJobList";
import { ActiveTowMapClientOnly } from "@/components/recovery/ActiveTowMapClientOnly";
// Both generic (PATCH /providers/me/availability, accept/decline against
// /service-requests/{id}/accept — no mechanic-specific logic) — already
// reused the same way by recovery/jobs/[id]/JobDetailClient.tsx's
// JobStatusControl import.
import { AvailabilityToggle } from "@/components/mechanic/AvailabilityToggle";
import { JobQueueList } from "@/components/mechanic/JobQueueList";
import { apiFetch } from "@/lib/api/server";
import { getAccessToken } from "@/lib/auth/session";
import type { ServiceRequest, ServiceRequestStatus } from "@/lib/types";

// Server-only default, matching web/src/app/track/[serviceRequestId]/page.tsx.
const WS_BASE_URL = process.env.NEXT_PUBLIC_WS_BASE_URL ?? "ws://localhost:8000";

const ACTIVE_STATUSES: ServiceRequestStatus[] = ["ACCEPTED", "EN_ROUTE", "IN_PROGRESS"];

export default async function RecoveryDispatchPage() {
  const [jobs, accessToken, availability] = await Promise.all([
    // ServiceRequestListCreateView.get() already scopes RECOVERY to
    // Q(service_type=RECOVERY, status=PENDING) | Q(provider=user) — every
    // job this operator is/was assigned to (FR-009), client-side filtered
    // below to the active subset (research.md "Multi-tow dispatch view").
    apiFetch<ServiceRequest[]>("/service-requests"),
    getAccessToken(),
    // The accept endpoint 409s an unavailable provider — the mechanic
    // dashboard already surfaces this same toggle; recovery never did.
    apiFetch<{ is_available: boolean }>("/providers/me/availability"),
  ]);

  const activeJobs = jobs.filter((job) => ACTIVE_STATUSES.includes(job.status));
  // The same GET already includes PENDING RECOVERY-type requests
  // (ServiceRequestListCreateView.get's Q(service_type=RECOVERY,
  // status=PENDING) | Q(provider=user)) — just never surfaced anywhere
  // in this portal before now.
  const pendingJobs = jobs.filter((job) => job.status === "PENDING" && !job.provider);

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Dispatch</h1>

      <AvailabilityToggle initialIsAvailable={availability.is_available} />

      <JobQueueList initialJobs={pendingJobs} jobHrefBase="/recovery/jobs" />

      {!accessToken ? (
        <p className="text-sm text-stop">Your session expired — please log in again to see live tracking.</p>
      ) : (
        <>
          <ActiveTowMapClientOnly initialJobs={activeJobs} wsBaseUrl={WS_BASE_URL} accessToken={accessToken} />
          <ActiveJobList initialJobs={activeJobs} wsBaseUrl={WS_BASE_URL} accessToken={accessToken} />
        </>
      )}
    </div>
  );
}
