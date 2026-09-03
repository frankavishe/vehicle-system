"use client";

import dynamic from "next/dynamic";

import type { LatLng } from "@/lib/types";

// Leaflet touches `window` at import time, so this must never render on
// the server — same reasoning as TrackingMapClientOnly.tsx.
const LocationPickerMap = dynamic(
  () => import("./LocationPickerMap").then((m) => m.LocationPickerMap),
  {
    ssr: false,
    loading: () => (
      <div className="flex h-72 w-full items-center justify-center border border-line bg-surface-raised text-sm text-steel-soft">
        Loading map…
      </div>
    ),
  },
);

export function LocationPickerMapClientOnly(props: {
  center: LatLng;
  picked: LatLng | null;
  onPick: (point: LatLng) => void;
}) {
  return <LocationPickerMap {...props} />;
}
