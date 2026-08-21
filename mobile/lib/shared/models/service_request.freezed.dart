// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ServiceRequestDto _$ServiceRequestDtoFromJson(Map<String, dynamic> json) {
  return _ServiceRequestDto.fromJson(json);
}

/// @nodoc
mixin _$ServiceRequestDto {
  String get id => throw _privateConstructorUsedError;
  UserSummary? get customer => throw _privateConstructorUsedError;
  UserSummary? get provider => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_type')
  ServiceType get serviceType => throw _privateConstructorUsedError;
  ServiceStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'pickup_location')
  LatLngPoint get pickupLocation => throw _privateConstructorUsedError;
  @JsonKey(name: 'dropoff_location')
  LatLngPoint? get dropoffLocation => throw _privateConstructorUsedError;
  @JsonKey(name: 'problem_description')
  String? get problemDescription => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_fare')
  String? get estimatedFare => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_fare')
  String? get finalFare => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ServiceRequestDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceRequestDtoCopyWith<ServiceRequestDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceRequestDtoCopyWith<$Res> {
  factory $ServiceRequestDtoCopyWith(
    ServiceRequestDto value,
    $Res Function(ServiceRequestDto) then,
  ) = _$ServiceRequestDtoCopyWithImpl<$Res, ServiceRequestDto>;
  @useResult
  $Res call({
    String id,
    UserSummary? customer,
    UserSummary? provider,
    @JsonKey(name: 'service_type') ServiceType serviceType,
    ServiceStatus status,
    @JsonKey(name: 'pickup_location') LatLngPoint pickupLocation,
    @JsonKey(name: 'dropoff_location') LatLngPoint? dropoffLocation,
    @JsonKey(name: 'problem_description') String? problemDescription,
    @JsonKey(name: 'estimated_fare') String? estimatedFare,
    @JsonKey(name: 'final_fare') String? finalFare,
    @JsonKey(name: 'created_at') String createdAt,
  });

  $UserSummaryCopyWith<$Res>? get customer;
  $UserSummaryCopyWith<$Res>? get provider;
  $LatLngPointCopyWith<$Res> get pickupLocation;
  $LatLngPointCopyWith<$Res>? get dropoffLocation;
}

/// @nodoc
class _$ServiceRequestDtoCopyWithImpl<$Res, $Val extends ServiceRequestDto>
    implements $ServiceRequestDtoCopyWith<$Res> {
  _$ServiceRequestDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customer = freezed,
    Object? provider = freezed,
    Object? serviceType = null,
    Object? status = null,
    Object? pickupLocation = null,
    Object? dropoffLocation = freezed,
    Object? problemDescription = freezed,
    Object? estimatedFare = freezed,
    Object? finalFare = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            customer: freezed == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as UserSummary?,
            provider: freezed == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as UserSummary?,
            serviceType: null == serviceType
                ? _value.serviceType
                : serviceType // ignore: cast_nullable_to_non_nullable
                      as ServiceType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ServiceStatus,
            pickupLocation: null == pickupLocation
                ? _value.pickupLocation
                : pickupLocation // ignore: cast_nullable_to_non_nullable
                      as LatLngPoint,
            dropoffLocation: freezed == dropoffLocation
                ? _value.dropoffLocation
                : dropoffLocation // ignore: cast_nullable_to_non_nullable
                      as LatLngPoint?,
            problemDescription: freezed == problemDescription
                ? _value.problemDescription
                : problemDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            estimatedFare: freezed == estimatedFare
                ? _value.estimatedFare
                : estimatedFare // ignore: cast_nullable_to_non_nullable
                      as String?,
            finalFare: freezed == finalFare
                ? _value.finalFare
                : finalFare // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of ServiceRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSummaryCopyWith<$Res>? get customer {
    if (_value.customer == null) {
      return null;
    }

    return $UserSummaryCopyWith<$Res>(_value.customer!, (value) {
      return _then(_value.copyWith(customer: value) as $Val);
    });
  }

  /// Create a copy of ServiceRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSummaryCopyWith<$Res>? get provider {
    if (_value.provider == null) {
      return null;
    }

    return $UserSummaryCopyWith<$Res>(_value.provider!, (value) {
      return _then(_value.copyWith(provider: value) as $Val);
    });
  }

  /// Create a copy of ServiceRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LatLngPointCopyWith<$Res> get pickupLocation {
    return $LatLngPointCopyWith<$Res>(_value.pickupLocation, (value) {
      return _then(_value.copyWith(pickupLocation: value) as $Val);
    });
  }

  /// Create a copy of ServiceRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LatLngPointCopyWith<$Res>? get dropoffLocation {
    if (_value.dropoffLocation == null) {
      return null;
    }

    return $LatLngPointCopyWith<$Res>(_value.dropoffLocation!, (value) {
      return _then(_value.copyWith(dropoffLocation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ServiceRequestDtoImplCopyWith<$Res>
    implements $ServiceRequestDtoCopyWith<$Res> {
  factory _$$ServiceRequestDtoImplCopyWith(
    _$ServiceRequestDtoImpl value,
    $Res Function(_$ServiceRequestDtoImpl) then,
  ) = __$$ServiceRequestDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    UserSummary? customer,
    UserSummary? provider,
    @JsonKey(name: 'service_type') ServiceType serviceType,
    ServiceStatus status,
    @JsonKey(name: 'pickup_location') LatLngPoint pickupLocation,
    @JsonKey(name: 'dropoff_location') LatLngPoint? dropoffLocation,
    @JsonKey(name: 'problem_description') String? problemDescription,
    @JsonKey(name: 'estimated_fare') String? estimatedFare,
    @JsonKey(name: 'final_fare') String? finalFare,
    @JsonKey(name: 'created_at') String createdAt,
  });

  @override
  $UserSummaryCopyWith<$Res>? get customer;
  @override
  $UserSummaryCopyWith<$Res>? get provider;
  @override
  $LatLngPointCopyWith<$Res> get pickupLocation;
  @override
  $LatLngPointCopyWith<$Res>? get dropoffLocation;
}

/// @nodoc
class __$$ServiceRequestDtoImplCopyWithImpl<$Res>
    extends _$ServiceRequestDtoCopyWithImpl<$Res, _$ServiceRequestDtoImpl>
    implements _$$ServiceRequestDtoImplCopyWith<$Res> {
  __$$ServiceRequestDtoImplCopyWithImpl(
    _$ServiceRequestDtoImpl _value,
    $Res Function(_$ServiceRequestDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServiceRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customer = freezed,
    Object? provider = freezed,
    Object? serviceType = null,
    Object? status = null,
    Object? pickupLocation = null,
    Object? dropoffLocation = freezed,
    Object? problemDescription = freezed,
    Object? estimatedFare = freezed,
    Object? finalFare = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ServiceRequestDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        customer: freezed == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as UserSummary?,
        provider: freezed == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as UserSummary?,
        serviceType: null == serviceType
            ? _value.serviceType
            : serviceType // ignore: cast_nullable_to_non_nullable
                  as ServiceType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ServiceStatus,
        pickupLocation: null == pickupLocation
            ? _value.pickupLocation
            : pickupLocation // ignore: cast_nullable_to_non_nullable
                  as LatLngPoint,
        dropoffLocation: freezed == dropoffLocation
            ? _value.dropoffLocation
            : dropoffLocation // ignore: cast_nullable_to_non_nullable
                  as LatLngPoint?,
        problemDescription: freezed == problemDescription
            ? _value.problemDescription
            : problemDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        estimatedFare: freezed == estimatedFare
            ? _value.estimatedFare
            : estimatedFare // ignore: cast_nullable_to_non_nullable
                  as String?,
        finalFare: freezed == finalFare
            ? _value.finalFare
            : finalFare // ignore: cast_nullable_to_non_nullable
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
class _$ServiceRequestDtoImpl implements _ServiceRequestDto {
  const _$ServiceRequestDtoImpl({
    required this.id,
    this.customer,
    this.provider,
    @JsonKey(name: 'service_type') required this.serviceType,
    required this.status,
    @JsonKey(name: 'pickup_location') required this.pickupLocation,
    @JsonKey(name: 'dropoff_location') this.dropoffLocation,
    @JsonKey(name: 'problem_description') this.problemDescription,
    @JsonKey(name: 'estimated_fare') this.estimatedFare,
    @JsonKey(name: 'final_fare') this.finalFare,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$ServiceRequestDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceRequestDtoImplFromJson(json);

  @override
  final String id;
  @override
  final UserSummary? customer;
  @override
  final UserSummary? provider;
  @override
  @JsonKey(name: 'service_type')
  final ServiceType serviceType;
  @override
  final ServiceStatus status;
  @override
  @JsonKey(name: 'pickup_location')
  final LatLngPoint pickupLocation;
  @override
  @JsonKey(name: 'dropoff_location')
  final LatLngPoint? dropoffLocation;
  @override
  @JsonKey(name: 'problem_description')
  final String? problemDescription;
  @override
  @JsonKey(name: 'estimated_fare')
  final String? estimatedFare;
  @override
  @JsonKey(name: 'final_fare')
  final String? finalFare;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'ServiceRequestDto(id: $id, customer: $customer, provider: $provider, serviceType: $serviceType, status: $status, pickupLocation: $pickupLocation, dropoffLocation: $dropoffLocation, problemDescription: $problemDescription, estimatedFare: $estimatedFare, finalFare: $finalFare, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceRequestDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.pickupLocation, pickupLocation) ||
                other.pickupLocation == pickupLocation) &&
            (identical(other.dropoffLocation, dropoffLocation) ||
                other.dropoffLocation == dropoffLocation) &&
            (identical(other.problemDescription, problemDescription) ||
                other.problemDescription == problemDescription) &&
            (identical(other.estimatedFare, estimatedFare) ||
                other.estimatedFare == estimatedFare) &&
            (identical(other.finalFare, finalFare) ||
                other.finalFare == finalFare) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    customer,
    provider,
    serviceType,
    status,
    pickupLocation,
    dropoffLocation,
    problemDescription,
    estimatedFare,
    finalFare,
    createdAt,
  );

  /// Create a copy of ServiceRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceRequestDtoImplCopyWith<_$ServiceRequestDtoImpl> get copyWith =>
      __$$ServiceRequestDtoImplCopyWithImpl<_$ServiceRequestDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceRequestDtoImplToJson(this);
  }
}

abstract class _ServiceRequestDto implements ServiceRequestDto {
  const factory _ServiceRequestDto({
    required final String id,
    final UserSummary? customer,
    final UserSummary? provider,
    @JsonKey(name: 'service_type') required final ServiceType serviceType,
    required final ServiceStatus status,
    @JsonKey(name: 'pickup_location') required final LatLngPoint pickupLocation,
    @JsonKey(name: 'dropoff_location') final LatLngPoint? dropoffLocation,
    @JsonKey(name: 'problem_description') final String? problemDescription,
    @JsonKey(name: 'estimated_fare') final String? estimatedFare,
    @JsonKey(name: 'final_fare') final String? finalFare,
    @JsonKey(name: 'created_at') required final String createdAt,
  }) = _$ServiceRequestDtoImpl;

  factory _ServiceRequestDto.fromJson(Map<String, dynamic> json) =
      _$ServiceRequestDtoImpl.fromJson;

  @override
  String get id;
  @override
  UserSummary? get customer;
  @override
  UserSummary? get provider;
  @override
  @JsonKey(name: 'service_type')
  ServiceType get serviceType;
  @override
  ServiceStatus get status;
  @override
  @JsonKey(name: 'pickup_location')
  LatLngPoint get pickupLocation;
  @override
  @JsonKey(name: 'dropoff_location')
  LatLngPoint? get dropoffLocation;
  @override
  @JsonKey(name: 'problem_description')
  String? get problemDescription;
  @override
  @JsonKey(name: 'estimated_fare')
  String? get estimatedFare;
  @override
  @JsonKey(name: 'final_fare')
  String? get finalFare;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of ServiceRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceRequestDtoImplCopyWith<_$ServiceRequestDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
