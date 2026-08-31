"use client";

import "leaflet/dist/leaflet.css";

import { divIcon } from "leaflet";
import { useEffect, useState } from "react";
import { MapContainer, Marker, Popup, TileLayer } from "react-leaflet";

import { ServiceRequestStatusBadge } from "@/components/tracking/ServiceRequestStatusBadge";
import type { LatLng, ServiceRequest, ServiceRequestStatus } from "@/lib/types";

// Dar es Salaam — reasonable default center before any job has a known
// live position yet, matching web/src/components/admin/FleetMap.tsx.
const DEFAULT_CENTER: [number, number] = [-6.7924, 39.2083];

const ACTIVE_STATUSES: ServiceRequestStatus[] = ["ACCEPTED", "EN_ROUTE", "IN_PROGRESS"];

// A job's last-known position counts as stale once this long has passed
// without a location_update — generous headroom over the ~5s publish
// cadence (web/src/components/tracking/TrackingMap.tsx) for a couple of
// missed beats before flagging it, rather than on the very first miss.
const STALE_AFTER_MS = 30000;
const STALENESS_TICK_MS = 5000;

function markerIcon(stale: boolean) {
  return divIcon({
    className: "",
    html: `<span style="display:block;width:14px;height:14px;border-radius:9999px;background:var(${
      stale ? "--color-steel-soft" : "--color-hazard"
    });border:2px solid white;box-shadow:0 0 0 1px rgba(0,0,0,0.25)"></span>`,
    iconSize: [14, 14],
    iconAnchor: [7, 7],
  });
}

interface JobPosition {
  lat: number;
  lng: number;
  updatedAt: number;
}

/** Multi-marker Leaflet map for every currently-active tow (Story 1). Each
 * job gets its own `ws://.../tracking/{id}/` connection — the same
 * connection web/src/app/track/[serviceRequestId] opens for a single job,
 * opened once per job here (research.md "Live position" decision) — and
 * is self-contained (own sockets, own state), matching this codebase's
 * existing pattern of not sharing a connection across components (see
 * web/src/components/tracking/TrackingMap.tsx). */
export function ActiveTowMap({
  initialJobs,
  wsBaseUrl,
  accessToken,
}: {
  initialJobs: ServiceRequest[];
  wsBaseUrl: string;
  accessToken: string;
}) {
  const [jobs, setJobs] = useState(initialJobs);
  const [positions, setPositions] = useState<Record<string, JobPosition>>({});
  // Read once per render from state (not called inline during render,
  // which React's purity rule disallows) and refreshed on a fixed cadence
  // below so a marker's staleness keeps advancing even when no new socket
  // event arrives — nothing else would trigger that redraw.
  const [now, setNow] = useState(() => Date.now());

  useEffect(() => {
    const interval = setInterval(() => setNow(Date.now()), STALENESS_TICK_MS);
    return () => clearInterval(interval);
  }, []);

  const jobIds = jobs
    .map((j) => j.id)
    .sort()
    .join(",");

  useEffect(() => {
    const sockets = jobs.map((job) => {
      const socket = new WebSocket(`${wsBaseUrl}/ws/api/v1/tracking/${job.id}/?token=${accessToken}`);
      socket.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data) as LatLng &
            Partial<{ event: string; status: ServiceRequestStatus }>;
          if (data.event === "status_update" && data.status) {
            if (ACTIVE_STATUSES.includes(data.status)) {
              setJobs((prev) => prev.map((j) => (j.id === job.id ? { ...j, status: data.status! } : j)));
            } else {
              // Completed/cancelled — drop off the active view (FR-004).
              // This job's own socket closes via this effect's cleanup
              // once `jobIds` changes and the effect reruns.
              setJobs((prev) => prev.filter((j) => j.id !== job.id));
            }
          } else if (typeof data.lat === "number" && typeof data.lng === "number") {
            setPositions((prev) => ({
              ...prev,
              [job.id]: { lat: data.lat, lng: data.lng, updatedAt: Date.now() },
            }));
          }
        } catch {
          // Ignore malformed frames rather than crashing the map.
        }
      };
      return socket;
    });

    return () => {
      for (const socket of sockets) socket.close();
    };
    // Reopen sockets only when the active job *id set* changes, not on
    // every status/field update to an already-tracked job.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [jobIds, wsBaseUrl, accessToken]);

  const withPosition = jobs.filter((job) => positions[job.id]);
  const center = withPosition[0]
    ? ([positions[withPosition[0].id].lat, positions[withPosition[0].id].lng] as [number, number])
    : DEFAULT_CENTER;

  return (
    <div className="h-[32rem] w-full overflow-hidden border border-line">
      <MapContainer center={center} zoom={12} className="h-full w-full">
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        {withPosition.map((job) => {
          const pos = positions[job.id];
          const stale = now - pos.updatedAt > STALE_AFTER_MS;
          // Each job renders as its own Marker keyed by job id, with a
          // popup identifying which job it is — two overlapping routes
          // still resolve to individually selectable, identifiable
          // markers rather than merging into one (SC-005 edge case).
          return (
            <Marker key={job.id} position={[pos.lat, pos.lng]} icon={markerIcon(stale)}>
              <Popup>
                <div className="flex flex-col gap-1">
                  <span className="font-semibold">{job.customer.full_name}</span>
                  <ServiceRequestStatusBadge status={job.status} />
                  {stale && <span className="text-xs text-stop">Position may be out of date</span>}
                </div>
              </Popup>
            </Marker>
          );
        })}
      </MapContainer>
    </div>
  );
}
