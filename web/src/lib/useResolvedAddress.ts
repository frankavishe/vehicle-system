"use client";

import { useEffect, useState } from "react";

import { reverseGeocode } from "@/lib/geocoding";
import type { LatLng } from "@/lib/types";

/** Label for a pickup/dropoff point on a job detail card: the
 * server-persisted address when there is one (set at request time by
 * RequestServiceForm.tsx's own reverseGeocode call), otherwise a
 * client-side reverse-geocode lookup of the same kind — falling back to
 * the raw coordinates while that resolves or if it fails, exactly as
 * reverseGeocode's own contract requires of its callers. Older/seeded
 * requests with no stored address are the common case this covers. */
export function useResolvedAddress(address: string | null | undefined, point: LatLng | null): string {
  const key = point ? `${point.lat},${point.lng}` : null;
  // Keyed rather than reset-on-effect-start — a bare `setResolved(null)`
  // at the top of the effect body is a synchronous setState-in-effect
  // (React's own react-hooks/set-state-in-effect flags it); comparing
  // `result.key` against the current `key` below achieves the same "stale
  // lookup for a since-changed point doesn't render" guarantee without it.
  const [result, setResult] = useState<{ key: string | null; name: string | null }>({
    key: null,
    name: null,
  });

  useEffect(() => {
    if (address || !point) return;

    let cancelled = false;
    reverseGeocode(point.lat, point.lng).then((name) => {
      if (!cancelled) setResult({ key, name });
    });
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [address, point?.lat, point?.lng]);

  if (address) return address;
  if (!point) return "Not set";
  const resolved = result.key === key ? result.name : null;
  return resolved ?? `${point.lat.toFixed(5)}, ${point.lng.toFixed(5)}`;
}
