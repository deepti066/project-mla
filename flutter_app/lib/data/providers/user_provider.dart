import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'http_provider.dart';

// User Profile Provider
final userProfileProvider = FutureProvider.family<User, int>((ref, userId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getUser(userId);
    return User.fromJson(response['data'] as Map<String, dynamic>);
  } catch (e) {
    throw Exception('Failed to fetch user profile: $e');
  }
});

// Current User Provider
final currentUserProvider = FutureProvider<User>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getCurrentUser();
    return User.fromJson(response['data'] as Map<String, dynamic>);
  } catch (e) {
    throw Exception('Failed to fetch current user: $e');
  }
});

// Search Users Provider
final searchUsersProvider = FutureProvider.family<List<User>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.searchUsers(query);
    final data = response['data'] as List;
    return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    throw Exception('Failed to search users: $e');
  }
});

// Follow User Provider
final followUserProvider = FutureProvider.family<bool, int>((ref, userId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    await apiService.followUser(userId);
    ref.invalidate(userProfileProvider(userId));
    return true;
  } catch (e) {
    throw Exception('Failed to follow user: $e');
  }
});

// Unfollow User Provider
final unfollowUserProvider = FutureProvider.family<bool, int>((ref, userId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    await apiService.unfollowUser(userId);
    ref.invalidate(userProfileProvider(userId));
    return true;
  } catch (e) {
    throw Exception('Failed to unfollow user: $e');
  }
});

// Followers Provider
final followersProvider = FutureProvider.family<List<User>, int>((ref, userId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getFollowers(userId, 1);
    final data = response['data'] as List;
    return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    throw Exception('Failed to fetch followers: $e');
  }
});

// Following Provider
final followingProvider = FutureProvider.family<List<User>, int>((ref, userId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getFollowing(userId, 1);
    final data = response['data'] as List;
    return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    throw Exception('Failed to fetch following: $e');
  }
});
