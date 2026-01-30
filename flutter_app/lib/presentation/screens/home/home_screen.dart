import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/post_model.dart';
import '../../../data/providers/post_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/post_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _selectedTabIndex = 0; // 0 = Feed (all), 1 = Following

  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_listenForScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_listenForScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _listenForScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        !_hasReachedEnd) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingMore || _hasReachedEnd) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    final provider = _selectedTabIndex == 0 ? postsProvider : feedProvider;
    final nextPageAsync = ref.read(provider(_currentPage));

    // Wait for the new page to load
    await nextPageAsync.future.catchError((_) {});

    // Check if we got empty results → assume end of list
    final newPosts = ref.read(provider(_currentPage));
    if (newPosts is AsyncData<List<dynamic>> && newPosts.value!.isEmpty) {
      _hasReachedEnd = true;
    }

    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    _hasReachedEnd = false;
    ref.invalidate(postsProvider);
    ref.invalidate(feedProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(authStateProvider).user?.isAdmin ?? false;
    print('Is Admin in build? $isAdmin');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              // TODO: Notifications screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                _buildTabButton('For You', 0),
                const SizedBox(width: 16),
                _buildTabButton('Following', 1),
              ],
            ),
          ),
          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _selectedTabIndex == 0
                  ? _buildFeedList(postsProvider)
                  : _buildFeedList(feedProvider),
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
        onPressed: () => context.go('/create-post'),
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Post'),
      )
          : null,
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            _currentPage = 1;
            _hasReachedEnd = false;
          });

          // Delay jump until next frame (when ListView is rebuilt)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(0);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1).withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF6366F1) : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedList(FutureProviderFamily<List<Post>, int> provider) {
    final pages = List.generate(_currentPage, (i) => i + 1);
    final asyncValues = pages.map((p) => ref.watch(provider(p))).toList();

    List<Post> allPosts = [];
    bool isLoading = false;
    Object? error;

    for (final asyncValue in asyncValues) {
      asyncValue.whenData((posts) => allPosts.addAll(posts));
      if (asyncValue.isLoading && allPosts.isEmpty) isLoading = true;
      if (asyncValue.hasError) error = asyncValue.error;
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Something went wrong', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _onRefresh,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (isLoading && allPosts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _selectedTabIndex == 0 ? 'No posts yet' : 'No posts from people you follow',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTabIndex == 0 ? 'Check back later' : 'Follow some users to see their posts',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: allPosts.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == allPosts.length) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return PostCard(post: allPosts[index]);
      },
    );
  }
}

extension on AsyncValue<List<Post>> {
  get future => null;
}
