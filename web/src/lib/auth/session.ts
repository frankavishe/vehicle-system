import "server-only";
import { cookies } from "next/headers";

import { ACCESS_COOKIE } from "@/lib/auth/cookies";
import { toSessionUser } from "@/lib/auth/jwt";
import type { SessionUser } from "@/lib/types";

/** Reads the current user out of the (already-fresh, thanks to
 * middleware.ts) access-token cookie. Server Components/Actions only —
 * Client Components get the same data via <AuthProvider> instead, since
 * they can't read an httpOnly cookie. */
export async function getSession(): Promise<SessionUser | null> {
  const jar = await cookies();
  const token = jar.get(ACCESS_COOKIE)?.value;
  if (!token) return null;
  return toSessionUser(token);
}
