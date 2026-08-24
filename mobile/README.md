# AutoServe Mobile (Flutter)

Started in Phase 3 — role-based dashboards for Customer, Mechanic,
Recovery Operator, and Admin. Phase 4 adds `features/tracking/` (live
WebSocket location tracking, PLAN.md §5.2). See `PLAN.md` §7 and
`C:\Users\User\.claude\plans\phase-3-flutter-dispatch-plan.md` for the
Phase 3 design and every flagged package/scope decision from that phase.

## Stack

Riverpod (state) · go_router (routing + role-based redirect guards) · dio
(HTTP, with a Bearer-token + 401-refresh-retry interceptor) ·
flutter_secure_storage (JWT pair) · firebase_core/firebase_messaging (FCM,
guarded no-op until a real Firebase project exists) ·
flutter_local_notifications (foreground alert display) · geolocator (GPS) ·
image_picker (document uploads) · freezed/json_serializable (DTOs in
`lib/shared/models/`) · url_launcher (hands "buy now" off to the web
storefront's hosted checkout instead of a native payment UI) ·
**Phase 4:** flutter_map + latlong2 (OpenStreetMap tiles, no API key —
same reasoning as the backend's self-hosted OSRM and web/'s react-leaflet,
confirmed with the user) · web_socket_channel (the tracking consumer's
client).

**`image_picker`, not `file_picker`** (the plan's original choice): three
separate real `flutter build apk` attempts hit reproducible Android/Gradle
toolchain failures with `file_picker` on this Flutter release (8.x hardcodes
an incompatible `compileSdk`; 11.x's Kotlin sources fail to link under this
release's newer "Built-in Kotlin" build support). Flagged trade-off:
`features/provider/screens/documents_screen.dart` now only accepts
gallery/camera images, not PDFs, for provider certification uploads.

## Running against the backend

No `mobile` service exists in `infra/docker-compose.yml` — this app is
built via the Flutter SDK on your host/CI, not containerized; the compiled
app talks to the `backend` container's already host-exposed `:8000`.

`API_BASE_URL` is passed at build/run time via `--dart-define`, not a
`.env` file (there's no bundled env-file reader at Flutter runtime the way
Next.js has one). Defaults to the Android emulator's host-loopback address
if omitted.

```bash
# Android emulator (default — no flag needed)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1

# iOS simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1

# Physical device on the same network — use your machine's LAN IP
flutter run --dart-define=API_BASE_URL=http://192.168.1.23:8000/api/v1
```

`ApiConfig.wsBaseUrl` (the tracking consumer's `ws://`/`wss://` origin) is
derived from `API_BASE_URL` at runtime, not its own `--dart-define` — same
host, just a different scheme and without the `/api/v1` suffix.

The parts-sourcing "buy now" flow also needs the storefront's base URL
(`web/`) to build the checkout deep link — same pattern:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=STOREFRONT_BASE_URL=http://10.0.2.2:3000
```

## Firebase (push notifications)

No Firebase project exists yet (Phase 1's human-account-setup checklist
item, still open — see `phase.md`). Every push-related code path is
guarded and fails soft without one: `Firebase.initializeApp()`'s failure
is caught in `core/push/fcm_service.dart`, so the app boots and runs
normally with push simply disabled. Once a project exists:

1. Register Android/iOS apps in the Firebase console.
2. Drop `google-services.json` into `android/app/`.
3. For iOS, drop `GoogleService-Info.plist` into `ios/Runner/` (via Xcode,
   so it's added to the target).
4. No other code changes needed — `FcmService` picks it up automatically.

## Codegen

`lib/shared/models/` DTOs are freezed + json_serializable. After changing
any of them:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Testing

Deliberately light, mirroring `web/`'s own documented `frontend-ci.yml`
asymmetry applied to this second UI stack: `test/unit/` covers pure logic
only — the router's redirect guard (`app_router_test.dart`), the
client-side `ALLOWED_TRANSITIONS` mirror (`service_status_transitions_test.dart`),
the dio 401-refresh-retry interceptor
(`dio_401_retry_test.dart`, against a scripted fake `HttpClientAdapter` —
no real network, no mocking package), and (Phase 4) the
`wsBaseUrl` derivation (`api_config_test.dart`). No widget/golden/
integration suite this phase — `features/tracking/screens/tracking_screen.dart`'s
actual WebSocket/map behavior is exercised manually against a running
backend, same as every other screen.

```bash
flutter analyze
flutter test
```
