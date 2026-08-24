"use client";

import "leaflet/dist/leaflet.css";

import { divIcon } from "leaflet";
import { useEffect, useRef, useState } from "react";
import { MapContainer, Marker, Popup, TileLayer } from "react-leaflet";

import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import type { LatLng } from "@/lib/types";

// Custom dot markers instead of Leaflet's default pin image — sidesteps
// the well-known "default marker icon 404s under a bundler" issue
// entirely, and reads better against this app's own palette than the
// stock blue pin would.
function dotIcon(colorVar: string) {
  return divIcon({
    className: "",
    html: `<span style="display:block;width:14px;height:14px;border-radius:9999px;background:var(${colorVar});border:2px solid white;box-shadow:0 0 0 1px rgba(0,0,0,0.25)"></span>`,
    iconSize: [14, 14],
    iconAnchor: [7, 7],
  });
}

const liveIcon = dotIcon("--color-hazard");
const pickupIcon = dotIcon("--color-signal");
const dropoffIcon = dotIcon("--color-go");

type ConnectionState = "connecting" | "open" | "closed";

// Reconnects a fixed number of times with a flat delay — deliberately
// minimal (no exponential backoff) since a tracking session is short-lived
// (one active job) and the user can always reload; not worth more
// machinery than that.
const RECONNECT_DELAY_MS = 3000;
const MAX_RECONNECT_ATTEMPTS = 5;

// PLAN.md §5.2: "driver's Flutter app emits lat/lng every 5s" — this web
// counterpart (used when the provider is on web/, not just Flutter)
// matches that same cadence via a plain poll rather than throttling
// watchPosition's movement-driven callbacks, which fire at an unrelated,
// unpredictable rate.
const LOCATION_PUBLISH_INTERVAL_MS = 5000;

export function TrackingMap({
  serviceRequestId,
  wsBaseUrl,
  accessToken,
  pickup,
  dropoff,
  isProvider,
}: {
  serviceRequestId: string;
  wsBaseUrl: string;
  accessToken: string;
  pickup: LatLng;
  dropoff: LatLng | null;
  isProvider: boolean;
}) {
  const [connection, setConnection] = useState<ConnectionState>("connecting");
  const [livePosition, setLivePosition] = useState<LatLng | null>(null);
  const [sharing, setSharing] = useState(false);
  const [shareError, setShareError] = useState<string | null>(null);
  const socketRef = useRef<WebSocket | null>(null);
  const attemptsRef = useRef(0);

  useEffect(() => {
    let cancelled = false;
    let reconnectTimer: ReturnType<typeof setTimeout>;

    function connect() {
      if (cancelled) return;
      setConnection("connecting");
      const url = `${wsBaseUrl}/ws/api/v1/tracking/${serviceRequestId}/?token=${accessToken}`;
      const socket = new WebSocket(url);
      socketRef.current = socket;

      socket.onopen = () => {
        attemptsRef.current = 0;
        setConnection("open");
      };
      socket.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data) as LatLng & { error?: string };
          if (typeof data.lat === "number" && typeof data.lng === "number") {
            setLivePosition({ lat: data.lat, lng: data.lng });
          }
        } catch {
          // Ignore malformed frames rather than crashing the map.
        }
      };
      socket.onclose = () => {
        setConnection("closed");
        if (cancelled || attemptsRef.current >= MAX_RECONNECT_ATTEMPTS) return;
        attemptsRef.current += 1;
        reconnectTimer = setTimeout(connect, RECONNECT_DELAY_MS);
      };
    }

    connect();
    return () => {
      cancelled = true;
      clearTimeout(reconnectTimer);
      socketRef.current?.close();
    };
  }, [serviceRequestId, wsBaseUrl, accessToken]);

  // Provider-only: polls the browser's geolocation every 5s and publishes
  // it over the same socket, matching apps.tracking.consumers'
  // "only the assigned provider publishes" rule (the backend silently
  // drops anything sent by the customer side, so this is UX, not the
  // actual access control).
  useEffect(() => {
    if (!isProvider || !sharing) return;

    function publish() {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const socket = socketRef.current;
          if (socket?.readyState === WebSocket.OPEN) {
            socket.send(
              JSON.stringify({ lat: position.coords.latitude, lng: position.coords.longitude }),
            );
          }
        },
        () => setShareError("Location permission was denied."),
        { enableHighAccuracy: true, timeout: 8000 },
      );
    }

    publish();
    const interval = setInterval(publish, LOCATION_PUBLISH_INTERVAL_MS);
    return () => clearInterval(interval);
  }, [isProvider, sharing]);

  const center = livePosition ?? pickup;
  const statusTone = connection === "open" ? "go" : connection === "connecting" ? "signal" : "stop";
  const statusLabel = connection === "open" ? "Live" : connection === "connecting" ? "Connecting…" : "Disconnected";

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center justify-between">
        <Badge tone={statusTone}>{statusLabel}</Badge>
        {isProvider && (
          <Button
            variant={sharing ? "danger" : "primary"}
            onClick={() => {
              if (!sharing && !("geolocation" in navigator)) {
                setShareError("This browser doesn't support location sharing.");
                return;
              }
              setShareError(null);
              setSharing((v) => !v);
            }}
          >
            {sharing ? "Stop sharing location" : "Share my location"}
          </Button>
        )}
      </div>
      {shareError && <p className="text-sm text-stop">{shareError}</p>}

      <div className="h-96 w-full overflow-hidden border border-line">
        <MapContainer center={[center.lat, center.lng]} zoom={13} className="h-full w-full">
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <Marker position={[pickup.lat, pickup.lng]} icon={pickupIcon}>
            <Popup>Pickup</Popup>
          </Marker>
          {dropoff && (
            <Marker position={[dropoff.lat, dropoff.lng]} icon={dropoffIcon}>
              <Popup>Dropoff</Popup>
            </Marker>
          )}
          {livePosition && (
            <Marker position={[livePosition.lat, livePosition.lng]} icon={liveIcon}>
              <Popup>Live position</Popup>
            </Marker>
          )}
        </MapContainer>
      </div>
    </div>
  );
}
