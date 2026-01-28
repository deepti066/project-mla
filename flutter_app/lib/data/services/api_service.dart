import 'package:dio/dio.dart';
import '../../config/api_config.dart';

class ApiService {
  late Dio dio;
  final String baseUrl;

  ApiService(this.dio, {this.baseUrl = ''}) {
    if (baseUrl.isNotEmpty) {
      dio.options.baseUrl = baseUrl;
    }
  }

  // Auth Endpoints
  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await dio.post(ApiConfig.login, data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await dio.post(ApiConfig.register, data: data);
    return response.data;
  }

  // Post Endpoints
  Future<Map<String, dynamic>> getPosts(int page, int perPage) async {
    final response = await dio.get(
      ApiConfig.posts,
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getFeed(int page, int perPage) async {
    final response = await dio.get(
      ApiConfig.feed,
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getPost(int postId) async {
    final response = await dio.get('${ApiConfig.posts}/$postId');
    return response.data;
  }

  Future<Map<String, dynamic>> createPost(String caption, List<MultipartFile> media) async {
    FormData formData = FormData.fromMap({
      'caption': caption,
      'media': media,
    });
    final response = await dio.post(ApiConfig.posts, data: formData);
    return response.data;
  }

  Future<Map<String, dynamic>> updatePost(int postId, Map<String, dynamic> data) async {
    final response = await dio.put('${ApiConfig.posts}/$postId', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> deletePost(int postId) async {
    final response = await dio.delete('${ApiConfig.posts}/$postId');
    return response.data;
  }

  // Like Endpoints
  Future<Map<String, dynamic>> likePost(int postId) async {
    final response = await dio.post('${ApiConfig.posts}/$postId/like');
    return response.data;
  }

  Future<Map<String, dynamic>> unlikePost(int postId) async {
    final response = await dio.post('${ApiConfig.posts}/$postId/unlike');
    return response.data;
  }

  Future<Map<String, dynamic>> getLikes(int postId, int page) async {
    final response = await dio.get(
      '${ApiConfig.posts}/$postId/likes',
      queryParameters: {'page': page},
    );
    return response.data;
  }

  // Comment Endpoints
  Future<Map<String, dynamic>> getComments(int postId, int page) async {
    final response = await dio.get(
      '${ApiConfig.posts}/$postId/comments',
      queryParameters: {'page': page},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> createComment(int postId, Map<String, dynamic> data) async {
    final response = await dio.post('${ApiConfig.posts}/$postId/comments', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updateComment(int commentId, Map<String, dynamic> data) async {
    final response = await dio.put('${ApiConfig.comments}/$commentId', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> deleteComment(int commentId) async {
    final response = await dio.delete('${ApiConfig.comments}/$commentId');
    return response.data;
  }

  // Share Endpoints
  Future<Map<String, dynamic>> sharePost(int postId, Map<String, dynamic> data) async {
    final response = await dio.post('${ApiConfig.posts}/$postId/share', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> getShares(int postId) async {
    final response = await dio.get('${ApiConfig.posts}/$postId/shares');
    return response.data;
  }

  Future<Map<String, dynamic>> deleteShare(int shareId) async {
    final response = await dio.delete('${ApiConfig.shares}/$shareId');
    return response.data;
  }

  // User Endpoints
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await dio.get('${ApiConfig.users}/me');
    return response.data;
  }

  Future<Map<String, dynamic>> getUser(int userId) async {
    final response = await dio.get('${ApiConfig.users}/$userId');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? bio,
    MultipartFile? avatar,
    bool? isPrivate,
  }) async {
    FormData formData = FormData.fromMap({
      if (name != null) 'name': name,
      if (bio != null) 'bio': bio,
      if (avatar != null) 'avatar': avatar,
      if (isPrivate != null) 'is_private': isPrivate,
    });
    final response = await dio.put('${ApiConfig.users}/profile', data: formData);
    return response.data;
  }

  Future<Map<String, dynamic>> followUser(int userId) async {
    final response = await dio.post('${ApiConfig.users}/$userId/follow');
    return response.data;
  }

  Future<Map<String, dynamic>> unfollowUser(int userId) async {
    final response = await dio.post('${ApiConfig.users}/$userId/unfollow');
    return response.data;
  }

  Future<Map<String, dynamic>> getFollowers(int userId, int page) async {
    final response = await dio.get(
      '${ApiConfig.users}/$userId/followers',
      queryParameters: {'page': page},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getFollowing(int userId, int page) async {
    final response = await dio.get(
      '${ApiConfig.users}/$userId/following',
      queryParameters: {'page': page},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> searchUsers(String query) async {
    final response = await dio.get(
      '${ApiConfig.users}/search',
      queryParameters: {'q': query},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateFcmToken(Map<String, dynamic> data) async {
    final response = await dio.post(ApiConfig.updateFcmToken, data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> changePassword(Map<String, dynamic> data) async {
    final response = await dio.post('${ApiConfig.users}/change-password', data: data);
    return response.data;
  }
}
