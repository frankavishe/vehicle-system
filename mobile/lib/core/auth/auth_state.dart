import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/dio_client.dart';
import 'jwt_utils.dart';
import 'secure_token_store.dart';

/// Decoded from the access token's own claims (role/full_name embedded
/// server-side, PLAN.md §6) — no separate /users/me round trip needed
/// just to know who's logged in and which role's shell to route into.
class AuthUser {
  const AuthUser({required this.id, required this.email, required this.fullName, required this.role});

  final String id;
  final String email;
  final String fullName;
  final String role; // CUSTOMER | MECHANIC | RECOVERY | ADMIN

  factory AuthUser.fromClaims(Map<String, dynamic> claims) => AuthUser(
        id: claims['user_id'] as String,
        email: claims['email'] as String? ?? '',
        fullName: claims['full_name'] as String? ?? '',
        role: claims['role'] as String,
      );
}

/// Holds the current signed-in user (or null). `null` after `build()`
/// resolves means "definitely logged out" — the router's redirect guard
/// waits on this before deciding where to send an unauthenticated user.
class AuthController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    final store = ref.watch(secureTokenStoreProvider);
    final access = await store.readAccess();
    if (access == null) return null;
    if (isJwtExpired(access)) {
      final refresh = await store.readRefresh();
      if (refresh == null) return null;
      // Let the dio interceptor's refresh path handle renewal on the
      // next real request; for the boot-time check, an expired access
      // token with no verified refresh is treated as logged out.
      return null;
    }
    return AuthUser.fromClaims(decodeJwtClaims(access));
  }

  Future<void> login({required String email, required String password}) async {
    final dio = ref.read(dioProvider);
    final store = ref.read(secureTokenStoreProvider);
    final response = await dio.post('/auth/login', data: {'email': email, 'password': password});
    final access = response.data['access'] as String;
    final refresh = response.data['refresh'] as String;
    await store.save(access: access, refresh: refresh);
    state = AsyncData(AuthUser.fromClaims(decodeJwtClaims(access)));
  }

  Future<void> register({
    required String email,
    required String phone,
    required String fullName,
    required String password,
    required String role,
  }) async {
    final dio = ref.read(dioProvider);
    await dio.post('/auth/register', data: {
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'password': password,
      'role': role,
    });
    // Register returns the created user, no tokens — chain an immediate
    // login so signup lands the user straight in (same pattern as web/'s
    // register page).
    await login(email: email, password: password);
  }

  Future<void> logout() async {
    await ref.read(secureTokenStoreProvider).clear();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(AuthController.new);
