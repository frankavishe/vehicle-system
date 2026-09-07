import { redirect } from "next/navigation";
import type { ReactNode } from "react";

import { DashboardTabs } from "@/components/layout/DashboardTabs";
import { getSession } from "@/lib/auth/session";

const TABS = [
  { href: "/admin/users", label: "Users" },
  { href: "/admin/vendors", label: "Vendors" },
  { href: "/admin/inventory", label: "Inventory" },
  { href: "/admin/map", label: "Fleet map" },
  { href: "/admin/disputes", label: "Disputes" },
  { href: "/admin/payouts", label: "Payouts" },
  { href: "/admin/analytics", label: "Analytics" },
];

export default async function AdminLayout({ children }: { children: ReactNode }) {
  const user = await getSession();
  if (!user) redirect("/login?next=/admin/vendors");
  if (user.role !== "ADMIN") redirect("/");

  return (
    <div className="flex flex-col gap-6">
      <DashboardTabs items={TABS} />
      {children}
    </div>
  );
}
