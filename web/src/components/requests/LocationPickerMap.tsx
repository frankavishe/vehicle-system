"use client";

import "leaflet/dist/leaflet.css";

import { divIcon } from "leaflet";
import { MapContainer, Marker, TileLayer, useMapEvents } from "react-leaflet";

import type { LatLng } from "@/lib/types";

// Same custom-dot-marker approach as TrackingMap.tsx, sidestepping the
// "default marker icon 404s under a bundler" issue — red here (--color-stop)
// so a dropped pin reads distinctly from tracking's pickup/dropoff dots.
const pinIcon = divIcon({
  className: "",
  html: `<span style="display:block;width:16px;height:16px;border-radius:9999px;background:var(--color-stop);border:2px solid white;box-shadow:0 0 0 1px rgba(0,0,0,0.25)"></span>`,
  iconSize: [16, 16],
  iconAnchor: [8, 8],
});

/** react-leaflet has no `onClick` prop on MapContainer — click handling
 * only exists via useMapEvents, which must run inside the map's context,
 * hence this childless helper component instead of an inline handler. */
function ClickToPick({ onPick }: { onPick: (point: LatLng) => void }) {
  useMapEvents({
    click(e) {
      onPick({ lat: e.latlng.lat, lng: e.latlng.lng });
    },
  });
  return null;
}

export function LocationPickerMap({
  center,
  picked,
  onPick,
}: {
  /** Where to center the map — the already-captured pickup point when
   * there is one, so drop-off starts nearby rather than on a fixed
   * fallback city. */
  center: LatLng;
  picked: LatLng | null;
  onPick: (point: LatLng) => void;
}) {
  return (
    <div className="h-72 w-full overflow-hidden border border-line">
      <MapContainer center={[center.lat, center.lng]} zoom={13} className="h-full w-full">
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        <ClickToPick onPick={onPick} />
        {picked && <Marker position={[picked.lat, picked.lng]} icon={pinIcon} />}
      </MapContainer>
    </div>
  );
}
