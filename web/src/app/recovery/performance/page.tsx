import { PerformanceSummary } from "@/components/recovery/PerformanceSummary";
import { apiFetch } from "@/lib/api/server";
import type { ProviderPerformance } from "@/lib/types";

export default async function RecoveryPerformancePage() {
  // No period_start/period_end — the backend defaults to the trailing 30
  // days (contracts/rest.md) so a first-touch call still renders something.
  const performance = await apiFetch<ProviderPerformance>("/providers/me/performance");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Performance</h1>
      <PerformanceSummary initialPerformance={performance} />
    </div>
  );
}
