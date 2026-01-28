import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// HTTP Client Provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.apiBaseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
    headers: {
      'Accept': 'application/json',
    },
  ));

  // Add interceptors
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Force Accept header on EVERY request (extra safety)
        options.headers['Accept'] = 'application/json';

        // Your existing token logic
        final token = StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Optional: debug in development
        if (kDebugMode) {
          print('→ REQUEST: ${options.method} ${options.uri}');
          print('Headers: ${options.headers}');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('← RESPONSE: ${response.statusCode} ${response.realUri}');
        }
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        if (kDebugMode && error.response != null) {
          print('Dio Error: ${error.type} - Status: ${error.response?.statusCode}');
          print('Location header (if 302): ${error.response?.headers['location']}');
          print('Error body: ${error.response?.data}');
        }

        // Your 401 handling
        if (error.response?.statusCode == 401) {
          StorageService.logout();
          // Optional: add navigation or refresh logic here if needed
        }

        return handler.next(error);
      },
    ),
  );

  return dio;
});

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio, baseUrl: ApiConfig.apiBaseUrl);
});
