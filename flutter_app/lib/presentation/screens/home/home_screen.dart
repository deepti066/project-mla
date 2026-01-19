import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/post_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/post_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentPage = 1;
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pageKey = 'page_$_selectedTabIndex $_currentPage';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Media'),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Column(
                      children: [
                        Text(
                          'Feed',
                          style: TextStyle(
                            fontWeight: _selectedTabIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                            color: _selectedTabIndex == 0 ? const Color(0xFF6366F1) : Colors.grey,
                          ),
                        ),
                        if (_selectedTabIndex == 0)
                          Container(
                            height: 3,
                            margin: const EdgeInsets.only(top: 8),
                            color: const Color(0xFF6366F1),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    child: Column(
                      children: [
                        Text(
                          'Following',
                          style: TextStyle(
                            fontWeight: _selectedTabIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                            color: _selectedTabIndex == 1 ? const Color(0xFF6366F1) : Colors.grey,
                          ),
                        ),
                        if (_selectedTabIndex == 1)
                          Container(
                            height: 3,
                            margin: const EdgeInsets.only(top: 8),
                            color: const Color(0xFF6366F1),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Posts Feed
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildPublicFeed()
                : _buildFollowingFeed(),
          ),
        ],
      ),
      floatingActionButton: ref.watch(authStateProvider).user?.isAdmin ?? false
          ? FloatingActionButton(
              onPressed: () => context.go('/create-post'),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) {
            context.go('/search');
          } else if (index == 2) {
            context.go('/profile');
          }
        },
      ),
    );
  }

  Widget _buildPublicFeed() {
    final postsAsync = ref.watch(postsProvider(_currentPage));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(postsProvider);
      },
      child: postsAsync.when(
        data: (posts) {
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildFollowingFeed() {
    final feedAsync = ref.watch(feedProvider(_currentPage));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(feedProvider);
      },
      child: feedAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No posts from following',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
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
