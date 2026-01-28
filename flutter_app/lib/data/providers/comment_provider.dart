import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment_model.dart';
import 'http_provider.dart';

// Comments Provider
final commentsProvider = FutureProvider.family<List<Comment>, int>((ref, postId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getComments(postId, 1);
    final data = response.data['data'] as List;
    return data.map((json) => Comment.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    throw Exception('Failed to fetch comments: $e');
  }
});

extension on Map<String, dynamic> {
  get data => null;
}

// Add Comment Provider
final addCommentProvider = FutureProvider.family<Comment, (int, String, int?)>(
  (ref, params) async {
    final (postId, body, parentCommentId) = params;
    final apiService = ref.watch(apiServiceProvider);
    try {
      final response = await apiService.createComment(postId, {
        'body': body,
        if (parentCommentId != null) 'parent_comment_id': parentCommentId,
      });
      ref.invalidate(commentsProvider(postId));
      return Comment.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  },
);

// Update Comment Provider
final updateCommentProvider = FutureProvider.family<Comment, (int, String)>(
  (ref, params) async {
    final (commentId, body) = params;
    final apiService = ref.watch(apiServiceProvider);
    try {
      final response = await apiService.updateComment(commentId, {
        'body': body,
      });
      return Comment.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  },
);

// Delete Comment Provider
final deleteCommentProvider = FutureProvider.family<bool, int>((ref, commentId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    await apiService.deleteComment(commentId);
    return true;
  } catch (e) {
    throw Exception('Failed to delete comment: $e');
  }
});
