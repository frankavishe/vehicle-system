/** Reverse-geocodes a captured pickup/drop-off point into a short,
 * human-readable place name via OSM Nominatim
 * (https://nominatim.openstreetmap.org/reverse) — free, no API key,
 * matching this app's existing no-vendor-lock choices (react-leaflet/OSM
 * tiles, OSRM routing).
 *
 * Uses the browser's native `fetch`, not `apiFetch` (lib/api/client.ts) —
 * that one is scoped to our own backend via the `/api/backend` proxy.
 * The browser sends `Referer` automatically, satisfying Nominatim's
 * usage-policy identification requirement (capped at ~1 req/sec) with no
 * extra header needed — this fires once per user capture action, never
 * in bulk/background.
 *
 * Every failure mode (network error, timeout, no result) collapses to a
 * `null` return — callers must treat `null` as "fall back to showing
 * coordinates," never as an error to surface. This lookup is a display
 * nicety, not something capture or submission should ever block on. */
export async function reverseGeocode(lat: number, lng: number): Promise<string | null> {
  try {
    const url = new URL("https://nominatim.openstreetmap.org/reverse");
    url.searchParams.set("format", "jsonv2");
    url.searchParams.set("lat", String(lat));
    url.searchParams.set("lon", String(lng));
    url.searchParams.set("zoom", "18");
    url.searchParams.set("addressdetails", "1");

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000);
    let data: unknown;
    try {
      const res = await fetch(url.toString(), { signal: controller.signal });
      if (!res.ok) return null;
      data = await res.json();
    } finally {
      clearTimeout(timeout);
    }

    return shortName(data);
  } catch {
    return null;
  }
}

function shortName(data: unknown): string | null {
  if (typeof data !== "object" || data === null) return null;
  const record = data as Record<string, unknown>;

  const address = record.address;
  if (typeof address === "object" && address !== null) {
    const a = address as Record<string, unknown>;
    const line = (a.road as string | undefined) || (a.neighbourhood as string | undefined);
    const area = (a.suburb as string | undefined) || (a.city as string | undefined);
    const parts = [line, area].filter((s): s is string => Boolean(s));
    if (parts.length > 0) return parts.join(", ");
  }

  const displayName = record.display_name;
  if (typeof displayName !== "string" || displayName.length === 0) return null;
  return displayName
    .split(",")
    .map((s) => s.trim())
    .slice(0, 2)
    .join(", ");
}
