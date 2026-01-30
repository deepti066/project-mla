import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // ← added for Scaffold etc.
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

import '../../data/providers/auth_provider.dart'; // assuming this exposes authStateProvider

// ────────────────────────────────────────────────
// Shell widget with BottomNavigationBar
// ────────────────────────────────────────────────
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Riverpod provider for the router
// ────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode, // better than hard true

    // ── Redirect logic ───────────────────────────────────────
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.isAuthenticated;

      // If on login/register and now logged in → go home
      if (state.matchedLocation == '/login' || state.matchedLocation == '/register') {
        return isLoggedIn ? '/home' : null;
      }

      // If not logged in and trying to access protected route → go login
      if (!isLoggedIn &&
          state.matchedLocation != '/' &&
          state.matchedLocation != '/login' &&
          state.matchedLocation != '/register') {
        return '/login';
      }

      // Splash can proceed freely
      if (state.matchedLocation == '/') {
        return null;
      }

      // Optional: admin-only check for create-post
      if (state.matchedLocation == '/create-post') {
        final isAdmin = authState.isAuthenticated && (authState.user?.isAdmin ?? false);
        if (!isAdmin) return '/home';
      }

      return null;
    },

    // ── Routes ───────────────────────────────────────────────
    routes: [
      // Public / initial
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

      // ── Shell with bottom nav ────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Search tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),

          // Profile tab (own profile)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Routes OUTSIDE the bottom nav shell ─────────────────
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final postId = state.pathParameters['id'] ?? '0';
          return PostDetailScreen(postId: postId);
        },
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
    ],
  );

  // Listen to auth changes → refresh router to re-evaluate redirect
  ref.listen<AuthState>(authStateProvider, (previous, next) {
    if (previous?.isAuthenticated != next.isAuthenticated) {
      router.refresh();
    }
  });

  return router;
});
