# 📱 Flutter Integration Guide

## Overview

This guide provides comprehensive instructions for integrating your Laravel backend API with a Flutter mobile application.

---

## 1. Project Setup

### 1.1 Create Flutter Project

```bash
flutter create social_media_app
cd social_media_app
```

### 1.2 Required Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP & API
  http: ^1.1.0
  dio: ^5.3.0  # (Recommended over http for better features)
  
  # State Management
  riverpod: ^2.4.0
  riverpod_generator: ^2.3.0
  
  # Storage & Security
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.0
  
  # Image & Media
  image_picker: ^1.0.0
  video_player: ^2.7.0
  cached_network_image: ^3.3.0
  photo_view: ^0.14.0
  
  # UI Components
  flutter_staggered_grid_view: ^0.7.0
  pull_to_refresh: ^2.0.0
  smooth_page_indicator: ^1.0.0
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_messaging: ^14.6.0
  
  # Date/Time
  intl: ^0.19.0
  
  # JSON Serialization
  json_serializable: ^6.7.0
  json_annotation: ^4.8.0

dev_dependencies:
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  json_serializable: ^6.7.0
```

Run:
```bash
flutter pub get
flutter pub run build_runner build
```

---

## 2. API Configuration

### 2.1 Environment Setup

Create `lib/config/env.dart`:

```dart
class Environment {
  static const String baseUrl = 'http://192.168.1.100:8000/api';
  // For production: 'https://api.yourdomain.com/api'
  
  static const String socketUrl = 'ws://192.168.1.100:8000';
  // For WebSocket connections (future enhancement)
  
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
}
```

### 2.2 HTTP Client Setup (Using Dio)

Create `lib/services/api_client.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env.dart';

class ApiClient {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Environment.baseUrl,
        connectTimeout: Duration(seconds: Environment.connectTimeoutSeconds),
        receiveTimeout: Duration(seconds: Environment.receiveTimeoutSeconds),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(_storage));
    _dio.interceptors.add(_LoggingInterceptor());
  }

  Dio get dio => _dio;

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - Token expired
    if (err.response?.statusCode == 401) {
      // Clear token and redirect to login
      await _storage.delete(key: 'access_token');
      // Navigation handled in main app
    }
    return handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('📤 REQUEST[${options.method}] => PATH: ${options.path}');
    print('Headers: ${options.headers}');
    print('Body: ${options.data}');
    return handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) {
    print('📥 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('Response: ${response.data}');
    return handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('Error: ${err.message}');
    return handler.next(err);
  }
}
```

---

## 3. Model Classes

### 3.1 User Model

Create `lib/models/user.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'avatar')
  final String? avatarUrl;
  final String? bio;
  final String role; // 'admin' or 'follower'
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_private')
  final bool isPrivate;
  final UserStats stats;
  @JsonKey(name: 'last_seen_at')
  final DateTime? lastSeenAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bio,
    required this.role,
    required this.isVerified,
    required this.isPrivate,
    required this.stats,
    this.lastSeenAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserStats {
  @JsonKey(name: 'posts_count')
  final int postsCount;
  @JsonKey(name: 'followers_count')
  final int followersCount;
  @JsonKey(name: 'following_count')
  final int followingCount;

  UserStats({
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}
```

### 3.2 Post Model

Create `lib/models/post.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final int id;
  final User user;
  final String caption;
  final List<PostMedia> media;
  final PostEngagement engagement;
  @JsonKey(name: 'is_liked')
  final bool isLiked;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.user,
    required this.caption,
    required this.media,
    required this.engagement,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class PostMedia {
  final int id;
  final String type; // 'image' or 'video'
  final String url;
  final String? thumbnail;

  PostMedia({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnail,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) => _$PostMediaFromJson(json);
  Map<String, dynamic> toJson() => _$PostMediaToJson(this);
}

@JsonSerializable()
class PostEngagement {
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  @JsonKey(name: 'shares_count')
  final int sharesCount;
  @JsonKey(name: 'views_count')
  final int viewsCount;

  PostEngagement({
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
  });

  factory PostEngagement.fromJson(Map<String, dynamic> json) => _$PostEngagementFromJson(json);
  Map<String, dynamic> toJson() => _$PostEngagementToJson(this);
}
```

### 3.3 Comment Model

Create `lib/models/comment.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final int id;
  final User user;
  final String body;
  final List<Comment> replies;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.user,
    required this.body,
    required this.replies,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
```

---

## 4. Repository Pattern

### 4.1 Auth Repository

Create `lib/repositories/auth_repository.dart`:

```dart
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role, // 'admin' or 'follower'
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      
      final token = response.data['access_token'];
      await _apiClient.setToken(token);
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final token = response.data['access_token'];
      await _apiClient.setToken(token);
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
  }

  Future<void> updateFcmToken(String token) async {
    try {
      await _apiClient.dio.post(
        '/update-fcm-token',
        data: {'fcm_token': token},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? 'An error occurred';
    }
    return error.message ?? 'Network error';
  }
}
```

### 4.2 Post Repository

Create `lib/repositories/post_repository.dart`:

```dart
import 'package:dio/dio.dart';
import '../models/post.dart';
import '../services/api_client.dart';

class PostRepository {
  final ApiClient _apiClient;

  PostRepository(this._apiClient);

  Future<List<Post>> getPosts({int page = 1, int perPage = 15}) async {
    try {
      final response = await _apiClient.dio.get(
        '/posts',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      
      final data = response.data['data'] as List;
      return data.map((json) => Post.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Post>> getFeed({int page = 1, int perPage = 15}) async {
    try {
      final response = await _apiClient.dio.get(
        '/posts/feed',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      
      final data = response.data['data'] as List;
      return data.map((json) => Post.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Post> getPost(int postId) async {
    try {
      final response = await _apiClient.dio.get('/posts/$postId');
      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Post> createPost({
    required String caption,
    required List<MultipartFile> mediaFiles,
  }) async {
    try {
      final formData = FormData.fromMap({
        'caption': caption,
        'media': mediaFiles,
      });

      final response = await _apiClient.dio.post(
        '/posts',
        data: formData,
      );

      return Post.fromJson(response.data['post']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> likePost(int postId) async {
    try {
      await _apiClient.dio.post('/posts/$postId/like');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> unlikePost(int postId) async {
    try {
      await _apiClient.dio.post('/posts/$postId/unlike');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> sharePost(int postId, {String? sharedTo}) async {
    try {
      await _apiClient.dio.post(
        '/posts/$postId/share',
        data: {'shared_to': sharedTo},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? 'An error occurred';
    }
    return error.message ?? 'Network error';
  }
}
```

### 4.3 Comment & User Repository

Create `lib/repositories/comment_repository.dart`:

```dart
import 'package:dio/dio.dart';
import '../models/comment.dart';
import '../services/api_client.dart';

class CommentRepository {
  final ApiClient _apiClient;

  CommentRepository(this._apiClient);

  Future<List<Comment>> getComments(int postId, {int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        '/posts/$postId/comments',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      
      final data = response.data['data'] as List;
      return data.map((json) => Comment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Comment> createComment(int postId, String body, {int? parentCommentId}) async {
    try {
      final response = await _apiClient.dio.post(
        '/posts/$postId/comments',
        data: {
          'body': body,
          'parent_comment_id': parentCommentId,
        },
      );

      return Comment.fromJson(response.data['comment']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateComment(int commentId, String body) async {
    try {
      await _apiClient.dio.put(
        '/comments/$commentId',
        data: {'body': body},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      await _apiClient.dio.delete('/comments/$commentId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? 'An error occurred';
    }
    return error.message ?? 'Network error';
  }
}
```

Create `lib/repositories/user_repository.dart`:

```dart
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/api_client.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get('/user/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getUser(int userId) async {
    try {
      final response = await _apiClient.dio.get('/user/$userId');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateProfile({
    String? name,
    String? bio,
    bool? isPrivate,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/user/profile',
        data: {
          if (name != null) 'name': name,
          if (bio != null) 'bio': bio,
          if (isPrivate != null) 'is_private': isPrivate,
        },
      );

      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> followUser(int userId) async {
    try {
      await _apiClient.dio.post('/user/$userId/follow');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> unfollowUser(int userId) async {
    try {
      await _apiClient.dio.post('/user/$userId/unfollow');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<User>> searchUsers(String query, {int page = 1}) async {
    try {
      final response = await _apiClient.dio.get(
        '/user/search',
        queryParameters: {'q': query, 'page': page, 'per_page': 15},
      );
      
      final data = response.data['data'] as List;
      return data.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? 'An error occurred';
    }
    return error.message ?? 'Network error';
  }
}
```

---

## 5. State Management (Riverpod)

### 5.1 Providers

Create `lib/providers/auth_provider.dart`:

```dart
import 'package:riverpod/riverpod.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../services/api_client.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final authRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<User?>>((ref) {
  return CurrentUserNotifier(ref.watch(authRepositoryProvider));
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  CurrentUserNotifier(this._authRepository) : super(const AsyncValue.loading());

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.login(email: email, password: password);
      // Fetch user data
      return null; // Implement user fetching
    });
  }

  Future<void> register(String name, String email, String password, String role) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      return null;
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _authRepository.logout();
    state = const AsyncValue.data(null);
  }
}
```

Create `lib/providers/post_provider.dart`:

```dart
import 'package:riverpod/riverpod.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';
import '../services/api_client.dart';

final postRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostRepository(apiClient);
});

final postsProvider = FutureProvider.autoDispose.family<List<Post>, int>((ref, page) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getPosts(page: page, perPage: 15);
});

final feedProvider = FutureProvider.autoDispose.family<List<Post>, int>((ref, page) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getFeed(page: page, perPage: 15);
});

final postDetailProvider = FutureProvider.autoDispose.family<Post, int>((ref, postId) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getPost(postId);
});
```

---

## 6. UI Implementation Example

### 6.1 Login Screen

Create `lib/screens/auth/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(currentUserProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
        // Navigate to home screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 6.2 Home Feed Screen

Create `lib/screens/home/feed_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/post_provider.dart';
import '../../models/post.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(feedProvider(_currentPage));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        elevation: 0,
      ),
      body: postsAsync.when(
        data: (posts) {
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return Center(child: Text('Error: $error'));
        },
      ),
    );
  }
}

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: post.user.avatarUrl != null
                      ? NetworkImage(post.user.avatarUrl!)
                      : null,
                  child: post.user.avatarUrl == null
                      ? Text(post.user.name[0])
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(post.createdAt.toString(), style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(post.caption),
          ),
          const SizedBox(height: 8),
          // Media
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: post.media.length,
              itemBuilder: (context, index) {
                final media = post.media[index];
                return Image.network(
                  media.url,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                );
              },
            ),
          ),
          // Engagement buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _EngagementButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${post.engagement.likesCount}',
                  onPressed: () {
                    // Handle like
                  },
                ),
                _EngagementButton(
                  icon: Icons.comment_outlined,
                  label: '${post.engagement.commentsCount}',
                  onPressed: () {
                    // Handle comment
                  },
                ),
                _EngagementButton(
                  icon: Icons.share_outlined,
                  label: '${post.engagement.sharesCount}',
                  onPressed: () {
                    // Handle share
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _EngagementButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
```

---

## 7. Firebase Push Notifications Setup

### 7.1 Initialize Firebase

Create `lib/services/firebase_service.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    
    // Request notification permission
    final settings = await FirebaseMessaging.instance.requestPermission();
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    }
    
    // Get FCM token
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received notification in foreground: ${message.notification?.title}');
    });
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
  }
}
```

### 7.2 Update FCM Token on Launch

In your main app or splash screen:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import '../repositories/auth_repository.dart';

// After user logs in
final fcmToken = await FirebaseMessaging.instance.getToken();
if (fcmToken != null) {
  await authRepository.updateFcmToken(fcmToken);
}
```

---

## 8. Best Practices

### 8.1 Image & Video Optimization

```dart
// Compress image before upload
import 'package:image/image.dart' as img;

Future<File> compressImage(File imageFile) async {
  final image = img.decodeImage(await imageFile.readAsBytes());
  final compressedImage = img.encodeJpg(image!, quality: 85);
  
  final compressedFile = File('${imageFile.parent.path}/compressed.jpg');
  await compressedFile.writeAsBytes(compressedImage);
  
  return compressedFile;
}
```

### 8.2 Error Handling

```dart
// Custom error handling
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

// Use in repositories
try {
  // API call
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    throw AppException('Unauthorized', code: '401');
  } else if (e.response?.statusCode == 500) {
    throw AppException('Server error', code: '500');
  } else {
    throw AppException(e.message ?? 'Unknown error');
  }
}
```

### 8.3 Pagination

```dart
// Implement infinite scroll
final ScrollController _scrollController = ScrollController();

@override
void initState() {
  _scrollController.addListener(() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load next page
      _currentPage++;
    }
  });
  super.initState();
}
```

### 8.4 Caching

```dart
// Cache user preferences locally
final prefs = await SharedPreferences.getInstance();
await prefs.setString('user_id', userId.toString());
final cachedUserId = prefs.getString('user_id');
```

---

## 9. Testing

### 9.1 Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AuthRepository', () {
    test('login returns access token', () async {
      final mockDio = MockDio();
      final repository = AuthRepository(ApiClient()); // Pass mock
      
      // Mock response
      when(mockDio.post(any)).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: {'access_token': 'test_token'},
        statusCode: 200,
      ));
      
      final result = await repository.login(
        email: 'test@example.com',
        password: 'password',
      );
      
      expect(result['access_token'], 'test_token');
    });
  });
}
```

---

## 10. Deployment

### 10.1 Android Build

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### 10.2 iOS Build

```bash
flutter build ios --release
```

---

## 11. Troubleshooting

### Common Issues

1. **CORS Error**: Ensure API allows Flutter app origin
2. **Certificate Error**: Disable SSL verification only for development:
   ```dart
   (_apiClient.dio.httpClientAdapter as DefaultHttpClientAdapter)
       .onHttpClientCreate = (client) {
     client.badCertificateCallback = (_, __, ___) => true;
     return client;
   };
   ```
3. **Token Expiration**: Implement refresh token logic in interceptors

---

This guide provides a complete foundation for integrating your Flutter app with the Laravel backend. Customize as needed for your specific requirements!
