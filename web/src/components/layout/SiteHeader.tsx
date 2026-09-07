"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useState } from "react";

import { useAuth } from "@/lib/auth/AuthProvider";
import { useCartCount } from "@/lib/cart/CartCountProvider";

function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
  const pathname = usePathname();
  const active = pathname === href || pathname.startsWith(`${href}/`);
  return (
    <Link
      href={href}
      className={
        active
          ? "rounded-full bg-primary-soft px-3 py-1.5 font-medium text-primary"
          : "px-3 py-1.5 text-steel hover:text-asphalt"
      }
    >
      {children}
    </Link>
  );
}

export function SiteHeader() {
  const { user, setUser } = useAuth();
  const { count } = useCartCount();
  const router = useRouter();
  const [loggingOut, setLoggingOut] = useState(false);

  async function handleLogout() {
    setLoggingOut(true);
    await fetch("/api/auth/logout", { method: "POST" });
    setUser(null);
    setLoggingOut(false);
    router.push("/");
    router.refresh();
  }

  return (
    <header className="sticky top-0 z-10 border-b border-line bg-surface-raised shadow-sm">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-6 px-4 py-4 sm:px-6">
        <Link href="/" className="font-display text-2xl font-bold text-asphalt">
          AUTO<span className="text-primary">SERVE</span>
        </Link>

        <nav className="hidden items-center gap-1 text-sm font-medium sm:flex">
          <NavLink href="/catalog">Catalog</NavLink>
          {user?.role === "CUSTOMER" && (
            <>
              <NavLink href="/orders">My orders</NavLink>
              <NavLink href="/requests">Request mechanic/tow</NavLink>
            </>
          )}
          {user?.role === "ADMIN" && (
            <>
              <NavLink href="/admin/vendors">Vendors</NavLink>
              <NavLink href="/admin/inventory">Inventory</NavLink>
            </>
          )}
          {user?.role === "MECHANIC" && <NavLink href="/mechanic">Mechanic Portal</NavLink>}
          {user?.role === "RECOVERY" && <NavLink href="/recovery">Recovery Portal</NavLink>}
        </nav>

        <div className="flex items-center gap-3">
          {user?.role === "CUSTOMER" && (
            <Link
              href="/cart"
              className="rounded-full border border-line bg-surface px-3 py-1.5 text-sm font-medium text-asphalt hover:border-primary"
            >
              Cart{count > 0 ? ` (${count})` : ""}
            </Link>
          )}
          {user ? (
            <div className="flex items-center gap-2">
              <span className="flex items-center gap-2 rounded-full bg-primary-soft py-1 pl-1 pr-3 text-sm font-medium text-primary">
                <span className="flex h-6 w-6 items-center justify-center rounded-full bg-primary text-xs font-semibold text-white">
                  {user.full_name.charAt(0).toUpperCase()}
                </span>
                {user.full_name.split(" ")[0]}
              </span>
              <button
                onClick={handleLogout}
                disabled={loggingOut}
                className="text-sm font-medium text-steel hover:text-asphalt disabled:opacity-50"
              >
                {loggingOut ? "Signing out…" : "Sign out"}
              </button>
            </div>
          ) : (
            <div className="flex items-center gap-3 text-sm font-medium">
              <Link href="/login" className="text-steel hover:text-asphalt">
                Log in
              </Link>
              <Link
                href="/register"
                className="rounded-full bg-primary px-4 py-1.5 text-white shadow-sm hover:bg-primary-dark"
              >
                Sign up
              </Link>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
