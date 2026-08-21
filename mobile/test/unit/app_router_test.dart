import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/router/app_router.dart';

void main() {
  group('computeRedirect', () {
    test('holds position while auth state is still resolving', () {
      expect(
        computeRedirect(isLoading: true, userRole: null, matchedLocation: '/customer'),
        isNull,
      );
    });

    test('sends an unauthenticated user to /login from a protected route', () {
      expect(
        computeRedirect(isLoading: false, userRole: null, matchedLocation: '/mechanic'),
        '/login',
      );
    });

    test('leaves an unauthenticated user alone on /login', () {
      expect(
        computeRedirect(isLoading: false, userRole: null, matchedLocation: '/login'),
        isNull,
      );
    });

    test('bounces a logged-in user away from /login to their role home', () {
      expect(
        computeRedirect(isLoading: false, userRole: 'CUSTOMER', matchedLocation: '/login'),
        '/customer',
      );
    });

    test('bounces a logged-in user away from /register to their role home', () {
      expect(
        computeRedirect(isLoading: false, userRole: 'MECHANIC', matchedLocation: '/register'),
        '/mechanic',
      );
    });

    test('blocks a customer from a mechanic route', () {
      expect(
        computeRedirect(isLoading: false, userRole: 'CUSTOMER', matchedLocation: '/mechanic/jobs/123'),
        '/customer',
      );
    });

    test('lets a mechanic stay within their own sub-routes', () {
      expect(
        computeRedirect(isLoading: false, userRole: 'MECHANIC', matchedLocation: '/mechanic/jobs/123'),
        isNull,
      );
    });

    test('routes each role to its own home', () {
      expect(homeForRole('CUSTOMER'), '/customer');
      expect(homeForRole('MECHANIC'), '/mechanic');
      expect(homeForRole('RECOVERY'), '/recovery');
      expect(homeForRole('ADMIN'), '/admin');
    });
  });
}
