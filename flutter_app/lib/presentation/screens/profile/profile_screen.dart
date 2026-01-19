import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  final String? userId;

  const ProfileScreen({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = userId != null
        ? ref.watch(userProfileProvider(int.parse(userId!)))
        : ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (userId == null)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.go('/edit-profile'),
            ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.avatar != null
                            ? NetworkImage(user.avatar!)
                            : null,
                        child: user.avatar == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (user.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(Icons.verified, size: 16, color: Colors.blue),
                        ),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(user.bio!),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatCard(label: 'Posts', value: '0'),
                      _StatCard(label: 'Followers', value: '0'),
                      _StatCard(label: 'Following', value: '0'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
