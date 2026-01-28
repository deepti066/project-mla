import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'http_provider.dart';

// Fetch Shares Provider
final sharesProvider = FutureProvider.family<List<dynamic>, int>((ref, postId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getShares(postId);
    final data = response['data'] as List;
    return data;
  } catch (e) {
    throw Exception('Failed to fetch shares: $e');
  }
});

// Delete Share Provider
final deleteShareProvider = FutureProvider.family<bool, int>((ref, shareId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    await apiService.deleteShare(shareId);
    // Note: We might want to invalidate the post or user feed if we knew which one it belonged to,
    // but typically deleting a share just removes it from the list. 
    // If we have a provider for the specific list this share came from, we could invalidate it.
    // For now, the caller is responsible for UI updates or invalidation.
    return true;
  } catch (e) {
    throw Exception('Failed to delete share: $e');
  }
});
