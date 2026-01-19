import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/http_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    try {
      // Initialize auth from stored data
      await ref.read(authStateProvider.notifier).initialize();
      
      // Give UI time to update
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }

    if (!mounted) return;

    // Wait for splash screen display
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is authenticated
    final authState = ref.read(authStateProvider);
    debugPrint('Navigating... Auth status: ${authState.status}');
    
    if (authState.isAuthenticated) {
      if (mounted) context.go('/home');
    } else {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.share_rounded, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Social Media',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with everyone',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
