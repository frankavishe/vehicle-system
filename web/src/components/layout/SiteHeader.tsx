"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";

import { useAuth } from "@/lib/auth/AuthProvider";
import { useCartCount } from "@/lib/cart/CartCountProvider";

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
    <header className="sticky top-0 z-10 bg-surface">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-6 px-4 py-4 sm:px-6">
        <Link href="/" className="font-display text-2xl font-bold tracking-tight text-asphalt">
          AUTO<span className="text-hazard">SERVE</span>
        </Link>

        <nav className="hidden items-center gap-6 text-sm font-medium text-steel sm:flex">
          <Link href="/catalog" className="hover:text-asphalt">
            Catalog
          </Link>
          {user?.role === "CUSTOMER" && (
            <Link href="/orders" className="hover:text-asphalt">
              My orders
            </Link>
          )}
          {user?.role === "ADMIN" && (
            <>
              <Link href="/admin/vendors" className="hover:text-asphalt">
                Vendors
              </Link>
              <Link href="/admin/inventory" className="hover:text-asphalt">
                Inventory
              </Link>
            </>
          )}
          {user?.role === "MECHANIC" && (
            <Link href="/mechanic" className="hover:text-asphalt">
              Mechanic Portal
            </Link>
          )}
          {user?.role === "RECOVERY" && (
            <Link href="/recovery" className="hover:text-asphalt">
              Recovery Portal
            </Link>
          )}
        </nav>

        <div className="flex items-center gap-4">
          {user?.role === "CUSTOMER" && (
            <Link
              href="/cart"
              className="border border-line bg-surface-raised px-3 py-1.5 text-sm font-semibold text-asphalt hover:border-asphalt"
            >
              Cart{count > 0 ? ` (${count})` : ""}
            </Link>
          )}
          {user ? (
            <button
              onClick={handleLogout}
              disabled={loggingOut}
              className="text-sm font-semibold text-steel hover:text-asphalt disabled:opacity-50"
            >
              {loggingOut ? "Signing out…" : `Sign out (${user.full_name.split(" ")[0]})`}
            </button>
          ) : (
            <div className="flex items-center gap-3 text-sm font-semibold">
              <Link href="/login" className="text-steel hover:text-asphalt">
                Log in
              </Link>
              <Link href="/register" className="bg-hazard px-3 py-1.5 text-white hover:bg-hazard-dark">
                Sign up
              </Link>
            </div>
          )}
        </div>
      </div>
      <div className="hazard-stripe" />
    </header>
  );
}
