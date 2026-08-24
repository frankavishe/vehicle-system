"use client";

import dynamic from "next/dynamic";

import type { ProviderMapEntry } from "@/lib/types";

const FleetMap = dynamic(() => import("./FleetMap").then((m) => m.FleetMap), {
  ssr: false,
  loading: () => (
    <div className="flex h-[32rem] w-full items-center justify-center border border-line bg-surface-raised text-sm text-steel-soft">
      Loading map…
    </div>
  ),
});

export function FleetMapClientOnly({ initialProviders }: { initialProviders: ProviderMapEntry[] }) {
  return <FleetMap initialProviders={initialProviders} />;
}
