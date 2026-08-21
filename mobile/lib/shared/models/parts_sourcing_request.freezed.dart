// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parts_sourcing_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PartsSourcingRequestDto _$PartsSourcingRequestDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PartsSourcingRequestDto.fromJson(json);
}

/// @nodoc
mixin _$PartsSourcingRequestDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_request')
  String get serviceRequestId => throw _privateConstructorUsedError;
  @JsonKey(name: 'requested_by')
  String? get requestedById => throw _privateConstructorUsedError;
  @JsonKey(name: 'spare_part')
  String? get sparePartId => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  PartsSourcingStatus get status => throw _privateConstructorUsedError;
  String? get order => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PartsSourcingRequestDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PartsSourcingRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartsSourcingRequestDtoCopyWith<PartsSourcingRequestDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartsSourcingRequestDtoCopyWith<$Res> {
  factory $PartsSourcingRequestDtoCopyWith(
    PartsSourcingRequestDto value,
    $Res Function(PartsSourcingRequestDto) then,
  ) = _$PartsSourcingRequestDtoCopyWithImpl<$Res, PartsSourcingRequestDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'service_request') String serviceRequestId,
    @JsonKey(name: 'requested_by') String? requestedById,
    @JsonKey(name: 'spare_part') String? sparePartId,
    int quantity,
    PartsSourcingStatus status,
    String? order,
    @JsonKey(name: 'created_at') String createdAt,
  });
}

/// @nodoc
class _$PartsSourcingRequestDtoCopyWithImpl<
  $Res,
  $Val extends PartsSourcingRequestDto
>
    implements $PartsSourcingRequestDtoCopyWith<$Res> {
  _$PartsSourcingRequestDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartsSourcingRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceRequestId = null,
    Object? requestedById = freezed,
    Object? sparePartId = freezed,
    Object? quantity = null,
    Object? status = null,
    Object? order = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceRequestId: null == serviceRequestId
                ? _value.serviceRequestId
                : serviceRequestId // ignore: cast_nullable_to_non_nullable
                      as String,
            requestedById: freezed == requestedById
                ? _value.requestedById
                : requestedById // ignore: cast_nullable_to_non_nullable
                      as String?,
            sparePartId: freezed == sparePartId
                ? _value.sparePartId
                : sparePartId // ignore: cast_nullable_to_non_nullable
                      as String?,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PartsSourcingStatus,
            order: freezed == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$PartsSourcingRequestDtoImplCopyWith<$Res>
    implements $PartsSourcingRequestDtoCopyWith<$Res> {
  factory _$$PartsSourcingRequestDtoImplCopyWith(
    _$PartsSourcingRequestDtoImpl value,
    $Res Function(_$PartsSourcingRequestDtoImpl) then,
  ) = __$$PartsSourcingRequestDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'service_request') String serviceRequestId,
    @JsonKey(name: 'requested_by') String? requestedById,
    @JsonKey(name: 'spare_part') String? sparePartId,
    int quantity,
    PartsSourcingStatus status,
    String? order,
    @JsonKey(name: 'created_at') String createdAt,
  });
}

/// @nodoc
class __$$PartsSourcingRequestDtoImplCopyWithImpl<$Res>
    extends
        _$PartsSourcingRequestDtoCopyWithImpl<
          $Res,
          _$PartsSourcingRequestDtoImpl
        >
    implements _$$PartsSourcingRequestDtoImplCopyWith<$Res> {
  __$$PartsSourcingRequestDtoImplCopyWithImpl(
    _$PartsSourcingRequestDtoImpl _value,
    $Res Function(_$PartsSourcingRequestDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PartsSourcingRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceRequestId = null,
    Object? requestedById = freezed,
    Object? sparePartId = freezed,
    Object? quantity = null,
    Object? status = null,
    Object? order = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$PartsSourcingRequestDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceRequestId: null == serviceRequestId
            ? _value.serviceRequestId
            : serviceRequestId // ignore: cast_nullable_to_non_nullable
                  as String,
        requestedById: freezed == requestedById
            ? _value.requestedById
            : requestedById // ignore: cast_nullable_to_non_nullable
                  as String?,
        sparePartId: freezed == sparePartId
            ? _value.sparePartId
            : sparePartId // ignore: cast_nullable_to_non_nullable
                  as String?,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PartsSourcingStatus,
        order: freezed == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$PartsSourcingRequestDtoImpl implements _PartsSourcingRequestDto {
  const _$PartsSourcingRequestDtoImpl({
    required this.id,
    @JsonKey(name: 'service_request') required this.serviceRequestId,
    @JsonKey(name: 'requested_by') this.requestedById,
    @JsonKey(name: 'spare_part') this.sparePartId,
    required this.quantity,
    required this.status,
    this.order,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$PartsSourcingRequestDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PartsSourcingRequestDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'service_request')
  final String serviceRequestId;
  @override
  @JsonKey(name: 'requested_by')
  final String? requestedById;
  @override
  @JsonKey(name: 'spare_part')
  final String? sparePartId;
  @override
  final int quantity;
  @override
  final PartsSourcingStatus status;
  @override
  final String? order;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'PartsSourcingRequestDto(id: $id, serviceRequestId: $serviceRequestId, requestedById: $requestedById, sparePartId: $sparePartId, quantity: $quantity, status: $status, order: $order, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartsSourcingRequestDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serviceRequestId, serviceRequestId) ||
                other.serviceRequestId == serviceRequestId) &&
            (identical(other.requestedById, requestedById) ||
                other.requestedById == requestedById) &&
            (identical(other.sparePartId, sparePartId) ||
                other.sparePartId == sparePartId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    serviceRequestId,
    requestedById,
    sparePartId,
    quantity,
    status,
    order,
    createdAt,
  );

  /// Create a copy of PartsSourcingRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartsSourcingRequestDtoImplCopyWith<_$PartsSourcingRequestDtoImpl>
  get copyWith =>
      __$$PartsSourcingRequestDtoImplCopyWithImpl<
        _$PartsSourcingRequestDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PartsSourcingRequestDtoImplToJson(this);
  }
}

abstract class _PartsSourcingRequestDto implements PartsSourcingRequestDto {
  const factory _PartsSourcingRequestDto({
    required final String id,
    @JsonKey(name: 'service_request') required final String serviceRequestId,
    @JsonKey(name: 'requested_by') final String? requestedById,
    @JsonKey(name: 'spare_part') final String? sparePartId,
    required final int quantity,
    required final PartsSourcingStatus status,
    final String? order,
    @JsonKey(name: 'created_at') required final String createdAt,
  }) = _$PartsSourcingRequestDtoImpl;

  factory _PartsSourcingRequestDto.fromJson(Map<String, dynamic> json) =
      _$PartsSourcingRequestDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'service_request')
  String get serviceRequestId;
  @override
  @JsonKey(name: 'requested_by')
  String? get requestedById;
  @override
  @JsonKey(name: 'spare_part')
  String? get sparePartId;
  @override
  int get quantity;
  @override
  PartsSourcingStatus get status;
  @override
  String? get order;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of PartsSourcingRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartsSourcingRequestDtoImplCopyWith<_$PartsSourcingRequestDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
