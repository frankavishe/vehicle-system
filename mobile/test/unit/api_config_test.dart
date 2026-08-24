import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/api_config.dart';

void main() {
  group('ApiConfig.wsBaseUrl', () {
    test('derives ws:// from the default http:// baseUrl, dropping /api/v1', () {
      // ApiConfig.baseUrl defaults to http://10.0.2.2:8000/api/v1 (no
      // --dart-define in `flutter test`) — this pins that derivation.
      expect(ApiConfig.wsBaseUrl, 'ws://10.0.2.2:8000');
    });
  });
}
