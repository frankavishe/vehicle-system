import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/secure_token_store.dart';
import 'api_config.dart';

/// dio's closest analog to web/'s two-tier client: a single interceptor
/// attaches the Bearer token to every request and retries exactly once
/// on a 401 after a token refresh — no caller needs its own
/// refresh-on-401 logic (PLAN §6's "attach Authorization: Bearer on API
/// calls").
class DioClient {
  /// `httpClientAdapter` is exposed purely for tests — production code
  /// never passes it, so both `dio` and the refresh-only `_refreshDio`
  /// fall back to dio's real platform adapter.
  DioClient(this._tokenStore, {HttpClientAdapter? httpClientAdapter}) {
    dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl, connectTimeout: const Duration(seconds: 15)));
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );

    // A second, interceptor-free Dio dedicated to the refresh call itself
    // — reused across every refresh rather than constructed fresh each
    // time, and critically must never go through `dio`'s own interceptor
    // (a failed refresh would otherwise try to refresh itself).
    _refreshDio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

    if (httpClientAdapter != null) {
      dio.httpClientAdapter = httpClientAdapter;
      _refreshDio.httpClientAdapter = httpClientAdapter;
    }
  }

  final SecureTokenStore _tokenStore;
  late final Dio dio;
  late final Dio _refreshDio;

  // Serializes concurrent refresh attempts so a burst of 401s doesn't
  // fire the refresh endpoint multiple times in parallel.
  Future<String?>? _refreshing;

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final access = await _tokenStore.readAccess();
    if (access != null) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    handler.next(options);
  }

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    final response = error.response;
    final alreadyRetried = error.requestOptions.extra['retried'] == true;

    if (response?.statusCode != 401 || alreadyRetried) {
      handler.next(error);
      return;
    }

    final newAccess = await _refreshAccessToken();
    if (newAccess == null) {
      await _tokenStore.clear();
      handler.next(error);
      return;
    }

    final retryOptions = error.requestOptions
      ..headers['Authorization'] = 'Bearer $newAccess'
      ..extra['retried'] = true;

    try {
      final retryResponse = await dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshAccessToken() {
    // Single in-flight refresh shared by every 401 that arrives while one
    // is already running.
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<String?> _doRefresh() async {
    final refresh = await _tokenStore.readRefresh();
    if (refresh == null) return null;

    try {
      final response = await _refreshDio.post('/auth/refresh', data: {'refresh': refresh});
      final newAccess = response.data['access'] as String;
      await _tokenStore.saveAccess(newAccess);
      return newAccess;
    } on DioException {
      return null;
    }
  }
}

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.watch(secureTokenStoreProvider));
});

final dioProvider = Provider<Dio>((ref) => ref.watch(dioClientProvider).dio);
