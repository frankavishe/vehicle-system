import { redirect } from "next/navigation";
import type { ReactNode } from "react";

import { DashboardTabs } from "@/components/layout/DashboardTabs";
import { apiFetch } from "@/lib/api/server";
import { getSession } from "@/lib/auth/session";
import type { MeResponse } from "@/lib/types";

const TABS = [
  { href: "/mechanic", label: "Dashboard" },
  { href: "/mechanic/earnings", label: "Earnings" },
  { href: "/mechanic/history", label: "History" },
  { href: "/mechanic/documents", label: "Documents" },
];

export default async function MechanicLayout({ children }: { children: ReactNode }) {
  const user = await getSession();
  if (!user) redirect("/login?next=/mechanic");
  if (user.role !== "MECHANIC") redirect("/");

  // is_verified isn't in the JWT (only role/full_name are — see
  // web/src/lib/auth/jwt.ts), so FR-001's "verified mechanic account"
  // gate needs one extra call to the existing /users/me endpoint rather
  // than a new claim (see specs/001-mechanic-web-portal/research.md).
  const me = await apiFetch<MeResponse>("/users/me");
  if (!me.is_verified) redirect("/?notice=mechanic-pending");

  return (
    <div className="flex flex-col gap-6">
      <DashboardTabs items={TABS} />
      {children}
    </div>
  );
}
