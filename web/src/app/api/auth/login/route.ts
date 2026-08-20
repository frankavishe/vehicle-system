import { NextRequest, NextResponse } from "next/server";

import { API_BASE } from "@/lib/api/config";
import {
  ACCESS_COOKIE,
  ACCESS_MAX_AGE,
  REFRESH_COOKIE,
  REFRESH_MAX_AGE,
  cookieOptions,
} from "@/lib/auth/cookies";
import { toSessionUser } from "@/lib/auth/jwt";

/** POST /api/auth/login — proxies Django's /auth/login and, on success,
 * stores the pair as httpOnly cookies instead of ever handing the tokens
 * to browser JS (PLAN.md §6). Returns the decoded user for the caller to
 * put straight into <AuthProvider> without a second round trip. */
export async function POST(request: NextRequest) {
  const credentials = await request.json();

  const loginRes = await fetch(`${API_BASE}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(credentials),
  });
  const body = await loginRes.json();
  if (!loginRes.ok) {
    return NextResponse.json(body, { status: loginRes.status });
  }

  const user = toSessionUser(body.access);
  const response = NextResponse.json({ user });
  response.cookies.set(ACCESS_COOKIE, body.access, cookieOptions(ACCESS_MAX_AGE));
  response.cookies.set(REFRESH_COOKIE, body.refresh, cookieOptions(REFRESH_MAX_AGE));
  return response;
}
