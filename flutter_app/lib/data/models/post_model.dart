import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'post_model.g.dart';

@JsonSerializable()
class Media {
  final int id;
  @JsonKey(name: 'post_id')
  final int postId;
  @JsonKey(name: 'media_type')
  final String mediaType;
  @JsonKey(name: 'media_url')
  final String mediaUrl;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  final int order;

  Media({
    required this.id,
    required this.postId,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.order,
  });

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
  Map<String, dynamic> toJson() => _$MediaToJson(this);
}

@JsonSerializable()
class Post {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String caption;
  final List<Media> media;
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  @JsonKey(name: 'shares_count')
  final int sharesCount;
  @JsonKey(name: 'is_archived')
  final bool isArchived;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final User user;
  @JsonKey(name: 'is_liked_by_auth')
  final bool isLikedByAuth;

  Post({
    required this.id,
    required this.userId,
    required this.caption,
    required this.media,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.isArchived,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.isLikedByAuth,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);

  Post copyWith({
    int? id,
    int? userId,
    String? caption,
    List<Media>? media,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isArchived,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    bool? isLikedByAuth,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caption: caption ?? this.caption,
      media: media ?? this.media,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isArchived: isArchived ?? this.isArchived,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      isLikedByAuth: isLikedByAuth ?? this.isLikedByAuth,
    );
  }
}
