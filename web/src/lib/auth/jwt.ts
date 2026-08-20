import type { SessionUser, UserRole } from "@/lib/types";

interface AccessTokenPayload {
  user_id: string;
  role: UserRole;
  full_name: string;
  email?: string;
  exp: number;
}

/** Decodes the JWT payload without verifying the signature. This is only
 * ever used to read `role`/`full_name` for UI purposes (nav links, gating
 * which page renders) — Django re-verifies the signature on every real
 * request, so a forged/tampered token here can't grant access to
 * anything; it can only make our own UI momentarily wrong. */
export function decodeAccessToken(token: string): AccessTokenPayload | null {
  try {
    const [, payload] = token.split(".");
    return JSON.parse(base64UrlDecode(payload)) as AccessTokenPayload;
  } catch {
    return null;
  }
}

// Plain atob()/TextDecoder rather than Buffer, so this works unchanged in
// both the Node route handlers/Server Components and the Edge middleware
// (middleware.ts calls this to decide whether the access token needs a
// proactive refresh before the request continues).
function base64UrlDecode(segment: string): string {
  const base64 = segment.replace(/-/g, "+").replace(/_/g, "/");
  const padded = base64.padEnd(base64.length + ((4 - (base64.length % 4)) % 4), "=");
  const binary = atob(padded);
  const bytes = Uint8Array.from(binary, (c) => c.charCodeAt(0));
  return new TextDecoder("utf-8").decode(bytes);
}

export function isExpired(payload: { exp: number } | null, skewSeconds = 10): boolean {
  if (!payload) return true;
  return Date.now() / 1000 >= payload.exp - skewSeconds;
}

export function toSessionUser(token: string): SessionUser | null {
  const payload = decodeAccessToken(token);
  if (!payload) return null;
  return {
    id: payload.user_id,
    role: payload.role,
    full_name: payload.full_name,
    email: payload.email ?? "",
    exp: payload.exp,
  };
}
