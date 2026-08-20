import { NextRequest, NextResponse } from "next/server";

import {
  ACCESS_COOKIE,
  ACCESS_MAX_AGE,
  REFRESH_COOKIE,
  REFRESH_MAX_AGE,
  cookieOptions,
} from "@/lib/auth/cookies";
import { decodeAccessToken, isExpired } from "@/lib/auth/jwt";

/** Proactively refreshes the access token before it expires, so neither
 * Server Components (via apiFetch in src/lib/api/server.ts) nor the
 * /api/backend proxy ever have to juggle refresh-on-401 themselves — by
 * the time either runs, the cookie is already good for this request. */
export async function proxy(request: NextRequest) {
  const refreshToken = request.cookies.get(REFRESH_COOKIE)?.value;
  if (!refreshToken) return NextResponse.next();

  const accessToken = request.cookies.get(ACCESS_COOKIE)?.value;
  const payload = accessToken ? decodeAccessToken(accessToken) : null;
  if (!isExpired(payload)) return NextResponse.next();

  const backendUrl = process.env.BACKEND_INTERNAL_URL ?? "http://localhost:8000";
  try {
    const refreshRes = await fetch(`${backendUrl}/api/v1/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh: refreshToken }),
    });

    if (!refreshRes.ok) {
      // The refresh token itself is dead (expired/blacklisted) — drop
      // both cookies so the page renders logged-out instead of retrying
      // this failed refresh on every request.
      const response = NextResponse.next();
      response.cookies.delete(ACCESS_COOKIE);
      response.cookies.delete(REFRESH_COOKIE);
      return response;
    }

    const data: { access: string; refresh?: string } = await refreshRes.json();

    // Mutate the request's own cookies first so Server Components
    // rendering *this* request see the fresh token via next/headers'
    // cookies(), then build the response from that mutated request so
    // the browser also receives the new Set-Cookie headers.
    request.cookies.set(ACCESS_COOKIE, data.access);
    if (data.refresh) request.cookies.set(REFRESH_COOKIE, data.refresh);

    const response = NextResponse.next({ request });
    response.cookies.set(ACCESS_COOKIE, data.access, cookieOptions(ACCESS_MAX_AGE));
    if (data.refresh) {
      response.cookies.set(REFRESH_COOKIE, data.refresh, cookieOptions(REFRESH_MAX_AGE));
    }
    return response;
  } catch {
    // Backend unreachable — proceed with the stale token; the page's own
    // API call will surface a clear error rather than middleware masking
    // a backend outage as a silent logout.
    return NextResponse.next();
  }
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico|firebase-messaging-sw.js).*)"],
};
