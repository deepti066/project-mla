import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import 'http_provider.dart';

// Posts Feed Provider
final postsProvider = FutureProvider.family<List<Post>, int>((ref, page) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getPosts(page, 15);

    // ── ADD THESE PRINTS ───────────────────────────────────────
    // print('=== RAW RESPONSE for page $page ===');
    // print(response);                          // full map
    // print('Keys in response: ${response.keys}');
    // if (response.containsKey('data')) {
    //   print('data type: ${response['data'].runtimeType}');
    //   print('data length: ${(response['data'] as List?)?.length ?? "null"}');
    // }
    // ───────────────────────────────────────────────────────────

    final data = response['data'] as List? ?? [];
    return data.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e, stack) {
    print('ERROR fetching posts: $e');
    print(stack);
    rethrow;
  }
});

// User Feed Provider (Personalized)
final feedProvider = FutureProvider.family<List<Post>, int>((ref, page) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getFeed(page, 15);

    // ────────────────────────────── ADD THESE LINES ──────────────────────────────
    // print('FEED RESPONSE FULL: $response');
    // print('RESPONSE TYPE: ${response.runtimeType}');
    // print('HAS "data" KEY? ${response.containsKey('data')}');
    // if (response.containsKey('data')) {
    //   print('"data" VALUE TYPE: ${response['data'].runtimeType}');
    //   print('"data" LENGTH: ${(response['data'] as List?)?.length ?? "NOT A LIST"}');
    // }
    // print('ALL KEYS IN RESPONSE: ${response.keys.toList()}');
    // ──────────────────────────────────────────────────────────────────────────────

    final data = response['data'] as List? ?? [];
    return data.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    print('FEED ERROR: $e');
    rethrow;
  }
});

// Single Post Provider
final postProvider = FutureProvider.family<Post, int>((ref, postId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getPost(postId);
    return Post.fromJson(response['data'] as Map<String, dynamic>);
  } catch (e) {
    throw Exception('Failed to fetch post: $e');
  }
});

// Like Post Provider
final likePostProvider = FutureProvider.family<bool, int>((ref, postId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    await apiService.likePost(postId);
    // Invalidate the post provider to refresh data
    ref.invalidate(postProvider(postId));
    ref.invalidate(feedProvider);
    return true;
  } catch (e) {
    throw Exception('Failed to like post: $e');
  }
});

// Unlike Post Provider
final unlikePostProvider = FutureProvider.family<bool, int>((ref, postId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    await apiService.unlikePost(postId);
    // Invalidate the post provider to refresh data
    ref.invalidate(postProvider(postId));
    ref.invalidate(feedProvider);
    return true;
  } catch (e) {
    throw Exception('Failed to unlike post: $e');
  }
});

// Share Post Provider
final sharePostProvider = FutureProvider.family<bool, (int, String?)>((ref, params) async {
  final (postId, channel) = params;
  final apiService = ref.watch(apiServiceProvider);
  try {
    await apiService.sharePost(postId, {
      if (channel != null) 'shared_to': channel,
    });
    ref.invalidate(postProvider(postId));
    return true;
  } catch (e) {
    throw Exception('Failed to share post: $e');
  }
});

// Likes List Provider
final likesProvider = FutureProvider.family<List<dynamic>, int>((ref, postId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getLikes(postId, 1);
    final data = response['data'] as List;
    return data;
  } catch (e) {
    throw Exception('Failed to fetch likes: $e');
  }
});
