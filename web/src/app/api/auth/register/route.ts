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

/** POST /api/auth/register — proxies Django's /auth/register, then
 * chains an immediate login with the same credentials so a new signup
 * lands the user straight in rather than back at the login form. */
export async function POST(request: NextRequest) {
  const payload = await request.json();

  const registerRes = await fetch(`${API_BASE}/auth/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  const registerBody = await registerRes.json();
  if (!registerRes.ok) {
    return NextResponse.json(registerBody, { status: registerRes.status });
  }

  const loginRes = await fetch(`${API_BASE}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: payload.email, password: payload.password }),
  });
  const loginBody = await loginRes.json();
  if (!loginRes.ok) {
    // Account was created but the follow-up login failed for some
    // unrelated reason — surface that as a distinct, actionable message
    // rather than a generic registration failure.
    return NextResponse.json(
      { detail: "Account created — please log in." },
      { status: 201 },
    );
  }

  const user = toSessionUser(loginBody.access);
  const response = NextResponse.json({ user }, { status: 201 });
  response.cookies.set(ACCESS_COOKIE, loginBody.access, cookieOptions(ACCESS_MAX_AGE));
  response.cookies.set(REFRESH_COOKIE, loginBody.refresh, cookieOptions(REFRESH_MAX_AGE));
  return response;
}
