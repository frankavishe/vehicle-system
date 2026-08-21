// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      fullName: json['full_name'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      isActive: json['is_active'] as bool,
      isVerified: json['is_verified'] as bool,
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'full_name': instance.fullName,
      'role': _$UserRoleEnumMap[instance.role]!,
      'is_active': instance.isActive,
      'is_verified': instance.isVerified,
    };

const _$UserRoleEnumMap = {
  UserRole.customer: 'CUSTOMER',
  UserRole.mechanic: 'MECHANIC',
  UserRole.recovery: 'RECOVERY',
  UserRole.admin: 'ADMIN',
};
