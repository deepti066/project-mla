import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart'; // for current user if needed
import '../../../data/providers/http_provider.dart';
import '../../../data/services/api_service.dart'; // your ApiService

// Providers (add these to your providers file or here temporarily)
final currentUserProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>(
      (ref) => UserNotifier(ref),
);

final userProfileProvider = StateNotifierProvider.family<UserNotifier, AsyncValue<User?>, int>(
      (ref, userId) => UserNotifier(ref)..load(userId: userId),
);

// Notifier class
class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;

  UserNotifier(this.ref) : super(const AsyncValue.loading());

  Future<void> load({int? userId}) async {
    state = const AsyncValue.loading();
    try {
      final api = ref.read(apiServiceProvider);
      Map<String, dynamic> data;

      if (userId == null) {
        data = await api.getCurrentUser();
      } else {
        data = await api.getUser(userId);
      }

      final user = User.fromJson(data);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId; // null = current user, string = other user

  const ProfileScreen({
    super.key,
    this.userId,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    if (widget.userId == null) {
      ref.read(currentUserProvider.notifier).load();
    } else {
      final parsedId = int.tryParse(widget.userId!);
      if (parsedId != null) {
        ref.read(userProfileProvider(parsedId).notifier).load(userId: parsedId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = widget.userId == null;

    final userAsync = isCurrentUser
        ? ref.watch(currentUserProvider)
        : ref.watch(userProfileProvider(int.tryParse(widget.userId!) ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? 'My Profile' : 'Profile'),
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.go('/edit-profile'),
            ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          final stats = user.stats ?? {};
          final postsCount = stats['posts_count'] ?? 0;
          final followersCount = stats['followers_count'] ?? 0;
          final followingCount = stats['following_count'] ?? 0;

          return RefreshIndicator(
            onRefresh: () async {
              if (isCurrentUser) {
                await ref.read(currentUserProvider.notifier).load();
              } else {
                final parsedId = int.tryParse(widget.userId!);
                if (parsedId != null) {
                  await ref.read(userProfileProvider(parsedId).notifier).load(userId: parsedId);
                }
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                    child: user.avatar == null ? const Icon(Icons.person, size: 60) : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name ?? 'User',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (user.isVerified == true)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.blue, size: 20),
                          SizedBox(width: 4),
                          Text('Verified', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Text(
                        user.bio!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatCard('Posts', postsCount),
                      _StatCard('Followers', followersCount),
                      _StatCard('Following', followingCount),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (!isCurrentUser)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          user.isFollowing == true ? Icons.check : Icons.person_add,
                          color: Colors.white,
                        ),
                        label: Text(
                          user.isFollowing == true ? 'Following' : 'Follow',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: user.isFollowing == true ? Colors.grey : const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final api = ref.read(apiServiceProvider);
                          try {
                            if (user.isFollowing == true) {
                              await api.unfollowUser(user.id!);
                            } else {
                              await api.followUser(user.id!);
                            }
                            // Refresh profile
                            final parsedId = int.tryParse(widget.userId!);
                            if (parsedId != null) {
                              ref.refresh(userProfileProvider(parsedId));
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Action failed: $e')),
                            );
                          }
                        },
                      ),
                    ),
                  const SizedBox(height: 40),
                  // You can add more sections here later (posts list, etc.)
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading profile: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (isCurrentUser) {
                    ref.read(currentUserProvider.notifier).load();
                  } else {
                    final parsedId = int.tryParse(widget.userId!);
                    if (parsedId != null) {
                      ref.read(userProfileProvider(parsedId).notifier).load();
                    }
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;

  const _StatCard(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
