import 'package:hive/hive.dart';

class StorageService {
  static const String authBoxName = 'auth_box';
  static const String userBoxName = 'user_box';
  static const String tokensBoxName = 'tokens_box';

  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String refreshTokenKey = 'refresh_token';

  static Future<void> init() async {
    await Hive.openBox(authBoxName);
    await Hive.openBox(userBoxName);
    await Hive.openBox(tokensBoxName);
  }

  // Auth Token Methods
  static Future<void> saveToken(String token) async {
    final box = Hive.box(authBoxName);
    await box.put(tokenKey, token);
  }

  static String? getToken() {
    final box = Hive.box(authBoxName);
    return box.get(tokenKey) as String?;
  }

  static Future<void> clearToken() async {
    final box = Hive.box(authBoxName);
    await box.delete(tokenKey);
  }

  // Refresh Token Methods
  static Future<void> saveRefreshToken(String token) async {
    final box = Hive.box(tokensBoxName);
    await box.put(refreshTokenKey, token);
  }

  static String? getRefreshToken() {
    final box = Hive.box(tokensBoxName);
    return box.get(refreshTokenKey) as String?;
  }

  // User Data Methods
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final box = Hive.box(userBoxName);
    await box.put(userKey, userData);
  }

  static Map<String, dynamic>? getUser() {
    final box = Hive.box(userBoxName);
    final data = box.get(userKey);
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  static Future<void> clearUser() async {
    final box = Hive.box(userBoxName);
    await box.delete(userKey);
  }

  // Logout - Clear everything
  static Future<void> logout() async {
    await clearToken();
    await clearUser();
    await Hive.box(tokensBoxName).clear();
  }
}
