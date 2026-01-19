// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      isVerified: json['is_verified'] as bool,
      isAdmin: json['is_admin'] as bool,
      isPrivate: json['is_private'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'avatar': instance.avatar,
      'bio': instance.bio,
      'is_verified': instance.isVerified,
      'is_admin': instance.isAdmin,
      'is_private': instance.isPrivate,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
