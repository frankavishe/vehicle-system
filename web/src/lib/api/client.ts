"use client";

import { ApiError } from "@/lib/api/errors";

interface RequestOptions {
  method?: "GET" | "POST" | "PATCH" | "PUT" | "DELETE";
  body?: unknown;
}

/** Client Components call our own same-origin proxy (see
 * src/app/api/backend/[...path]/route.ts) rather than Django directly —
 * Client Components can't read the httpOnly access-token cookie, but the
 * browser sends it automatically on this same-origin request, and the
 * proxy attaches it as a Bearer header before forwarding to Django. */
export async function apiFetch<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const res = await fetch(`/api/backend${path}`, {
    method: options.method ?? "GET",
    headers: { "Content-Type": "application/json" },
    body: options.body !== undefined ? JSON.stringify(options.body) : undefined,
  });

  if (res.status === 204) return undefined as T;
  const text = await res.text();
  const body = text ? JSON.parse(text) : null;
  if (!res.ok) throw new ApiError(res.status, body);
  return body as T;
}

/** Like apiFetch, but for multipart uploads (e.g. POST
 * /providers/me/documents) — takes a FormData body and deliberately
 * omits a Content-Type header so the browser sets
 * "multipart/form-data; boundary=..." itself; apiFetch's own
 * "Content-Type: application/json" would break the upload. The
 * same-origin proxy (src/app/api/backend/[...path]/route.ts) forwards
 * whatever Content-Type the browser attached, unchanged. */
export async function apiUpload<T>(path: string, formData: FormData): Promise<T> {
  const res = await fetch(`/api/backend${path}`, { method: "POST", body: formData });

  if (res.status === 204) return undefined as T;
  const text = await res.text();
  const body = text ? JSON.parse(text) : null;
  if (!res.ok) throw new ApiError(res.status, body);
  return body as T;
}
