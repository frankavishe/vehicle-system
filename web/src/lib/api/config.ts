// Server-only: the Django base URL as reached from inside the Next.js
// server process (Docker service name in compose, localhost otherwise).
// Never exposed to the browser — every authenticated call from the
// browser goes through our own /api/backend proxy instead (see
// src/lib/api/client.ts), so the browser never needs to know this.
export const BACKEND_URL = process.env.BACKEND_INTERNAL_URL ?? "http://localhost:8000";

export const API_BASE = `${BACKEND_URL}/api/v1`;
