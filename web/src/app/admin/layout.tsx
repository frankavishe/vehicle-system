import Link from "next/link";
import { redirect } from "next/navigation";
import type { ReactNode } from "react";

import { getSession } from "@/lib/auth/session";

export default async function AdminLayout({ children }: { children: ReactNode }) {
  const user = await getSession();
  if (!user) redirect("/login?next=/admin/vendors");
  if (user.role !== "ADMIN") redirect("/");

  return (
    <div className="flex flex-col gap-6">
      <nav className="flex gap-6 border-b border-line pb-3 text-sm font-semibold text-steel">
        <Link href="/admin/vendors" className="hover:text-asphalt">
          Vendors
        </Link>
        <Link href="/admin/inventory" className="hover:text-asphalt">
          Inventory
        </Link>
        <Link href="/admin/map" className="hover:text-asphalt">
          Fleet map
        </Link>
        <Link href="/admin/disputes" className="hover:text-asphalt">
          Disputes
        </Link>
        <Link href="/admin/payouts" className="hover:text-asphalt">
          Payouts
        </Link>
        <Link href="/admin/analytics" className="hover:text-asphalt">
          Analytics
        </Link>
      </nav>
      {children}
    </div>
  );
}
