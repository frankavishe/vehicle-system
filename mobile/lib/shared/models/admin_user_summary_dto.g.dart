// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminUserSummaryDtoImpl _$$AdminUserSummaryDtoImplFromJson(
  Map<String, dynamic> json,
) => _$AdminUserSummaryDtoImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  fullName: json['full_name'] as String,
  role: json['role'] as String,
  isActive: json['is_active'] as bool,
  isVerified: json['is_verified'] as bool,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$$AdminUserSummaryDtoImplToJson(
  _$AdminUserSummaryDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'phone': instance.phone,
  'full_name': instance.fullName,
  'role': instance.role,
  'is_active': instance.isActive,
  'is_verified': instance.isVerified,
  'created_at': instance.createdAt,
};
