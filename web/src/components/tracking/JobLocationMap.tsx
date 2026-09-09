"use client";

import "leaflet/dist/leaflet.css";

import { divIcon } from "leaflet";
import { useEffect } from "react";
import { MapContainer, Marker, Popup, TileLayer, useMap } from "react-leaflet";

import type { LatLng } from "@/lib/types";

// Same custom-dot-marker approach as TrackingMap.tsx — same colors too
// (--color-signal for pickup, --color-go for dropoff) so a job's location
// reads the same way here as it does once tracking goes live.
function dotIcon(colorVar: string) {
  return divIcon({
    className: "",
    html: `<span style="display:block;width:14px;height:14px;border-radius:9999px;background:var(${colorVar});border:2px solid white;box-shadow:0 0 0 1px rgba(0,0,0,0.25)"></span>`,
    iconSize: [14, 14],
    iconAnchor: [7, 7],
  });
}

const pickupIcon = dotIcon("--color-signal");
const dropoffIcon = dotIcon("--color-go");

/** Fits both pins in view when there's a dropoff to show alongside pickup
 * — a fixed zoom level would either crop one of them off-screen or, for a
 * short hop, waste most of the frame on empty space. react-leaflet has no
 * declarative "bounds" prop that keeps recalculating like this, hence the
 * childless helper-in-map-context pattern (see LocationPickerMap.tsx's
 * ClickToPick for the same reason). */
function FitToMarkers({ pickup, dropoff }: { pickup: LatLng; dropoff: LatLng | null }) {
  const map = useMap();
  useEffect(() => {
    if (dropoff) {
      map.fitBounds(
        [
          [pickup.lat, pickup.lng],
          [dropoff.lat, dropoff.lng],
        ],
        { padding: [32, 32] },
      );
    }
    // Only pickup/dropoff moving should re-fit — not e.g. the user's own
    // subsequent pan/zoom on the map.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [map, pickup.lat, pickup.lng, dropoff?.lat, dropoff?.lng]);
  return null;
}

/** Static (no live tracking socket) map for a job's pickup and, once set,
 * dropoff — the actual pinned location behind the address text on job
 * detail pages, not just coordinates as a string. Once a provider is
 * assigned, /track/[serviceRequestId]'s TrackingMap.tsx takes over with
 * the live position on top of the same two pins. */
export function JobLocationMap({ pickup, dropoff }: { pickup: LatLng; dropoff: LatLng | null }) {
  return (
    <div className="h-72 w-full overflow-hidden rounded-2xl border border-line shadow-sm">
      <MapContainer center={[pickup.lat, pickup.lng]} zoom={13} className="h-full w-full">
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        <FitToMarkers pickup={pickup} dropoff={dropoff} />
        <Marker position={[pickup.lat, pickup.lng]} icon={pickupIcon}>
          <Popup>Pickup</Popup>
        </Marker>
        {dropoff && (
          <Marker position={[dropoff.lat, dropoff.lng]} icon={dropoffIcon}>
            <Popup>Dropoff</Popup>
          </Marker>
        )}
      </MapContainer>
    </div>
  );
}
