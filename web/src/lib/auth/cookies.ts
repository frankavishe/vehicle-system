// Cookie names shared between middleware.ts and the /api/auth/* route
// handlers. Both tokens are httpOnly — no client-side JS ever reads the
// cookie itself (see PLAN.md §6: "Next.js httpOnly cookies"). Lifetimes
// mirror the backend's SIMPLE_JWT settings (config/settings/base.py).
// One narrow, deliberate exception: src/lib/auth/session.ts's
// getAccessToken() hands the raw access token to a Client Component once,
// server-side, so the Phase 4 tracking page can open its WebSocket (see
// that function's docstring) — the cookie itself is still never read
// from the browser.
export const ACCESS_COOKIE = "as_at";
export const REFRESH_COOKIE = "as_rt";

export const ACCESS_MAX_AGE = 15 * 60; // 15 minutes
export const REFRESH_MAX_AGE = 7 * 24 * 60 * 60; // 7 days

export function cookieOptions(maxAge: number) {
  return {
    httpOnly: true,
    sameSite: "lax" as const,
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge,
  };
}
