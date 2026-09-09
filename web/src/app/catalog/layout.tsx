import { redirect } from "next/navigation";
import type { ReactNode } from "react";

import { getSession } from "@/lib/auth/session";

// Catalog browsing stays open to anonymous visitors and CUSTOMER/ADMIN
// (backend `/parts` endpoints are AllowAny by design). MECHANIC and
// RECOVERY have no storefront use case — mechanics source parts through
// the scoped in-job "Request Parts" picker instead (PartsSourcingRequest),
// and recovery jobs don't consume parts at all — so send them back to
// their own portal rather than letting them browse/cart/checkout here.
export default async function CatalogLayout({ children }: { children: ReactNode }) {
  const user = await getSession();
  if (user?.role === "MECHANIC") redirect("/mechanic");
  if (user?.role === "RECOVERY") redirect("/recovery");

  return children;
}
