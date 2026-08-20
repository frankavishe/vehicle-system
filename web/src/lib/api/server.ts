import "server-only";
import { cookies } from "next/headers";

import { ACCESS_COOKIE } from "@/lib/auth/cookies";
import { ApiError } from "@/lib/api/errors";
import { API_BASE } from "@/lib/api/config";

interface RequestOptions {
  method?: "GET" | "POST" | "PATCH" | "PUT" | "DELETE";
  body?: unknown;
  /** Bypass Next's fetch cache — used for anything that must reflect the
   * logged-in user's own state (cart, orders, /users/me). */
  noStore?: boolean;
}

/** Server Components/Actions call Django directly (server-to-server) —
 * no need to round-trip through our own /api/backend proxy when we're
 * already on the server. middleware.ts keeps the access-token cookie
 * fresh before any of these run, so no refresh-on-401 logic lives here. */
export async function apiFetch<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const jar = await cookies();
  const token = jar.get(ACCESS_COOKIE)?.value;

  const res = await fetch(`${API_BASE}${path}`, {
    method: options.method ?? "GET",
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: options.body !== undefined ? JSON.stringify(options.body) : undefined,
    cache: options.noStore === false ? undefined : "no-store",
  });

  return parseResponse<T>(res);
}

export async function parseResponse<T>(res: Response): Promise<T> {
  if (res.status === 204) return undefined as T;
  const text = await res.text();
  const body = text ? JSON.parse(text) : null;
  if (!res.ok) throw new ApiError(res.status, body);
  return body as T;
}
