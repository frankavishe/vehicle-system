// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_shipment_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderShipmentDto _$OrderShipmentDtoFromJson(Map<String, dynamic> json) {
  return _OrderShipmentDto.fromJson(json);
}

/// @nodoc
mixin _$OrderShipmentDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'courier_name')
  String? get courierName => throw _privateConstructorUsedError;
  @JsonKey(name: 'tracking_ref')
  String? get trackingRef => throw _privateConstructorUsedError;
  @JsonKey(name: 'dispatched_at')
  String? get dispatchedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivered_at')
  String? get deliveredAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_location')
  LatLngPoint? get currentLocation => throw _privateConstructorUsedError;

  /// Serializes this OrderShipmentDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderShipmentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderShipmentDtoCopyWith<OrderShipmentDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderShipmentDtoCopyWith<$Res> {
  factory $OrderShipmentDtoCopyWith(
    OrderShipmentDto value,
    $Res Function(OrderShipmentDto) then,
  ) = _$OrderShipmentDtoCopyWithImpl<$Res, OrderShipmentDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'courier_name') String? courierName,
    @JsonKey(name: 'tracking_ref') String? trackingRef,
    @JsonKey(name: 'dispatched_at') String? dispatchedAt,
    @JsonKey(name: 'delivered_at') String? deliveredAt,
    @JsonKey(name: 'current_location') LatLngPoint? currentLocation,
  });

  $LatLngPointCopyWith<$Res>? get currentLocation;
}

/// @nodoc
class _$OrderShipmentDtoCopyWithImpl<$Res, $Val extends OrderShipmentDto>
    implements $OrderShipmentDtoCopyWith<$Res> {
  _$OrderShipmentDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderShipmentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courierName = freezed,
    Object? trackingRef = freezed,
    Object? dispatchedAt = freezed,
    Object? deliveredAt = freezed,
    Object? currentLocation = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            courierName: freezed == courierName
                ? _value.courierName
                : courierName // ignore: cast_nullable_to_non_nullable
                      as String?,
            trackingRef: freezed == trackingRef
                ? _value.trackingRef
                : trackingRef // ignore: cast_nullable_to_non_nullable
                      as String?,
            dispatchedAt: freezed == dispatchedAt
                ? _value.dispatchedAt
                : dispatchedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            deliveredAt: freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentLocation: freezed == currentLocation
                ? _value.currentLocation
                : currentLocation // ignore: cast_nullable_to_non_nullable
                      as LatLngPoint?,
          )
          as $Val,
    );
  }

  /// Create a copy of OrderShipmentDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LatLngPointCopyWith<$Res>? get currentLocation {
    if (_value.currentLocation == null) {
      return null;
    }

    return $LatLngPointCopyWith<$Res>(_value.currentLocation!, (value) {
      return _then(_value.copyWith(currentLocation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderShipmentDtoImplCopyWith<$Res>
    implements $OrderShipmentDtoCopyWith<$Res> {
  factory _$$OrderShipmentDtoImplCopyWith(
    _$OrderShipmentDtoImpl value,
    $Res Function(_$OrderShipmentDtoImpl) then,
  ) = __$$OrderShipmentDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'courier_name') String? courierName,
    @JsonKey(name: 'tracking_ref') String? trackingRef,
    @JsonKey(name: 'dispatched_at') String? dispatchedAt,
    @JsonKey(name: 'delivered_at') String? deliveredAt,
    @JsonKey(name: 'current_location') LatLngPoint? currentLocation,
  });

  @override
  $LatLngPointCopyWith<$Res>? get currentLocation;
}

/// @nodoc
class __$$OrderShipmentDtoImplCopyWithImpl<$Res>
    extends _$OrderShipmentDtoCopyWithImpl<$Res, _$OrderShipmentDtoImpl>
    implements _$$OrderShipmentDtoImplCopyWith<$Res> {
  __$$OrderShipmentDtoImplCopyWithImpl(
    _$OrderShipmentDtoImpl _value,
    $Res Function(_$OrderShipmentDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderShipmentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courierName = freezed,
    Object? trackingRef = freezed,
    Object? dispatchedAt = freezed,
    Object? deliveredAt = freezed,
    Object? currentLocation = freezed,
  }) {
    return _then(
      _$OrderShipmentDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        courierName: freezed == courierName
            ? _value.courierName
            : courierName // ignore: cast_nullable_to_non_nullable
                  as String?,
        trackingRef: freezed == trackingRef
            ? _value.trackingRef
            : trackingRef // ignore: cast_nullable_to_non_nullable
                  as String?,
        dispatchedAt: freezed == dispatchedAt
            ? _value.dispatchedAt
            : dispatchedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        deliveredAt: freezed == deliveredAt
            ? _value.deliveredAt
            : deliveredAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentLocation: freezed == currentLocation
            ? _value.currentLocation
            : currentLocation // ignore: cast_nullable_to_non_nullable
                  as LatLngPoint?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderShipmentDtoImpl implements _OrderShipmentDto {
  const _$OrderShipmentDtoImpl({
    required this.id,
    @JsonKey(name: 'courier_name') this.courierName,
    @JsonKey(name: 'tracking_ref') this.trackingRef,
    @JsonKey(name: 'dispatched_at') this.dispatchedAt,
    @JsonKey(name: 'delivered_at') this.deliveredAt,
    @JsonKey(name: 'current_location') this.currentLocation,
  });

  factory _$OrderShipmentDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderShipmentDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'courier_name')
  final String? courierName;
  @override
  @JsonKey(name: 'tracking_ref')
  final String? trackingRef;
  @override
  @JsonKey(name: 'dispatched_at')
  final String? dispatchedAt;
  @override
  @JsonKey(name: 'delivered_at')
  final String? deliveredAt;
  @override
  @JsonKey(name: 'current_location')
  final LatLngPoint? currentLocation;

  @override
  String toString() {
    return 'OrderShipmentDto(id: $id, courierName: $courierName, trackingRef: $trackingRef, dispatchedAt: $dispatchedAt, deliveredAt: $deliveredAt, currentLocation: $currentLocation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderShipmentDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courierName, courierName) ||
                other.courierName == courierName) &&
            (identical(other.trackingRef, trackingRef) ||
                other.trackingRef == trackingRef) &&
            (identical(other.dispatchedAt, dispatchedAt) ||
                other.dispatchedAt == dispatchedAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.currentLocation, currentLocation) ||
                other.currentLocation == currentLocation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    courierName,
    trackingRef,
    dispatchedAt,
    deliveredAt,
    currentLocation,
  );

  /// Create a copy of OrderShipmentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderShipmentDtoImplCopyWith<_$OrderShipmentDtoImpl> get copyWith =>
      __$$OrderShipmentDtoImplCopyWithImpl<_$OrderShipmentDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderShipmentDtoImplToJson(this);
  }
}

abstract class _OrderShipmentDto implements OrderShipmentDto {
  const factory _OrderShipmentDto({
    required final String id,
    @JsonKey(name: 'courier_name') final String? courierName,
    @JsonKey(name: 'tracking_ref') final String? trackingRef,
    @JsonKey(name: 'dispatched_at') final String? dispatchedAt,
    @JsonKey(name: 'delivered_at') final String? deliveredAt,
    @JsonKey(name: 'current_location') final LatLngPoint? currentLocation,
  }) = _$OrderShipmentDtoImpl;

  factory _OrderShipmentDto.fromJson(Map<String, dynamic> json) =
      _$OrderShipmentDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'courier_name')
  String? get courierName;
  @override
  @JsonKey(name: 'tracking_ref')
  String? get trackingRef;
  @override
  @JsonKey(name: 'dispatched_at')
  String? get dispatchedAt;
  @override
  @JsonKey(name: 'delivered_at')
  String? get deliveredAt;
  @override
  @JsonKey(name: 'current_location')
  LatLngPoint? get currentLocation;

  /// Create a copy of OrderShipmentDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderShipmentDtoImplCopyWith<_$OrderShipmentDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
