import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/dio_client.dart';
import 'package:mobile/core/auth/secure_token_store.dart';

/// A minimal in-memory KeyValueStore — same contract SecureTokenStore
/// uses against flutter_secure_storage in production, swapped here to
/// avoid a platform channel under plain `flutter test`.
class _FakeKeyValueStore implements KeyValueStore {
  final _values = <String, String>{};

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  @override
  Future<String?> read({required String key}) async => _values[key];

  @override
  Future<void> delete({required String key}) async => _values.remove(key);
}

/// Scripted responses keyed by request path — good enough for this one
/// interceptor's control flow without pulling in an HTTP-mocking package.
class _ScriptedAdapter implements HttpClientAdapter {
  final calls = <RequestOptions>[];
  final Map<String, List<int Function(RequestOptions)>> _scripts = {};

  /// Queues a status-code responder for `path`, consumed in call order.
  void queue(String path, int Function(RequestOptions options) responder) {
    _scripts.putIfAbsent(path, () => []).add(responder);
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    final queued = _scripts[options.path];
    if (queued == null || queued.isEmpty) {
      throw StateError('No scripted response for ${options.path}');
    }
    final statusCode = queued.removeAt(0)(options);

    final body = switch (options.path) {
      '/auth/refresh' => jsonEncode({'access': 'new-access-token'}),
      _ => statusCode == 200 ? jsonEncode({'ok': true}) : jsonEncode({'detail': 'Unauthorized'}),
    };

    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('DioClient 401-retry interceptor', () {
    late _FakeKeyValueStore keyValueStore;
    late SecureTokenStore tokenStore;
    late _ScriptedAdapter adapter;
    late DioClient client;

    setUp(() async {
      keyValueStore = _FakeKeyValueStore();
      tokenStore = SecureTokenStore.withStore(keyValueStore);
      await tokenStore.save(access: 'old-access-token', refresh: 'a-refresh-token');
      adapter = _ScriptedAdapter();
      client = DioClient(tokenStore, httpClientAdapter: adapter);
    });

    test('attaches the current access token as a Bearer header', () async {
      adapter.queue('/whoami', (_) => 200);
      await client.dio.get('/whoami');

      expect(adapter.calls.single.headers['Authorization'], 'Bearer old-access-token');
    });

    test('refreshes once on 401 and retries with the new token, succeeding', () async {
      adapter.queue('/whoami', (_) => 401);
      adapter.queue('/auth/refresh', (_) => 200);
      adapter.queue('/whoami', (_) => 200);

      final response = await client.dio.get('/whoami');

      expect(response.statusCode, 200);
      // 2 calls to /whoami (original + retry) + 1 refresh call.
      expect(adapter.calls.map((c) => c.path), ['/whoami', '/auth/refresh', '/whoami']);
      // The retried request carries the refreshed token.
      expect(adapter.calls.last.headers['Authorization'], 'Bearer new-access-token');
      expect(await tokenStore.readAccess(), 'new-access-token');
    });

    test('clears tokens and does not loop when the refresh call itself fails', () async {
      adapter.queue('/whoami', (_) => 401);
      adapter.queue('/auth/refresh', (_) => 401);

      await expectLater(client.dio.get('/whoami'), throwsA(isA<DioException>()));

      // Exactly one refresh attempt — no retry-of-a-retry loop.
      expect(adapter.calls.map((c) => c.path), ['/whoami', '/auth/refresh']);
      expect(await tokenStore.readAccess(), isNull);
    });

    test('does not retry a request that has already been retried once', () async {
      adapter.queue('/whoami', (_) => 401);
      adapter.queue('/auth/refresh', (_) => 200);
      adapter.queue('/whoami', (_) => 401); // still 401 even after refresh

      await expectLater(client.dio.get('/whoami'), throwsA(isA<DioException>()));

      // No second refresh attempt triggered by the retried request's own 401.
      expect(adapter.calls.map((c) => c.path), ['/whoami', '/auth/refresh', '/whoami']);
    });
  });
}
