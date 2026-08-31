import { ActiveJobList } from "@/components/recovery/ActiveJobList";
import { ActiveTowMapClientOnly } from "@/components/recovery/ActiveTowMapClientOnly";
import { apiFetch } from "@/lib/api/server";
import { getAccessToken } from "@/lib/auth/session";
import type { ServiceRequest, ServiceRequestStatus } from "@/lib/types";

// Server-only default, matching web/src/app/track/[serviceRequestId]/page.tsx.
const WS_BASE_URL = process.env.NEXT_PUBLIC_WS_BASE_URL ?? "ws://localhost:8000";

const ACTIVE_STATUSES: ServiceRequestStatus[] = ["ACCEPTED", "EN_ROUTE", "IN_PROGRESS"];

export default async function RecoveryDispatchPage() {
  const [jobs, accessToken] = await Promise.all([
    // ServiceRequestListCreateView.get() already scopes RECOVERY to
    // Q(service_type=RECOVERY, status=PENDING) | Q(provider=user) — every
    // job this operator is/was assigned to (FR-009), client-side filtered
    // below to the active subset (research.md "Multi-tow dispatch view").
    apiFetch<ServiceRequest[]>("/service-requests"),
    getAccessToken(),
  ]);

  const activeJobs = jobs.filter((job) => ACTIVE_STATUSES.includes(job.status));

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Dispatch</h1>

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
