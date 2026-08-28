import 'package:dio/dio.dart';
import 'package:pmdap_operations/core/config.dart';
import 'package:pmdap_operations/core/models.dart';
import 'package:pmdap_operations/core/token_store.dart';

class ApiClient {
  ApiClient({required TokenStore tokenStore, Dio? dio})
    : _tokenStore = tokenStore,
      dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
              headers: const {'Accept': 'application/json'},
            ),
          ) {
    this.dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final access = await _tokenStore.readAccess();
          if (access != null && access.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $access';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401 &&
              error.requestOptions.headers.containsKey('Authorization')) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStore _tokenStore;
  final Dio dio;
  void Function()? onUnauthorized;

  ApiFailure failure(DioException error) {
    final payload = error.response?.data;
    final body = payload is Map<String, dynamic> ? payload['error'] : null;
    final data = body is Map<String, dynamic>
        ? body
        : const <String, dynamic>{};
    final details = data['details'] is Map<String, dynamic>
        ? data['details'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return ApiFailure(
      code: data['code']?.toString() ?? 'network_error',
      message: data['message']?.toString() ?? 'Request failed.',
      statusCode: error.response?.statusCode,
      details: details,
    );
  }
}
