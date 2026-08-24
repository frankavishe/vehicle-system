"use client";

import "leaflet/dist/leaflet.css";

import { divIcon } from "leaflet";
import { useEffect, useState } from "react";
import { MapContainer, Marker, Popup, TileLayer } from "react-leaflet";

import { apiFetch } from "@/lib/api/client";
import type { ProviderMapEntry } from "@/lib/types";

// Dar es Salaam — reasonable default center when no provider has a known
// position yet (an empty fleet shouldn't render a blank world map).
const DEFAULT_CENTER: [number, number] = [-6.7924, 39.2083];

const POLL_INTERVAL_MS = 10000;

function markerIcon(available: boolean) {
  return divIcon({
    className: "",
    html: `<span style="display:block;width:14px;height:14px;border-radius:9999px;background:var(${
      available ? "--color-go" : "--color-steel-soft"
    });border:2px solid white;box-shadow:0 0 0 1px rgba(0,0,0,0.25)"></span>`,
    iconSize: [14, 14],
    iconAnchor: [7, 7],
  });
}

export function FleetMap({ initialProviders }: { initialProviders: ProviderMapEntry[] }) {
  const [providers, setProviders] = useState(initialProviders);

  useEffect(() => {
    const interval = setInterval(async () => {
      try {
        const page = await apiFetch<{ results: ProviderMapEntry[] }>("/admin/map");
        setProviders(page.results);
      } catch {
        // A transient poll failure isn't worth surfacing — the map just
        // keeps showing the last-known positions until the next tick.
      }
    }, POLL_INTERVAL_MS);
    return () => clearInterval(interval);
  }, []);

  const withPosition = providers.filter((p) => p.lat != null && p.lng != null);
  const center = withPosition[0] ? ([withPosition[0].lat, withPosition[0].lng] as [number, number]) : DEFAULT_CENTER;

  return (
    <div className="h-[32rem] w-full overflow-hidden border border-line">
      <MapContainer center={center} zoom={12} className="h-full w-full">
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        {withPosition.map((provider) => (
          <Marker
            key={provider.id}
            position={[provider.lat as number, provider.lng as number]}
            icon={markerIcon(provider.is_available)}
          >
            <Popup>
              {provider.full_name} — {provider.role}
              <br />
              {provider.is_available ? "Available" : "Unavailable"}
            </Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  );
}
