"use client";

import { initializeApp, getApps, type FirebaseOptions } from "firebase/app";
import { getMessaging, getToken, isSupported, type Messaging } from "firebase/messaging";

// Human account-setup item, same as backend's FIREBASE_* placeholders
// (backend/.env.example) — no Firebase project exists yet, so every
// export here degrades to a no-op until NEXT_PUBLIC_FIREBASE_* is filled
// in. web/.env.example documents the full var list.
const firebaseConfig: FirebaseOptions = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

const vapidKey = process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY;

export const isFirebaseConfigured = Boolean(
  firebaseConfig.apiKey && firebaseConfig.projectId && firebaseConfig.appId && vapidKey,
);

/** Registers public/firebase-messaging-sw.js (passing config via the
 * registration URL's query string, since a static file under public/
 * can't read process.env at request time) and returns an FCM registration
 * token, or null if Firebase isn't configured yet or the browser denies
 * notification permission. */
export async function registerForPush(): Promise<string | null> {
  if (!isFirebaseConfigured || typeof window === "undefined") return null;
  if (!(await isSupported())) return null;

  const permission = await Notification.requestPermission();
  if (permission !== "granted") return null;

  const params = new URLSearchParams(
    Object.entries(firebaseConfig).filter(([, v]) => v) as [string, string][],
  );
  const registration = await navigator.serviceWorker.register(
    `/firebase-messaging-sw.js?${params}`,
  );

  const app = getApps()[0] ?? initializeApp(firebaseConfig);
  const messaging: Messaging = getMessaging(app);

  return getToken(messaging, { vapidKey, serviceWorkerRegistration: registration });
}
