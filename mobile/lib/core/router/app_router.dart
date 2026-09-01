import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_shell.dart';
import '../../features/admin/screens/dispute_detail_screen.dart';
import '../../features/admin/screens/moderation_screen.dart';
import '../../features/admin/screens/payout_trigger_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/customer/screens/customer_shell.dart';
import '../../features/customer/screens/request_detail_screen.dart';
import '../../features/provider/screens/provider_job_detail_screen.dart';
import '../../features/provider/screens/provider_shell.dart';
import '../../features/shop/screens/cart_screen.dart';
import '../../features/shop/screens/checkout_screen.dart';
import '../../features/shop/screens/my_orders_screen.dart';
import '../../features/shop/screens/order_detail_screen.dart';
import '../../features/shop/screens/part_detail_screen.dart';
import '../../features/tracking/screens/tracking_screen.dart';
import '../auth/auth_state.dart';

/// Role -> the shell route it's confined to. Admin's mobile surface
/// (003-admin-mobile-app) has its own nested routes below, same pattern
/// as every other role.
String homeForRole(String role) => switch (role) {
      'CUSTOMER' => '/customer',
      'MECHANIC' => '/mechanic',
      'RECOVERY' => '/recovery',
      'ADMIN' => '/admin',
      _ => '/login',
    };

/// Pure redirect decision, extracted out of the `GoRouter.redirect`
/// closure so it's unit-testable without standing up go_router/Riverpod
/// (PLAN §7's "app_router_test.dart redirect logic"). `authState` is
/// `AsyncValue<AuthUser?>` but typed as `dynamic`-free `AsyncValue` here
/// to avoid a test-only dependency on the exact AuthUser shape beyond
/// `.role`.
String? computeRedirect({
  required bool isLoading,
  required String? userRole,
  required String matchedLocation,
}) {
  final loggingIn = matchedLocation == '/login' || matchedLocation == '/register';

  // Still resolving the boot-time token check — hold position rather
  // than bouncing to /login and immediately back.
  if (isLoading) return null;

  if (userRole == null) {
    return loggingIn ? null : '/login';
  }
  if (loggingIn) return homeForRole(userRole);

  final home = homeForRole(userRole);
  if (!matchedLocation.startsWith(home)) {
    return home;
  }
  return null;
}

/// Bridges Riverpod's async auth state into go_router's `refreshListenable`
/// so a login/logout re-runs the redirect logic below without any manual
/// `context.go(...)` calls scattered through the login/logout code paths.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      return computeRedirect(
        isLoading: authState.isLoading,
        userRole: authState.value?.role,
        matchedLocation: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerShell(),
        routes: [
          GoRoute(
            path: 'requests/:id',
            builder: (context, state) =>
                RequestDetailScreen(requestId: state.pathParameters['id']!),
          ),
          // Nested per-role (not one shared top-level route) because
          // computeRedirect above confines every authenticated user to
          // paths under their own role's home — see its docstring.
          GoRoute(
            path: 'tracking/:id',
            builder: (context, state) =>
                TrackingScreen(requestId: state.pathParameters['id']!),
          ),
          // Shop — the customer's native e-commerce flow. The listing
          // itself is a shell tab (ShopScreen); everything past it is a
          // pushed route, same as requests/:id and tracking/:id above.
          GoRoute(
            path: 'shop/:id',
            builder: (context, state) =>
                PartDetailScreen(partId: state.pathParameters['id']!),
          ),
          GoRoute(path: 'cart', builder: (context, state) => const CartScreen()),
          GoRoute(path: 'checkout', builder: (context, state) => const CheckoutScreen()),
          GoRoute(path: 'orders', builder: (context, state) => const MyOrdersScreen()),
          GoRoute(
            path: 'orders/:id',
            builder: (context, state) =>
                OrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/mechanic',
        builder: (context, state) => const ProviderShell(role: 'MECHANIC'),
        routes: [
          GoRoute(
            path: 'jobs/:id',
            builder: (context, state) =>
                ProviderJobDetailScreen(requestId: state.pathParameters['id']!, role: 'MECHANIC'),
          ),
          GoRoute(
            path: 'tracking/:id',
            builder: (context, state) =>
                TrackingScreen(requestId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/recovery',
        builder: (context, state) => const ProviderShell(role: 'RECOVERY'),
        routes: [
          GoRoute(
            path: 'jobs/:id',
            builder: (context, state) =>
                ProviderJobDetailScreen(requestId: state.pathParameters['id']!, role: 'RECOVERY'),
          ),
          GoRoute(
            path: 'tracking/:id',
            builder: (context, state) =>
                TrackingScreen(requestId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminShell(),
        routes: [
          // 003-admin-mobile-app — deep-linkable so a future push
          // notification (explicitly out of scope this feature, see
          // spec.md Assumptions) has a stable route to land on later
          // without a router change.
          GoRoute(
            path: 'disputes/:id',
            builder: (context, state) =>
                DisputeDetailScreen(disputeId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'moderation/accounts/:id',
            builder: (context, state) =>
                AccountDetailScreen(accountId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'moderation/payout',
            builder: (context, state) => const PayoutTriggerScreen(),
          ),
        ],
      ),
    ],
  );
});
