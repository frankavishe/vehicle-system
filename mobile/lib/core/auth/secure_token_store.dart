import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The minimal key/value contract `SecureTokenStore` needs — narrowed
/// down from `FlutterSecureStorage`'s full API so tests can substitute an
/// in-memory fake instead of going through a platform channel (which
/// isn't available under plain `flutter test`).
abstract class KeyValueStore {
  Future<void> write({required String key, required String? value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
}

class _FlutterSecureKeyValueStore implements KeyValueStore {
  const _FlutterSecureKeyValueStore(this._storage);
  final FlutterSecureStorage _storage;

  @override
  Future<void> write({required String key, required String? value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);
}

/// Wraps flutter_secure_storage (named explicitly in PLAN.md §6) for the
/// access/refresh JWT pair. No token decoding lives here — that's
/// auth_state.dart's job.
class SecureTokenStore {
  SecureTokenStore(FlutterSecureStorage storage) : _store = _FlutterSecureKeyValueStore(storage);

  /// Test-only constructor — bypasses the platform channel entirely.
  SecureTokenStore.withStore(this._store);

  final KeyValueStore _store;

  static const _accessKey = 'autoserve_access_token';
  static const _refreshKey = 'autoserve_refresh_token';

  Future<void> save({required String access, required String refresh}) async {
    await _store.write(key: _accessKey, value: access);
    await _store.write(key: _refreshKey, value: refresh);
  }

  Future<void> saveAccess(String access) => _store.write(key: _accessKey, value: access);

  Future<String?> readAccess() => _store.read(key: _accessKey);

  Future<String?> readRefresh() => _store.read(key: _refreshKey);

  Future<void> clear() async {
    await _store.delete(key: _accessKey);
    await _store.delete(key: _refreshKey);
  }
}

final secureTokenStoreProvider = Provider<SecureTokenStore>((ref) {
  return SecureTokenStore(const FlutterSecureStorage());
});
