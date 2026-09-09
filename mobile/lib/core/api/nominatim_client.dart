import 'package:dio/dio.dart';

/// Reverse-geocodes a captured pickup/drop-off point into a short,
/// human-readable place name via OSM Nominatim
/// (https://nominatim.openstreetmap.org/reverse) — free, no API key,
/// matching this app's existing no-vendor-lock choices (flutter_map/OSM
/// tiles, OSRM routing).
///
/// Deliberately uses its own plain [Dio] instance, never
/// [AutoserveApi]'s injected `_dio` (dio_client.dart) — that one is
/// baseUrl'd to our own backend and carries the auth-refresh interceptor,
/// neither of which apply to a public third-party API.
///
/// Every failure mode (network error, timeout, no result) collapses to a
/// `null` return — callers must treat `null` as "fall back to showing
/// coordinates," never as an error to surface to the user. This lookup is
/// a display nicety, not something capture or submission should ever
/// block on.
class NominatimClient {
  NominatimClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://nominatim.openstreetmap.org',
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            headers: {
              // Nominatim's usage policy requires a valid identifying
              // User-Agent for unattributed use (capped at ~1 req/sec) —
              // trivially satisfied here since this fires once per user
              // capture action, never in bulk/background.
              'User-Agent': 'AutoServe-Mobile/1.0 (contact: support@autoserve.app)',
            },
          ),
        );

  final Dio _dio;

  Future<String?> reverseGeocode({required double lat, required double lng}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': lat,
          'lon': lng,
          'zoom': 18,
          'addressdetails': 1,
        },
      );
      final data = response.data;
      if (data == null) return null;
      return _shortName(data);
    } catch (_) {
      // Network error, timeout, malformed response, whatever — the
      // contract is "no address," never a thrown error.
      return null;
    }
  }

  String? _shortName(Map<String, dynamic> data) {
    final address = data['address'] as Map<String, dynamic>?;
    if (address != null) {
      final line = address['road'] as String? ?? address['neighbourhood'] as String?;
      final area = address['suburb'] as String? ?? address['city'] as String?;
      final parts = [line, area].whereType<String>().where((s) => s.isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.join(', ');
    }

    final displayName = data['display_name'] as String?;
    if (displayName == null || displayName.isEmpty) return null;
    final segments = displayName.split(',').map((s) => s.trim()).toList();
    return segments.take(2).join(', ');
  }
}
