import { AvailabilityToggle } from "@/components/mechanic/AvailabilityToggle";
import { JobQueueList } from "@/components/mechanic/JobQueueList";
import { apiFetch } from "@/lib/api/server";
import type { ServiceRequest } from "@/lib/types";

export default async function MechanicDashboardPage() {
  const [availability, jobs] = await Promise.all([
    apiFetch<{ is_available: boolean }>("/providers/me/availability"),
    apiFetch<ServiceRequest[]>("/service-requests"),
  ]);

  return (
    <div className="flex flex-col gap-6">
      <h1 className="font-display text-3xl font-bold uppercase tracking-tight text-asphalt">Dashboard</h1>
      <AvailabilityToggle initialIsAvailable={availability.is_available} />
      <JobQueueList initialJobs={jobs} />
    </div>
  );
}
