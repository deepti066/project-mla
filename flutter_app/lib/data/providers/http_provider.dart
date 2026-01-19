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
  ));

  // Add interceptors
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle token refresh or logout
          StorageService.logout();
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
