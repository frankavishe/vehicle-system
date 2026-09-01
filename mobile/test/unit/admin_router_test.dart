import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/router/app_router.dart';

/// Extends app_router_test.dart's existing coverage of computeRedirect/
/// homeForRole with 003-admin-mobile-app's new nested /admin routes.
void main() {
  group('admin routes', () {
    test('an admin lands on /admin', () {
      expect(homeForRole('ADMIN'), '/admin');
    });

    test('an admin stays put on a nested dispute-detail route', () {
      expect(
        computeRedirect(isLoading: false, userRole: 'ADMIN', matchedLocation: '/admin/disputes/123'),
        isNull,
      );
    });

    test('an admin stays put on a nested moderation route', () {
      expect(
        computeRedirect(
          isLoading: false,
          userRole: 'ADMIN',
          matchedLocation: '/admin/moderation/accounts/123',
        ),
        isNull,
      );
    });

    test('a non-admin is redirected away from an admin route', () {
      expect(
        computeRedirect(isLoading: false, userRole: 'CUSTOMER', matchedLocation: '/admin/disputes/123'),
        '/customer',
      );
    });
  });
}
