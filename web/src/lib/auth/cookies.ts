// Cookie names shared between middleware.ts and the /api/auth/* route
// handlers. Both tokens are httpOnly — no client-side JS ever reads them
// (see PLAN.md §6: "Next.js httpOnly cookies"). Lifetimes mirror the
// backend's SIMPLE_JWT settings (config/settings/base.py).
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
