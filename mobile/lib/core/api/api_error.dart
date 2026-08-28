import 'package:dio/dio.dart';

/// Pulls a human-readable message out of a failed API call's response
/// body. The rest of the app's error handlers assume `e.response?.data`
/// is always a `{"detail": "..."}` map (DRF's default exception shape),
/// which crashes outright the moment a response isn't that shape — hit in
/// practice when a gateway integration 500s and Django's DEBUG error page
/// (HTML) reaches the client instead of JSON, or when a serializer raises
/// a bare list of errors (`["Cart is empty."]`) rather than a dict. This
/// checks the shape before indexing into it.
String extractApiErrorMessage(DioException e, {required String fallback}) {
  final data = e.response?.data;
  if (data is Map) {
    final detail = data['detail'];
    if (detail != null) return detail.toString();
  } else if (data is List && data.isNotEmpty) {
    return data.first.toString();
  }
  return fallback;
}
