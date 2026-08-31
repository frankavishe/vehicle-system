// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user_summary_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AdminUserSummaryDto _$AdminUserSummaryDtoFromJson(Map<String, dynamic> json) {
  return _AdminUserSummaryDto.fromJson(json);
}

/// @nodoc
mixin _$AdminUserSummaryDto {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // CUSTOMER | MECHANIC | RECOVERY | ADMIN
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_verified')
  bool get isVerified => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AdminUserSummaryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminUserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminUserSummaryDtoCopyWith<AdminUserSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminUserSummaryDtoCopyWith<$Res> {
  factory $AdminUserSummaryDtoCopyWith(
    AdminUserSummaryDto value,
    $Res Function(AdminUserSummaryDto) then,
  ) = _$AdminUserSummaryDtoCopyWithImpl<$Res, AdminUserSummaryDto>;
  @useResult
  $Res call({
    String id,
    String email,
    String? phone,
    @JsonKey(name: 'full_name') String fullName,
    String role,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'is_verified') bool isVerified,
    @JsonKey(name: 'created_at') String createdAt,
  });
}

/// @nodoc
class _$AdminUserSummaryDtoCopyWithImpl<$Res, $Val extends AdminUserSummaryDto>
    implements $AdminUserSummaryDtoCopyWith<$Res> {
  _$AdminUserSummaryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminUserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? phone = freezed,
    Object? fullName = null,
    Object? role = null,
    Object? isActive = null,
    Object? isVerified = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isVerified: null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminUserSummaryDtoImplCopyWith<$Res>
    implements $AdminUserSummaryDtoCopyWith<$Res> {
  factory _$$AdminUserSummaryDtoImplCopyWith(
    _$AdminUserSummaryDtoImpl value,
    $Res Function(_$AdminUserSummaryDtoImpl) then,
  ) = __$$AdminUserSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String? phone,
    @JsonKey(name: 'full_name') String fullName,
    String role,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'is_verified') bool isVerified,
    @JsonKey(name: 'created_at') String createdAt,
  });
}

/// @nodoc
class __$$AdminUserSummaryDtoImplCopyWithImpl<$Res>
    extends _$AdminUserSummaryDtoCopyWithImpl<$Res, _$AdminUserSummaryDtoImpl>
    implements _$$AdminUserSummaryDtoImplCopyWith<$Res> {
  __$$AdminUserSummaryDtoImplCopyWithImpl(
    _$AdminUserSummaryDtoImpl _value,
    $Res Function(_$AdminUserSummaryDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminUserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? phone = freezed,
    Object? fullName = null,
    Object? role = null,
    Object? isActive = null,
    Object? isVerified = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AdminUserSummaryDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminUserSummaryDtoImpl implements _AdminUserSummaryDto {
  const _$AdminUserSummaryDtoImpl({
    required this.id,
    required this.email,
    this.phone,
    @JsonKey(name: 'full_name') required this.fullName,
    required this.role,
    @JsonKey(name: 'is_active') required this.isActive,
    @JsonKey(name: 'is_verified') required this.isVerified,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$AdminUserSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminUserSummaryDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? phone;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final String role;
  // CUSTOMER | MECHANIC | RECOVERY | ADMIN
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'AdminUserSummaryDto(id: $id, email: $email, phone: $phone, fullName: $fullName, role: $role, isActive: $isActive, isVerified: $isVerified, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminUserSummaryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    phone,
    fullName,
    role,
    isActive,
    isVerified,
    createdAt,
  );

  /// Create a copy of AdminUserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminUserSummaryDtoImplCopyWith<_$AdminUserSummaryDtoImpl> get copyWith =>
      __$$AdminUserSummaryDtoImplCopyWithImpl<_$AdminUserSummaryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminUserSummaryDtoImplToJson(this);
  }
}

abstract class _AdminUserSummaryDto implements AdminUserSummaryDto {
  const factory _AdminUserSummaryDto({
    required final String id,
    required final String email,
    final String? phone,
    @JsonKey(name: 'full_name') required final String fullName,
    required final String role,
    @JsonKey(name: 'is_active') required final bool isActive,
    @JsonKey(name: 'is_verified') required final bool isVerified,
    @JsonKey(name: 'created_at') required final String createdAt,
  }) = _$AdminUserSummaryDtoImpl;

  factory _AdminUserSummaryDto.fromJson(Map<String, dynamic> json) =
      _$AdminUserSummaryDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get phone;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  String get role; // CUSTOMER | MECHANIC | RECOVERY | ADMIN
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'is_verified')
  bool get isVerified;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of AdminUserSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminUserSummaryDtoImplCopyWith<_$AdminUserSummaryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
