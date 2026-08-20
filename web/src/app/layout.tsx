import type { Metadata } from "next";
import { Big_Shoulders, IBM_Plex_Mono, IBM_Plex_Sans } from "next/font/google";

import { SiteFooter } from "@/components/layout/SiteFooter";
import { SiteHeader } from "@/components/layout/SiteHeader";
import { PushRegistration } from "@/components/PushRegistration";
import { apiFetch } from "@/lib/api/server";
import { AuthProvider } from "@/lib/auth/AuthProvider";
import { getSession } from "@/lib/auth/session";
import { CartCountProvider } from "@/lib/cart/CartCountProvider";
import type { Cart } from "@/lib/types";

import "./globals.css";

const bigShoulders = Big_Shoulders({
  variable: "--font-big-shoulders",
  subsets: ["latin"],
  weight: ["600", "700", "800"],
});

const plexSans = IBM_Plex_Sans({
  variable: "--font-plex-sans",
  subsets: ["latin"],
  weight: ["400", "500", "600"],
});

const plexMono = IBM_Plex_Mono({
  variable: "--font-plex-mono",
  subsets: ["latin"],
  weight: ["400", "500"],
});

export const metadata: Metadata = {
  title: "AutoServe — Genuine Spare Parts, Tanzania",
  description:
    "Browse and buy compatible auto spare parts, pay by card or mobile money, and track delivery — AutoServe's Tanzania storefront.",
};

async function getInitialCartCount(user: Awaited<ReturnType<typeof getSession>>) {
  if (user?.role !== "CUSTOMER") return 0;
  try {
    const cart = await apiFetch<Cart>("/cart");
    return cart.items.reduce((sum, item) => sum + item.quantity, 0);
  } catch {
    return 0;
  }
}

export default async function RootLayout({ children }: LayoutProps<"/">) {
  const user = await getSession();
  const cartCount = await getInitialCartCount(user);

  return (
    <html
      lang="en"
      className={`${bigShoulders.variable} ${plexSans.variable} ${plexMono.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col">
        <AuthProvider initialUser={user}>
          <CartCountProvider initialCount={cartCount}>
            <SiteHeader />
            <main className="mx-auto w-full max-w-6xl flex-1 px-4 py-8 sm:px-6">{children}</main>
            <SiteFooter />
            <PushRegistration />
          </CartCountProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
