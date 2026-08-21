import 'dart:convert';

/// Decodes a JWT's claims client-side, no signature check — same
/// "purely for UI timing" caveat as web/'s src/proxy.ts: the backend
/// re-verifies every real request, this is only used to read the
/// `role`/`full_name`/`exp` claims for local UI state and the router's
/// redirect guard.
Map<String, dynamic> decodeJwtClaims(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw const FormatException('Not a valid JWT.');
  }
  final payload = base64Url.decode(base64Url.normalize(parts[1]));
  return jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
}

bool isJwtExpired(String token) {
  final claims = decodeJwtClaims(token);
  final exp = claims['exp'] as int?;
  if (exp == null) return true;
  return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp;
}
