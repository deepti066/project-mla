import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/post/create_post_screen.dart';
import '../../presentation/screens/post/post_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../data/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // helps during development
    redirect: (context, state) {
      final authState = ref.read(authStateProvider); // read, not watch!
      final isLoggedIn = authState.isAuthenticated;

      // If user is on login/register and becomes logged in → go home
      if (state.matchedLocation == '/login' || state.matchedLocation == '/register') {
        return isLoggedIn ? '/home' : null;
      }

      // If not logged in and trying to access protected route → go login
      if (!isLoggedIn && state.matchedLocation != '/' && state.matchedLocation != '/login' && state.matchedLocation != '/register') {
        return '/login';
      }

      // Allow splash to proceed (it will call initialize)
      if (state.matchedLocation == '/') {
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create-post',
        redirect: (context, state) {
          final authState = ref.read(authStateProvider);
          final isAdmin = authState.isAuthenticated && (authState.user?.isAdmin ?? false);

          if (!isAdmin) {
            return '/home';
          }
          return null;
        },
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final postId = state.pathParameters['id'] ?? '';
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
  ref.listen<AuthState>(authStateProvider, (previous, next) {
    if (previous?.isAuthenticated != next.isAuthenticated) {
      router.refresh(); // ← triggers redirect check without rebuilding router
    }
  });

  return router;

});
