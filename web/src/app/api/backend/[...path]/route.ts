import { cookies } from "next/headers";
import { NextRequest, NextResponse } from "next/server";

import { API_BASE } from "@/lib/api/config";
import { ACCESS_COOKIE } from "@/lib/auth/cookies";

/** Same-origin proxy every Client Component calls through (see
 * src/lib/api/client.ts) — reads the httpOnly access-token cookie
 * (invisible to browser JS by design) and attaches it as a Bearer header
 * before forwarding to Django. middleware.ts keeps that cookie fresh, so
 * no refresh-on-401 logic is needed here either. */
async function proxy(request: NextRequest, path: string[]): Promise<NextResponse> {
  const jar = await cookies();
  const token = jar.get(ACCESS_COOKIE)?.value;

  const hasBody = !["GET", "HEAD", "DELETE"].includes(request.method);
  const url = `${API_BASE}/${path.join("/")}${request.nextUrl.search}`;

  const res = await fetch(url, {
    method: request.method,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: hasBody ? await request.text() : undefined,
    cache: "no-store",
  });

  const text = await res.text();
  return new NextResponse(text || null, {
    status: res.status,
    headers: { "Content-Type": res.headers.get("Content-Type") ?? "application/json" },
  });
}

type RouteContext = { params: Promise<{ path: string[] }> };

export async function GET(request: NextRequest, { params }: RouteContext) {
  return proxy(request, (await params).path);
}
export async function POST(request: NextRequest, { params }: RouteContext) {
  return proxy(request, (await params).path);
}
export async function PATCH(request: NextRequest, { params }: RouteContext) {
  return proxy(request, (await params).path);
}
export async function PUT(request: NextRequest, { params }: RouteContext) {
  return proxy(request, (await params).path);
}
export async function DELETE(request: NextRequest, { params }: RouteContext) {
  return proxy(request, (await params).path);
}
