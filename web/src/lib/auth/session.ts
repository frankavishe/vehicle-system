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

/** Phase 4, narrow exception to this file's own rule above ("Client
 * Components can't read an httpOnly cookie"): the WebSocket tracking
 * consumer (apps.tracking, PLAN.md §5.2) authenticates over a
 * `?token=` query-string param, since browsers can't set a WS
 * handshake's headers — there is no same-origin proxy for a WebSocket
 * upgrade the way /api/backend proxies HTTP. src/app/track/[id]/page.tsx
 * is the only caller: it reads the token server-side with this function
 * and hands it once to a Client Component purely to open that one
 * socket — never stored, never sent anywhere else. See cookies.ts. */
export async function getAccessToken(): Promise<string | null> {
  const jar = await cookies();
  return jar.get(ACCESS_COOKIE)?.value ?? null;
}
