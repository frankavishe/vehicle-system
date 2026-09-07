"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export interface DashboardTabItem {
  href: string;
  label: string;
}

/** Segmented pill-tab bar shared by the admin/mechanic/recovery portal
 * shells, replacing the old flat underlined text-link row. */
export function DashboardTabs({ items }: { items: DashboardTabItem[] }) {
  const pathname = usePathname();

  return (
    <nav className="flex w-fit flex-wrap gap-1 rounded-full border border-line bg-surface-raised p-1 shadow-sm">
      {items.map((item) => {
        const active = pathname === item.href;
        return (
          <Link
            key={item.href}
            href={item.href}
            className={`rounded-full px-4 py-2 text-sm font-medium transition-colors ${
              active ? "bg-primary text-white" : "text-steel hover:text-asphalt"
            }`}
          >
            {item.label}
          </Link>
        );
      })}
    </nav>
  );
}
