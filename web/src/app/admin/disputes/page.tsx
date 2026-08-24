import { DisputeManager } from "@/components/admin/DisputeManager";
import { apiFetch } from "@/lib/api/server";
import type { Dispute } from "@/lib/types";

export default async function AdminDisputesPage() {
  const page = await apiFetch<{ results: Dispute[] }>("/admin/disputes");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Disputes</h1>
      <DisputeManager initialDisputes={page.results} />
    </div>
  );
}
