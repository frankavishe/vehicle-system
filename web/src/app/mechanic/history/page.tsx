import { JobHistoryTable } from "@/components/mechanic/JobHistoryTable";
import { apiFetch } from "@/lib/api/server";
import type { ServiceRequest } from "@/lib/types";

export default async function MechanicHistoryPage() {
  const jobs = await apiFetch<ServiceRequest[]>("/service-requests?status=COMPLETED");

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Job history</h1>
      <JobHistoryTable jobs={jobs} />
    </div>
  );
}
