"use client";

import dynamic from "next/dynamic";

import type { ServiceRequest } from "@/lib/types";

// Leaflet touches `window` at import time, so this must never render on
// the server — `ssr: false` is only usable from inside a Client Component
// boundary (this file), not the Server Component page that renders it.
// Matches web/src/components/admin/FleetMapClientOnly.tsx.
const ActiveTowMap = dynamic(() => import("./ActiveTowMap").then((m) => m.ActiveTowMap), {
  ssr: false,
  loading: () => (
    <div className="flex h-[32rem] w-full items-center justify-center border border-line bg-surface-raised text-sm text-steel-soft">
      Loading map…
    </div>
  ),
});

export function ActiveTowMapClientOnly(props: {
  initialJobs: ServiceRequest[];
  wsBaseUrl: string;
  accessToken: string;
}) {
  return <ActiveTowMap {...props} />;
}
