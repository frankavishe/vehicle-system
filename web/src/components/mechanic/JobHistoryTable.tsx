import Link from "next/link";

import { formatDate, formatTZS } from "@/lib/format";
import type { ServiceRequest } from "@/lib/types";

export function JobHistoryTable({ jobs }: { jobs: ServiceRequest[] }) {
  if (jobs.length === 0) {
    return (
      <p className="rounded-2xl border border-line bg-surface-raised p-4 text-sm text-steel-soft shadow-sm">
        No completed jobs yet.
      </p>
    );
  }

  return (
    <div className="flex flex-col divide-y divide-line rounded-2xl border border-line bg-surface-raised shadow-sm">
      {jobs.map((job) => (
        <Link
          key={job.id}
          href={`/mechanic/history/${job.id}`}
          className="flex items-center justify-between gap-4 p-4 first:rounded-t-2xl last:rounded-b-2xl hover:bg-surface"
        >
          <div className="flex flex-col gap-0.5">
            <span className="text-xs text-steel-soft">
              {job.id.slice(0, 8)} · {formatDate(job.created_at)}
            </span>
            <span className="text-sm text-steel">{job.problem_description ?? "No description provided"}</span>
          </div>
          <span className="text-sm text-asphalt">{job.final_fare ? formatTZS(job.final_fare) : "—"}</span>
        </Link>
      ))}
    </div>
  );
}
