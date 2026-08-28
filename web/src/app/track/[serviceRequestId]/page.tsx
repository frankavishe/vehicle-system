import { notFound, redirect } from "next/navigation";

import { ServiceRequestStatusBadge } from "@/components/tracking/ServiceRequestStatusBadge";
import { TrackingMapClientOnly } from "@/components/tracking/TrackingMapClientOnly";
import { ApiError } from "@/lib/api/errors";
import { apiFetch } from "@/lib/api/server";
import { getAccessToken, getSession } from "@/lib/auth/session";
import { formatDate } from "@/lib/format";
import type { ServiceRequest } from "@/lib/types";

// Server-only (never sent to the browser as a public var, unlike
// NEXT_PUBLIC_WS_BASE_URL) — this default matches web/.env.example so
// local dev works with zero setup.
const WS_BASE_URL = process.env.NEXT_PUBLIC_WS_BASE_URL ?? "ws://localhost:8000";

export default async function TrackServiceRequestPage({
  params,
}: {
  params: Promise<{ serviceRequestId: string }>;
}) {
  const user = await getSession();
  if (!user) redirect("/login");

  const { serviceRequestId } = await params;

  let serviceRequest: ServiceRequest;
  try {
    serviceRequest = await apiFetch<ServiceRequest>(`/service-requests/${serviceRequestId}`);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  const accessToken = await getAccessToken();
  const isProvider = serviceRequest.provider?.id === user.id;

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-start justify-between gap-4">
        <div className="flex flex-col gap-1">
          <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">
            {serviceRequest.service_type === "RECOVERY" ? "Recovery tracking" : "Mechanic tracking"}
          </h1>
          <span className="text-sm text-steel-soft">Requested {formatDate(serviceRequest.created_at)}</span>
        </div>
        {/* Once TrackingMapClientOnly mounts below, it renders the live,
            WebSocket-updated status badge itself (contracts/websocket.md)
            — showing this static one too would just be a second,
            never-updating badge next to it. */}
        {(!serviceRequest.provider || !accessToken) && (
          <ServiceRequestStatusBadge status={serviceRequest.status} />
        )}
      </div>

      {!serviceRequest.provider ? (
        <p className="border border-line bg-surface-raised p-4 text-sm text-steel">
          Still waiting for a provider to accept this request — the map appears once one does.
        </p>
      ) : !accessToken ? (
        <p className="text-sm text-stop">Your session expired — please log in again to track live.</p>
      ) : (
        <TrackingMapClientOnly
          serviceRequestId={serviceRequest.id}
          wsBaseUrl={WS_BASE_URL}
          accessToken={accessToken}
          pickup={serviceRequest.pickup_location}
          dropoff={serviceRequest.dropoff_location}
          isProvider={isProvider}
          initialStatus={serviceRequest.status}
        />
      )}

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
          <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Customer</h2>
          <p className="text-sm text-steel">{serviceRequest.customer.full_name}</p>
        </div>
        <div className="flex flex-col gap-2 border border-line bg-surface-raised p-4">
          <h2 className="text-xs font-semibold uppercase tracking-wide text-steel">Provider</h2>
          <p className="text-sm text-steel">{serviceRequest.provider?.full_name ?? "Not yet assigned"}</p>
        </div>
      </div>
    </div>
  );
}
