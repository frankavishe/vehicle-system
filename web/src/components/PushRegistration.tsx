"use client";

import { useEffect, useRef } from "react";

import { apiFetch } from "@/lib/api/client";
import { useAuth } from "@/lib/auth/AuthProvider";
import { isFirebaseConfigured, registerForPush } from "@/lib/firebase";

/** Silently registers this browser for push once per signed-in session —
 * reuses Phase 1's existing POST /users/me/device-tokens unchanged, just
 * with platform: "WEB". No-ops entirely until a real Firebase project
 * exists (see src/lib/firebase.ts), so this is safe to render always. */
export function PushRegistration() {
  const { user } = useAuth();
  const attempted = useRef(false);

  useEffect(() => {
    if (!user || attempted.current || !isFirebaseConfigured) return;
    attempted.current = true;

    registerForPush()
      .then((token) => {
        if (!token) return;
        return apiFetch("/users/me/device-tokens", {
          method: "POST",
          body: { fcm_token: token, platform: "WEB" },
        });
      })
      .catch(() => {
        // Push is a convenience, not a blocking flow — a denied
        // permission or unreachable messaging service just means no push
        // for this session.
      });
  }, [user]);

  return null;
}
