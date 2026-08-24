"use client";

import dynamic from "next/dynamic";

import type { LatLng } from "@/lib/types";

// Leaflet touches `window` at import time, so this must never render on
// the server — `ssr: false` is only usable from inside a Client
// Component boundary (this file), not from the Server Component page
// that renders it.
const TrackingMap = dynamic(() => import("./TrackingMap").then((m) => m.TrackingMap), {
  ssr: false,
  loading: () => (
    <div className="flex h-96 w-full items-center justify-center border border-line bg-surface-raised text-sm text-steel-soft">
      Loading map…
    </div>
  ),
});

export function TrackingMapClientOnly(props: {
  serviceRequestId: string;
  wsBaseUrl: string;
  accessToken: string;
  pickup: LatLng;
  dropoff: LatLng | null;
  isProvider: boolean;
}) {
  return <TrackingMap {...props} />;
}
