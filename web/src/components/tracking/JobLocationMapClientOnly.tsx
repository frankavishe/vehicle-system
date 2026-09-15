"use client";

import dynamic from "next/dynamic";

import type { LatLng } from "@/lib/types";

// Leaflet touches `window` at import time, so this must never render on
// the server — `ssr: false` is only usable from inside a Client
// Component boundary (this file), not from the Server Component page
// that renders it. Matches TrackingMapClientOnly.tsx.
const JobLocationMap = dynamic(() => import("./JobLocationMap").then((m) => m.JobLocationMap), {
  ssr: false,
  loading: () => (
    <div className="flex h-72 w-full items-center justify-center rounded-2xl border border-line bg-surface-raised text-sm text-steel-soft shadow-sm">
      Loading map…
    </div>
  ),
});

export function JobLocationMapClientOnly(props: { pickup: LatLng; dropoff: LatLng | null }) {
  return <JobLocationMap {...props} />;
}
