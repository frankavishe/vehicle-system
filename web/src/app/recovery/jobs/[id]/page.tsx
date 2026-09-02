import { notFound } from "next/navigation";

import { ApiError } from "@/lib/api/errors";
import { apiFetch } from "@/lib/api/server";
import { getSession } from "@/lib/auth/session";
import type { ServiceRequest } from "@/lib/types";

import { JobDetailClient } from "./JobDetailClient";

export default async function RecoveryJobDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const user = await getSession();

  let job: ServiceRequest;
  try {
    // _get_visible_service_request already allows a same-type provider to
    // GET a still-PENDING request before accepting it — exactly what
    // FR-005's "estimate before committing" needs, no new visibility rule
    // (research.md "Fare estimate" decision).
    job = await apiFetch<ServiceRequest>(`/service-requests/${id}`);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  // The layout above already redirected anyone without a session, so
  // `user` is non-null here.
  return <JobDetailClient initialJob={job} currentUserId={user!.id} />;
}
