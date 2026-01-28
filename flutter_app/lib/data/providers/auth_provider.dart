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
  error, success,
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
    // ⛔ DO NOTHING if already authenticated
    if (state.status == AuthStatus.authenticated) return;

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
          return;
        } catch (_) {
          await logout();
        }
      }
    }

    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.login({'email': email, 'password': password});

      // print('Raw login response: $response');

      final token = response['access_token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('No access token received');
      }

      await StorageService.saveToken(token);

      // Now fetch full user with the new token
      final userResponse = await apiService.getCurrentUser();
      // print('User profile response: $userResponse');

      final user = User.fromJson(userResponse);

      await StorageService.saveUser(user.toJson());

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );

      // print('Login successful - full user loaded');
      return true;
    } catch (e) {
      String friendlyMessage = 'Something went wrong. Please try again.';

      if (e.toString().contains('401') || e.toString().contains('credentials') || e.toString().contains('invalid')) {
        friendlyMessage = 'Email or password is incorrect. Please try again.';
      } else if (e.toString().contains('network') || e.toString().contains('timeout')) {
        friendlyMessage = 'No internet connection. Please check your connection.';
      }

      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: friendlyMessage,
      );

      print('Login error (friendly): $friendlyMessage');
      return false;
    }
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

      // If you reach here → success (no auto-login)
      print('Raw register response: $response');
      return true;

    } catch (e) {
      String friendlyMessage = 'Something went wrong. Please try again later.';

      // Try to detect common backend errors
      if (e.toString().contains('422') || e.toString().contains('email') || e.toString().contains('unique')) {
        friendlyMessage = 'This email is already registered. Please use a different email.';
      } else if (e.toString().contains('password') || e.toString().contains('confirmation')) {
        friendlyMessage = 'Passwords do not match or are too weak. Please check.';
      } else if (e.toString().contains('400') || e.toString().contains('validation')) {
        friendlyMessage = 'Please fill all fields correctly.';
      } else if (e.toString().contains('network') || e.toString().contains('timeout')) {
        friendlyMessage = 'Network error. Please check your internet connection.';
      }

      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: friendlyMessage,
      );

      print('Register error (friendly): $friendlyMessage');
      print('Technical error: $e');

      return false;
    }
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

  void updateUser(User? updatedUser) {
    if (updatedUser == null) return;

    state = state.copyWith(user: updatedUser);
    // Optional: save to storage again
    StorageService.saveUser(updatedUser.toJson());
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
