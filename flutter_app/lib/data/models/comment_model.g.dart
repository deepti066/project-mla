// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: (json['id'] as num).toInt(),
      postId: (json['post_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      body: json['body'] as String,
      parentCommentId: (json['parent_comment_id'] as num?)?.toInt(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'user_id': instance.userId,
      'body': instance.body,
      'parent_comment_id': instance.parentCommentId,
      'user': instance.user,
      'replies': instance.replies,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
