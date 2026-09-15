"use client";

import { useState } from "react";

import { JobQueueList } from "@/components/mechanic/JobQueueList";
import type { ServiceRequest } from "@/lib/types";

import { ActiveJobList } from "./ActiveJobList";
import { ActiveTowMapClientOnly } from "./ActiveTowMapClientOnly";

/** Owns the one piece of state ActiveTowMapClientOnly and JobQueueList
 * (recovery/page.tsx's two independent children) need to share: which job
 * was last clicked. Clicking a row in the Job queue below focuses that job
 * directly on the map instead of navigating to its detail page — the
 * feature this component exists for. */
export function RecoveryDispatchBoard({
  pendingJobs,
  activeJobs,
  wsBaseUrl,
  accessToken,
}: {
  pendingJobs: ServiceRequest[];
  activeJobs: ServiceRequest[];
  wsBaseUrl: string;
  accessToken: string | null;
}) {
  const [selectedJobId, setSelectedJobId] = useState<string | null>(null);

  return (
    <>
      <JobQueueList
        initialJobs={pendingJobs}
        jobHrefBase="/recovery/jobs"
        selectedJobId={selectedJobId}
        onSelectJob={(job) => setSelectedJobId(job.id)}
      />

      {!accessToken ? (
        <p className="text-sm text-stop">Your session expired — please log in again to see live tracking.</p>
      ) : (
        <>
          <ActiveTowMapClientOnly
            initialJobs={activeJobs}
            pendingJobs={pendingJobs}
            wsBaseUrl={wsBaseUrl}
            accessToken={accessToken}
            selectedJobId={selectedJobId}
          />
          <ActiveJobList initialJobs={activeJobs} wsBaseUrl={wsBaseUrl} accessToken={accessToken} />
        </>
      )}
    </>
  );
}
