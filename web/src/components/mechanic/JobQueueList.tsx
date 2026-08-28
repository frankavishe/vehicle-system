"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { ServiceRequestStatusBadge } from "@/components/tracking/ServiceRequestStatusBadge";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import type { ServiceRequest } from "@/lib/types";

// Matches the cadence already established for the tracking map's own
// polling loop (web/src/components/tracking/TrackingMap.tsx) — there's
// no push channel for "a new job just matched you" on the web portal
// (the mobile app instead gets an FCM push from
// apps.dispatch.tasks.fan_out_job_alert), so a plain poll is how new
// offers and other mechanics' accepts surface here.
const QUEUE_POLL_INTERVAL_MS = 10000;

export function JobQueueList({ initialJobs }: { initialJobs: ServiceRequest[] }) {
  const [jobs, setJobs] = useState(initialJobs);
  const [declinedIds, setDeclinedIds] = useState<Set<string>>(new Set());
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function poll() {
      try {
        const fresh = await apiFetch<ServiceRequest[]>("/service-requests");
        if (!cancelled) {
          setJobs(fresh);
          setError(null);
        }
      } catch (err) {
        if (!cancelled) setError(err instanceof ApiError ? err.message : "Couldn't refresh jobs.");
      }
    }

    const interval = setInterval(poll, QUEUE_POLL_INTERVAL_MS);
    return () => {
      cancelled = true;
      clearInterval(interval);
    };
  }, []);

  // A decline is a client-side dismissal for this session only — no
  // backend call exists for it. The job stays PENDING and keeps being
  // offered to every other matching mechanic; it reappears here on a
  // hard refresh, which is the intended behavior (see
  // specs/001-mechanic-web-portal/research.md "Declining a job").
  function decline(id: string) {
    setDeclinedIds((prev) => new Set(prev).add(id));
  }

  const visibleJobs = jobs.filter((job) => !declinedIds.has(job.id));

  return (
    <div className="flex flex-col gap-3">
      <h2 className="font-display text-xl font-bold uppercase tracking-tight text-asphalt">Job queue</h2>
      {error && <p className="text-sm text-stop">{error}</p>}
      <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
        {visibleJobs.length === 0 && (
          <p className="p-4 text-sm text-steel-soft">No jobs waiting right now — check back once you&apos;re online.</p>
        )}
        {visibleJobs.map((job) => (
          <JobQueueRow key={job.id} job={job} onAccepted={setJobs} onDecline={() => decline(job.id)} />
        ))}
      </div>
    </div>
  );
}

function JobQueueRow({
  job,
  onAccepted,
  onDecline,
}: {
  job: ServiceRequest;
  onAccepted: (updater: (jobs: ServiceRequest[]) => ServiceRequest[]) => void;
  onDecline: () => void;
}) {
  const [accepting, setAccepting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function accept() {
    setAccepting(true);
    setError(null);
    try {
      const updated = await apiFetch<ServiceRequest>(`/service-requests/${job.id}/accept`, {
        method: "POST",
      });
      onAccepted((jobs) => jobs.map((j) => (j.id === updated.id ? updated : j)));
    } catch (err) {
      // 409 means someone else already accepted it — surface that
      // clearly rather than as a generic failure (edge case: "the
      // portal MUST show the job as no longer available").
      setError(
        err instanceof ApiError
          ? err.status === 409
            ? "Someone else already accepted this job."
            : err.message
          : "Couldn't accept this job.",
      );
    } finally {
      setAccepting(false);
    }
  }

  return (
    <div className="flex items-center justify-between gap-4 p-4">
      <Link href={`/mechanic/jobs/${job.id}`} className="flex flex-col gap-0.5 hover:opacity-80">
        <span className="text-sm font-semibold text-asphalt">
          {job.problem_description ?? "No description provided"}
        </span>
        <span className="text-xs text-steel-soft">
          Pickup: {job.pickup_location.lat.toFixed(4)}, {job.pickup_location.lng.toFixed(4)}
        </span>
      </Link>
      <div className="flex items-center gap-3">
        <ServiceRequestStatusBadge status={job.status} />
        {job.status === "PENDING" && !job.provider && (
          <>
            <Button variant="ghost" onClick={onDecline}>
              Decline
            </Button>
            <Button disabled={accepting} onClick={accept}>
              {accepting ? "Accepting…" : "Accept"}
            </Button>
          </>
        )}
        {error && <Badge tone="stop">{error}</Badge>}
      </div>
    </div>
  );
}
