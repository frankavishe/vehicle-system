// Background push handler for the "WEB" platform (see backend
// apps/notifications: Platform.WEB, DeviceTokenSerializer). A static file
// under public/ can't read process.env at request time, so
// src/lib/firebase.ts passes the public Firebase config as a query string
// when it registers this worker.
importScripts("https://www.gstatic.com/firebasejs/12.18.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/12.18.0/firebase-messaging-compat.js");

const params = new URLSearchParams(self.location.search);

firebase.initializeApp({
  apiKey: params.get("apiKey"),
  authDomain: params.get("authDomain"),
  projectId: params.get("projectId"),
  messagingSenderId: params.get("messagingSenderId"),
  appId: params.get("appId"),
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification ?? {};
  self.registration.showNotification(title ?? "AutoServe", {
    body: body ?? "",
    icon: "/favicon.ico",
  });
});
