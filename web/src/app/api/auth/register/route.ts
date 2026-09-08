import { NextRequest, NextResponse } from "next/server";

import { API_BASE } from "@/lib/api/config";

/** POST /api/auth/register — proxies Django's /auth/register. Deliberately
 * does not auto-login: the user lands back on the login form and signs in
 * explicitly after creating an account. */
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

  return NextResponse.json({ ok: true }, { status: 201 });
}
