import { notFound } from "next/navigation";

import { ApiError } from "@/lib/api/errors";
import { apiFetch } from "@/lib/api/server";
import { getSession } from "@/lib/auth/session";
import type { ServiceRequest } from "@/lib/types";

import { JobDetailClient } from "./JobDetailClient";

export default async function MechanicJobDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const user = await getSession();

  let job: ServiceRequest;
  try {
    job = await apiFetch<ServiceRequest>(`/service-requests/${id}`);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  // The layout above already redirected anyone without a session, so
  // `user` is non-null here.
  return <JobDetailClient initialJob={job} currentUserId={user!.id} />;
}
