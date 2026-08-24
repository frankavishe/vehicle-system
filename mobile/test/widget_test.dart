// Placeholder — replaced the default counter-app smoke test (which
// referenced the template's MyApp) since AutoServeApp needs a
// ProviderScope + routed auth state to boot, not a meaningful thing to
// smoke test without a live backend. Real coverage lives in test/unit/
// (router redirect logic, ALLOWED_TRANSITIONS mirror, dio's 401-retry
// interceptor) per PLAN §7's "deliberately light" Flutter test scope.
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder', () {
    expect(1 + 1, 2);
  });
}
