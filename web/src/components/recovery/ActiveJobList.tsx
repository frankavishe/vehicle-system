"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import { ServiceRequestStatusBadge } from "@/components/tracking/ServiceRequestStatusBadge";
import type { ServiceRequest, ServiceRequestStatus } from "@/lib/types";

const ACTIVE_STATUSES: ServiceRequestStatus[] = ["ACCEPTED", "EN_ROUTE", "IN_PROGRESS"];

/** List of every currently-active tow, kept in sync with the same job set
 * rendered on ActiveTowMap.tsx (Story 1) — self-contained (opens its own
 * per-job `status_update` sockets rather than sharing ActiveTowMap.tsx's),
 * matching this codebase's existing pattern of independent, self-managing
 * live components (see web/src/components/tracking/TrackingMap.tsx). */
export function ActiveJobList({
  initialJobs,
  wsBaseUrl,
  accessToken,
}: {
  initialJobs: ServiceRequest[];
  wsBaseUrl: string;
  accessToken: string;
}) {
  const [jobs, setJobs] = useState(initialJobs);

  const jobIds = jobs
    .map((j) => j.id)
    .sort()
    .join(",");

  useEffect(() => {
    const sockets = jobs.map((job) => {
      const socket = new WebSocket(`${wsBaseUrl}/ws/api/v1/tracking/${job.id}/?token=${accessToken}`);
      socket.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data) as Partial<{ event: string; status: ServiceRequestStatus }>;
          if (data.event === "status_update" && data.status) {
            if (ACTIVE_STATUSES.includes(data.status)) {
              setJobs((prev) => prev.map((j) => (j.id === job.id ? { ...j, status: data.status! } : j)));
            } else {
              // Completed/cancelled — drop off the active view (FR-004),
              // remains reachable via GET /service-requests?status=... .
              setJobs((prev) => prev.filter((j) => j.id !== job.id));
            }
          }
        } catch {
          // Ignore malformed frames rather than crashing the list.
        }
      };
      return socket;
    });

    return () => {
      for (const socket of sockets) socket.close();
    };
    // Reopen sockets only when the active job *id set* changes, not on
    // every status/field update to an already-tracked job — mirrors
    // ActiveTowMap.tsx's identical pattern.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [jobIds, wsBaseUrl, accessToken]);

  return (
    <div className="flex flex-col gap-3">
      <h2 className="font-display text-xl font-bold uppercase tracking-tight text-asphalt">Active tows</h2>
      <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
        {jobs.length === 0 && (
          <p className="p-4 text-sm text-steel-soft">No active tows right now.</p>
        )}
        {jobs.map((job) => (
          <Link
            key={job.id}
            href={`/recovery/jobs/${job.id}`}
            className="flex items-center justify-between gap-4 p-4 hover:bg-line/20"
          >
            <div className="flex flex-col gap-0.5">
              <span className="text-sm font-semibold text-asphalt">{job.customer.full_name}</span>
              <span className="text-xs text-steel-soft">
                Pickup: {job.pickup_location.lat.toFixed(4)}, {job.pickup_location.lng.toFixed(4)}
              </span>
            </div>
            <ServiceRequestStatusBadge status={job.status} />
          </Link>
        ))}
      </div>
    </div>
  );
}
