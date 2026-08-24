import { FleetMapClientOnly } from "@/components/admin/FleetMapClientOnly";
import { apiFetch } from "@/lib/api/server";
import type { ProviderMapEntry } from "@/lib/types";

export default async function AdminFleetMapPage() {
  const page = await apiFetch<{ results: ProviderMapEntry[] }>("/admin/map");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Fleet map</h1>
      <FleetMapClientOnly initialProviders={page.results} />
    </div>
  );
}
