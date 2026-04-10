import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../storage/secure_storage.dart';

class ApiClient extends GetxService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/v1';
  // Use 10.0.2.2 for Android emulator → maps to host localhost
  // Change to your server IP for physical devices

  late final Dio _dio;

  Dio get dio => _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(LogInterceptor(
      request: true,
      responseBody: true,
      error: true,
      logPrint: (o) => debugPrint('[API] $o'),
    ));
  }
}

// ─── Auth interceptor: attaches Bearer token + handles 401 refresh ───────────

class _AuthInterceptor extends Interceptor {
  SecureStorage get _store => Get.find<SecureStorage>();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _store.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        // Retry the original request with the new token
        final token = await _store.accessToken;
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $token';
        try {
          final dio = Get.find<ApiClient>().dio;
          final response = await dio.fetch(opts);
          return handler.resolve(response);
        } catch (_) {}
      }
      // Refresh failed → log out
      await _store.clearSession();
      Get.offAllNamed('/login');
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    try {
      final refresh = await _store.refreshToken;
      if (refresh == null) return false;
      final dio = Dio(BaseOptions(baseUrl: Get.find<ApiClient>().dio.options.baseUrl));
      final res = await dio.post('/auth/token/refresh/', data: {'refresh': refresh});
      await _store.updateAccessToken(res.data['access']);
      return true;
    } catch (_) {
      return false;
    }
  }
}
