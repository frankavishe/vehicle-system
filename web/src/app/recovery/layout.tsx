import Link from "next/link";
import { redirect } from "next/navigation";
import type { ReactNode } from "react";

import { apiFetch } from "@/lib/api/server";
import { getSession } from "@/lib/auth/session";
import type { MeResponse } from "@/lib/types";

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
      <nav className="flex gap-6 border-b border-line pb-3 text-sm font-semibold text-steel">
        <Link href="/recovery" className="hover:text-asphalt">
          Dispatch
        </Link>
        <Link href="/recovery/performance" className="hover:text-asphalt">
          Performance
        </Link>
      </nav>
      {children}
    </div>
  );
}
