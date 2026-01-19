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
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;

      if (state.matchedLocation == '/login' || state.matchedLocation == '/register') {
        return isLoggedIn ? '/home' : null;
      }

      if (!isLoggedIn && state.matchedLocation != '/') {
        return '/login';
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
});
