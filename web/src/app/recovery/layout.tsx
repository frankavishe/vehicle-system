import { redirect } from "next/navigation";
import type { ReactNode } from "react";

import { DashboardTabs } from "@/components/layout/DashboardTabs";
import { apiFetch } from "@/lib/api/server";
import { getSession } from "@/lib/auth/session";
import type { MeResponse } from "@/lib/types";

const TABS = [
  { href: "/recovery", label: "Dispatch" },
  { href: "/recovery/performance", label: "Performance" },
];

export default async function RecoveryLayout({ children }: { children: ReactNode }) {
  const user = await getSession();
  if (!user) redirect("/login?next=/recovery");
  if (user.role !== "RECOVERY") redirect("/");

  // is_verified isn't in the JWT (only role/full_name are — see
  // web/src/lib/auth/jwt.ts), so FR-001's "verified recovery account"
  // gate needs one extra call to the existing /users/me endpoint, exactly
  // as 001-mechanic-web-portal's layout.tsx already does.
  const me = await apiFetch<MeResponse>("/users/me");
  if (!me.is_verified) redirect("/?notice=recovery-pending");

  return (
    <div className="flex flex-col gap-6">
      <DashboardTabs items={TABS} />
      {children}
    </div>
  );
}
