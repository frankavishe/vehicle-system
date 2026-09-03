"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import type { FormEvent } from "react";

import { Button } from "@/components/ui/Button";
import { Field, Select, Textarea } from "@/components/ui/Field";
import { LocationPickerMapClientOnly } from "@/components/requests/LocationPickerMapClientOnly";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import type { LatLng, ServiceRequest, ServiceType } from "@/lib/types";

// Dar es Salaam — matches the backend's own test/demo fixture
// (apps/dispatch/tests/factories.py's DAR_ES_SALAAM), used to center the
// drop-off map when pickup hasn't been captured yet.
const FALLBACK_CENTER: LatLng = { lat: -6.7924, lng: 39.2083 };

const SERVICE_TYPES: { value: ServiceType; label: string }[] = [
  { value: "MECHANIC", label: "Mechanic — fix it where I am" },
  { value: "RECOVERY", label: "Towing — take my vehicle somewhere" },
];

/** Wraps the browser Geolocation API (navigator.geolocation) — the web
 * equivalent of the mobile app's `geolocator` package
 * (mobile/lib/features/customer/screens/request_service_screen.dart) —
 * in a Promise so the two capture buttons below can `await` it. */
function getCurrentPosition(): Promise<LatLng> {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error("Location isn't available in this browser."));
      return;
    }
    navigator.geolocation.getCurrentPosition(
      (position) => resolve({ lat: position.coords.latitude, lng: position.coords.longitude }),
      (err) => reject(new Error(err.message || "Couldn't get your location.")),
      { enableHighAccuracy: true, timeout: 15000 },
    );
  });
}

export function RequestServiceForm() {
  const router = useRouter();
  const [serviceType, setServiceType] = useState<ServiceType>("MECHANIC");
  const [description, setDescription] = useState("");
  const [pickup, setPickup] = useState<LatLng | null>(null);
  const [dropoff, setDropoff] = useState<LatLng | null>(null);
  const [locating, setLocating] = useState<"pickup" | "dropoff" | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  // Whether the inline drop-off map picker is expanded. Only drop-off gets
  // this — pickup is always "wherever the customer currently is", so
  // map-picking it wouldn't make sense — see LocationField's onPickMap doc.
  const [pickingDropoff, setPickingDropoff] = useState(false);

  async function capture(which: "pickup" | "dropoff") {
    setLocating(which);
    setError(null);
    try {
      const position = await getCurrentPosition();
      if (which === "pickup") setPickup(position);
      else setDropoff(position);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Couldn't get your location.");
    } finally {
      setLocating(null);
    }
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (!pickup) {
      setError("Capture your pickup location first.");
      return;
    }
    if (serviceType === "RECOVERY" && !dropoff) {
      setError("Recovery requests need a drop-off location too.");
      return;
    }

    setSubmitting(true);
    setError(null);
    try {
      const created = await apiFetch<ServiceRequest>("/service-requests", {
        method: "POST",
        body: {
          service_type: serviceType,
          pickup_lat: pickup.lat,
          pickup_lng: pickup.lng,
          dropoff_lat: dropoff?.lat,
          dropoff_lng: dropoff?.lng,
          problem_description: description.trim() || undefined,
        },
      });
      router.push(`/track/${created.id}`);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Couldn't send this request.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="flex w-full max-w-sm flex-col gap-4">
      <Field label="What do you need" htmlFor="service_type">
        <Select
          id="service_type"
          value={serviceType}
          onChange={(e) => {
            setServiceType(e.target.value as ServiceType);
            setDropoff(null);
            setPickingDropoff(false);
          }}
        >
          {SERVICE_TYPES.map((t) => (
            <option key={t.value} value={t.value}>
              {t.label}
            </option>
          ))}
        </Select>
      </Field>

      <Field label="What's wrong?" htmlFor="description">
        <Textarea
          id="description"
          rows={3}
          placeholder="e.g. Flat tyre, engine won't start…"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />
      </Field>

      <LocationField
        label="Pickup location"
        position={pickup}
        loading={locating === "pickup"}
        onCapture={() => capture("pickup")}
      />

      {serviceType === "RECOVERY" && (
        <>
          <LocationField
            label="Drop-off location"
            position={dropoff}
            loading={locating === "dropoff"}
            onCapture={() => capture("dropoff")}
            onPickMap={() => setPickingDropoff((v) => !v)}
          />
          {pickingDropoff && (
            <div className="flex flex-col gap-2 border border-line bg-surface-raised p-3">
              <p className="text-sm text-steel-soft">
                Click the map to drop a pin — useful when the vehicle is broken down somewhere
                other than where the tow should end up (e.g. a garage across town).
              </p>
              <LocationPickerMapClientOnly
                center={pickup ?? FALLBACK_CENTER}
                picked={dropoff}
                onPick={setDropoff}
              />
              <div className="flex items-center justify-between gap-3">
                <Button
                  type="button"
                  variant="ghost"
                  disabled={locating === "dropoff"}
                  onClick={() => capture("dropoff")}
                >
                  {locating === "dropoff" ? "Locating…" : "Use my current location"}
                </Button>
                <Button type="button" disabled={!dropoff} onClick={() => setPickingDropoff(false)}>
                  Use this location
                </Button>
              </div>
            </div>
          )}
        </>
      )}

      {error ? <p className="text-sm text-stop">{error}</p> : null}

      <Button type="submit" disabled={submitting}>
        {submitting ? "Sending…" : "Request now"}
      </Button>
    </form>
  );
}

function LocationField({
  label,
  position,
  loading,
  onCapture,
  onPickMap,
}: {
  label: string;
  position: LatLng | null;
  loading: boolean;
  onCapture: () => void;
  // Only drop-off passes this — pickup is always "wherever the customer
  // currently is" (Geolocation only), so map-picking it wouldn't make
  // sense. Mirrors mobile/lib/.../request_service_screen.dart's
  // _LocationTile.onPickMap.
  onPickMap?: () => void;
}) {
  return (
    <div className="flex items-center justify-between gap-3 border border-line bg-surface-raised p-3">
      <div className="flex flex-col gap-0.5">
        <span className="text-xs font-semibold uppercase tracking-wide text-steel">{label}</span>
        <span className="text-sm text-steel-soft">
          {position ? `${position.lat.toFixed(5)}, ${position.lng.toFixed(5)}` : "Not captured yet"}
        </span>
      </div>
      <div className="flex items-center gap-2">
        {onPickMap && (
          <Button type="button" variant="ghost" onClick={onPickMap}>
            Pick on map
          </Button>
        )}
        <Button type="button" variant="ghost" disabled={loading} onClick={onCapture}>
          {loading ? "Locating…" : "Capture"}
        </Button>
      </div>
    </div>
  );
}
