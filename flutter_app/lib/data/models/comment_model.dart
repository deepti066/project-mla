import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class Comment {
  final int id;
  @JsonKey(name: 'post_id')
  final int postId;
  @JsonKey(name: 'user_id')
  final int userId;
  final String body;
  @JsonKey(name: 'parent_comment_id')
  final int? parentCommentId;
  final User user;
  final List<Comment>? replies;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.body,
    this.parentCommentId,
    required this.user,
    this.replies,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
