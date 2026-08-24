import { PayoutManager } from "@/components/admin/PayoutManager";
import { apiFetch } from "@/lib/api/server";
import type { Payout } from "@/lib/types";

export default async function AdminPayoutsPage() {
  const page = await apiFetch<{ results: Payout[] }>("/admin/payouts");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Payouts</h1>
      <PayoutManager initialPayouts={page.results} />
    </div>
  );
}
