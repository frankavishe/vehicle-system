import { EarningsSummary } from "@/components/mechanic/EarningsSummary";
import { apiFetch } from "@/lib/api/server";
import type { Payout } from "@/lib/types";

export default async function MechanicEarningsPage() {
  const page = await apiFetch<{ results: Payout[] }>("/providers/me/payouts");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Earnings</h1>
      <EarningsSummary initialPayouts={page.results} />
    </div>
  );
}
