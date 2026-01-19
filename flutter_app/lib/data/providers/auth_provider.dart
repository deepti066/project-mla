import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import 'http_provider.dart';

// Auth State
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  bool get isError => status == AuthStatus.error;
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState());

  Future<void> initialize() async {
    final token = StorageService.getToken();
    if (token != null) {
      final userData = StorageService.getUser();
      if (userData != null) {
        try {
          final user = User.fromJson(userData);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        } catch (e) {
          await logout();
        }
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.login({
        'email': email,
        'password': password,
      });

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      await StorageService.saveToken(token);
      await StorageService.saveUser(userData);

      final user = User.fromJson(userData);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
    return false;
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
    String role,
  ) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.register({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
      });

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      await StorageService.saveToken(token);
      await StorageService.saveUser(userData);

      final user = User.fromJson(userData);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
    return false;
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await StorageService.logout();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateUser(User user) async {
    await StorageService.saveUser(user.toJson());
    state = state.copyWith(user: user);
  }
}

// Auth Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// Auth Initialization Provider
final initializeAuthProvider = FutureProvider<void>((ref) async {
  final authNotifier = ref.read(authStateProvider.notifier);
  await authNotifier.initialize();
});
