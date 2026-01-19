import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _baseUrl = 'http://localhost:8000';
  static const String _apiVersion = 'api';

  static String get baseUrl => _baseUrl;
  static String get apiBaseUrl => '$_baseUrl/$_apiVersion';

  // Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String posts = '/posts';
  static const String feed = '/posts/feed';
  static const String comments = '/comments';
  static const String users = '/user';
  static const String updateFcmToken = '/update-fcm-token';

  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Debug
  static bool get isDebugMode => kDebugMode;
}
