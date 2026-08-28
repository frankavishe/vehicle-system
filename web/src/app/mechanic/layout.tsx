import Link from "next/link";
import { redirect } from "next/navigation";
import type { ReactNode } from "react";

import { apiFetch } from "@/lib/api/server";
import { getSession } from "@/lib/auth/session";
import type { MeResponse } from "@/lib/types";

export default async function MechanicLayout({ children }: { children: ReactNode }) {
  const user = await getSession();
  if (!user) redirect("/login?next=/mechanic");
  if (user.role !== "MECHANIC") redirect("/");

  // is_verified isn't in the JWT (only role/full_name are — see
  // web/src/lib/auth/jwt.ts), so FR-001's "verified mechanic account"
  // gate needs one extra call to the existing /users/me endpoint rather
  // than a new claim (see specs/001-mechanic-web-portal/research.md).
  const me = await apiFetch<MeResponse>("/users/me");
  if (!me.is_verified) redirect("/");

  return (
    <div className="flex flex-col gap-6">
      <nav className="flex gap-6 border-b border-line pb-3 text-sm font-semibold text-steel">
        <Link href="/mechanic" className="hover:text-asphalt">
          Dashboard
        </Link>
        <Link href="/mechanic/earnings" className="hover:text-asphalt">
          Earnings
        </Link>
        <Link href="/mechanic/history" className="hover:text-asphalt">
          History
        </Link>
        <Link href="/mechanic/documents" className="hover:text-asphalt">
          Documents
        </Link>
      </nav>
      {children}
    </div>
  );
}
