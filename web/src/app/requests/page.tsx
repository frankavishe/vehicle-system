import Link from "next/link";
import { redirect } from "next/navigation";

import { ServiceRequestStatusBadge } from "@/components/tracking/ServiceRequestStatusBadge";
import { apiFetch } from "@/lib/api/server";
import { getSession } from "@/lib/auth/session";
import { formatDate } from "@/lib/format";
import type { ServiceRequest } from "@/lib/types";

export default async function RequestsPage() {
  const user = await getSession();
  if (!user) redirect("/login?next=/requests");
  if (user.role !== "CUSTOMER") redirect("/");

  // GET /service-requests is auto-scoped to the caller's own requests for
  // the CUSTOMER role (apps/dispatch/views.py's ServiceRequestListCreateView.get).
  const requests = await apiFetch<ServiceRequest[]>("/service-requests");

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between gap-4">
        <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">
          My service requests
        </h1>
        <Link
          href="/requests/new"
          className="bg-hazard px-3 py-2 text-sm font-semibold uppercase tracking-wide text-white hover:bg-hazard-dark"
        >
          Request service
        </Link>
      </div>

      {requests.length === 0 ? (
        <div className="border border-dashed border-line bg-surface-raised p-10 text-center">
          <p className="text-sm text-steel">You haven&apos;t requested a mechanic or tow yet.</p>
          <Link href="/requests/new" className="mt-3 inline-block text-sm font-semibold text-signal hover:text-signal-dark">
            Request one now →
          </Link>
        </div>
      ) : (
        <div className="flex flex-col divide-y divide-line border border-line bg-surface-raised">
          {requests.map((request) => (
            <Link
              key={request.id}
              href={`/track/${request.id}`}
              className="flex flex-col gap-2 p-4 hover:bg-surface sm:flex-row sm:items-center sm:justify-between"
            >
              <div className="flex flex-col gap-0.5">
                <span className="font-mono text-sm text-asphalt">
                  {request.service_type === "RECOVERY" ? "Towing" : "Mechanic"} · #{request.id.slice(0, 8)}
                </span>
                <span className="text-xs text-steel-soft">{formatDate(request.created_at)}</span>
              </div>
              <ServiceRequestStatusBadge status={request.status} />
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
