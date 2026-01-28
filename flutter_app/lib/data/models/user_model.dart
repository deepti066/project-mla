import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final int? id;                    // ← nullable
  final String? name;               // ← nullable
  final String? email;              // ← nullable
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? avatar;
  final String? bio;
  @JsonKey(name: 'is_verified')
  final bool? isVerified;
  @JsonKey(name: 'is_admin')
  final bool? isAdmin;
  @JsonKey(name: 'is_private')
  final bool? isPrivate;

  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)
  final DateTime? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.avatar,
    this.bio,
    this.isVerified,
    this.isAdmin,
    this.isPrivate,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  get isFollowing => null;

  get stats => null;
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Safe date parser
  static DateTime? _dateTimeFromJson(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  // Optional: copyWith with nullables
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
