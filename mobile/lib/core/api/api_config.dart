/// `API_BASE_URL` is passed via `--dart-define`, not a `.env` file —
/// there's no bundled asset pipeline reading env files at runtime the way
/// Next.js does, and `--dart-define` is baked in at build time per PLAN §7
/// ("no `mobile` service in docker-compose.yml — builds run via the SDK on
/// host/CI"). Defaults to the Android emulator's host-loopback address;
/// override for iOS simulator (`http://localhost:8000/api/v1`) or a real
/// device (your machine's LAN IP) — see mobile/README.md.
class ApiConfig {
  ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  /// Phase 4 (PLAN.md §5.2) — derived from [baseUrl] rather than its own
  /// `--dart-define`, since it's always the same origin/host, just a
  /// different scheme and without the `/api/v1` suffix (apps.tracking's
  /// routing.py already includes that prefix in its own path).
  static String get wsBaseUrl =>
      baseUrl.replaceFirst(RegExp(r'^http'), 'ws').replaceFirst(RegExp(r'/api/v1$'), '');
}
