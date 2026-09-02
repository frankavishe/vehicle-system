"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import type { FormEvent } from "react";

import { Button } from "@/components/ui/Button";
import { Field, Select, Textarea } from "@/components/ui/Field";
import { apiFetch } from "@/lib/api/client";
import { ApiError } from "@/lib/api/errors";
import type { LatLng, ServiceRequest, ServiceType } from "@/lib/types";

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
        <LocationField
          label="Drop-off location"
          position={dropoff}
          loading={locating === "dropoff"}
          onCapture={() => capture("dropoff")}
        />
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
}: {
  label: string;
  position: LatLng | null;
  loading: boolean;
  onCapture: () => void;
}) {
  return (
    <div className="flex items-center justify-between gap-3 border border-line bg-surface-raised p-3">
      <div className="flex flex-col gap-0.5">
        <span className="text-xs font-semibold uppercase tracking-wide text-steel">{label}</span>
        <span className="text-sm text-steel-soft">
          {position ? `${position.lat.toFixed(5)}, ${position.lng.toFixed(5)}` : "Not captured yet"}
        </span>
      </div>
      <Button type="button" variant="ghost" disabled={loading} onClick={onCapture}>
        {loading ? "Locating…" : "Capture"}
      </Button>
    </div>
  );
}
