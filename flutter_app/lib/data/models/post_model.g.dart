// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
      id: (json['id'] as num).toInt(),
      postId: (json['post_id'] as num).toInt(),
      mediaType: json['media_type'] as String,
      mediaUrl: json['media_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'media_type': instance.mediaType,
      'media_url': instance.mediaUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'order': instance.order,
    };

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      caption: json['caption'] as String,
      media: (json['media'] as List<dynamic>)
          .map((e) => Media.fromJson(e as Map<String, dynamic>))
          .toList(),
      likesCount: (json['likes_count'] as num).toInt(),
      commentsCount: (json['comments_count'] as num).toInt(),
      sharesCount: (json['shares_count'] as num).toInt(),
      isArchived: json['is_archived'] as bool,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      isLikedByAuth: json['is_liked_by_auth'] as bool,
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'caption': instance.caption,
      'media': instance.media,
      'likes_count': instance.likesCount,
      'comments_count': instance.commentsCount,
      'shares_count': instance.sharesCount,
      'is_archived': instance.isArchived,
      'published_at': instance.publishedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'user': instance.user,
      'is_liked_by_auth': instance.isLikedByAuth,
    };
