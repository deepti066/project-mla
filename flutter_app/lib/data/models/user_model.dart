import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? avatar;
  final String? bio;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_admin')
  final bool isAdmin;
  @JsonKey(name: 'is_private')
  final bool isPrivate;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.avatar,
    this.bio,
    required this.isVerified,
    required this.isAdmin,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatar,
    String? bio,
    bool? isVerified,
    bool? isAdmin,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
