// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lat_lng_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LatLngPoint _$LatLngPointFromJson(Map<String, dynamic> json) {
  return _LatLngPoint.fromJson(json);
}

/// @nodoc
mixin _$LatLngPoint {
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;

  /// Serializes this LatLngPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LatLngPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LatLngPointCopyWith<LatLngPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LatLngPointCopyWith<$Res> {
  factory $LatLngPointCopyWith(
    LatLngPoint value,
    $Res Function(LatLngPoint) then,
  ) = _$LatLngPointCopyWithImpl<$Res, LatLngPoint>;
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class _$LatLngPointCopyWithImpl<$Res, $Val extends LatLngPoint>
    implements $LatLngPointCopyWith<$Res> {
  _$LatLngPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LatLngPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = null, Object? lng = null}) {
    return _then(
      _value.copyWith(
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LatLngPointImplCopyWith<$Res>
    implements $LatLngPointCopyWith<$Res> {
  factory _$$LatLngPointImplCopyWith(
    _$LatLngPointImpl value,
    $Res Function(_$LatLngPointImpl) then,
  ) = __$$LatLngPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class __$$LatLngPointImplCopyWithImpl<$Res>
    extends _$LatLngPointCopyWithImpl<$Res, _$LatLngPointImpl>
    implements _$$LatLngPointImplCopyWith<$Res> {
  __$$LatLngPointImplCopyWithImpl(
    _$LatLngPointImpl _value,
    $Res Function(_$LatLngPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LatLngPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = null, Object? lng = null}) {
    return _then(
      _$LatLngPointImpl(
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LatLngPointImpl implements _LatLngPoint {
  const _$LatLngPointImpl({required this.lat, required this.lng});

  factory _$LatLngPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$LatLngPointImplFromJson(json);

  @override
  final double lat;
  @override
  final double lng;

  @override
  String toString() {
    return 'LatLngPoint(lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LatLngPointImpl &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng);

  /// Create a copy of LatLngPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LatLngPointImplCopyWith<_$LatLngPointImpl> get copyWith =>
      __$$LatLngPointImplCopyWithImpl<_$LatLngPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LatLngPointImplToJson(this);
  }
}

abstract class _LatLngPoint implements LatLngPoint {
  const factory _LatLngPoint({
    required final double lat,
    required final double lng,
  }) = _$LatLngPointImpl;

  factory _LatLngPoint.fromJson(Map<String, dynamic> json) =
      _$LatLngPointImpl.fromJson;

  @override
  double get lat;
  @override
  double get lng;

  /// Create a copy of LatLngPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LatLngPointImplCopyWith<_$LatLngPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
