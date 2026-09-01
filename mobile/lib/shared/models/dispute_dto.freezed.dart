// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DisputeServiceRequestSummary _$DisputeServiceRequestSummaryFromJson(
  Map<String, dynamic> json,
) {
  return _DisputeServiceRequestSummary.fromJson(json);
}

/// @nodoc
mixin _$DisputeServiceRequestSummary {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_type')
  String get serviceType => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String? get customerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'provider_name')
  String? get providerName => throw _privateConstructorUsedError;

  /// Serializes this DisputeServiceRequestSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DisputeServiceRequestSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisputeServiceRequestSummaryCopyWith<DisputeServiceRequestSummary>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisputeServiceRequestSummaryCopyWith<$Res> {
  factory $DisputeServiceRequestSummaryCopyWith(
    DisputeServiceRequestSummary value,
    $Res Function(DisputeServiceRequestSummary) then,
  ) =
      _$DisputeServiceRequestSummaryCopyWithImpl<
        $Res,
        DisputeServiceRequestSummary
      >;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'service_type') String serviceType,
    String status,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'provider_name') String? providerName,
  });
}

/// @nodoc
class _$DisputeServiceRequestSummaryCopyWithImpl<
  $Res,
  $Val extends DisputeServiceRequestSummary
>
    implements $DisputeServiceRequestSummaryCopyWith<$Res> {
  _$DisputeServiceRequestSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DisputeServiceRequestSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceType = null,
    Object? status = null,
    Object? customerName = freezed,
    Object? providerName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceType: null == serviceType
                ? _value.serviceType
                : serviceType // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            providerName: freezed == providerName
                ? _value.providerName
                : providerName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DisputeServiceRequestSummaryImplCopyWith<$Res>
    implements $DisputeServiceRequestSummaryCopyWith<$Res> {
  factory _$$DisputeServiceRequestSummaryImplCopyWith(
    _$DisputeServiceRequestSummaryImpl value,
    $Res Function(_$DisputeServiceRequestSummaryImpl) then,
  ) = __$$DisputeServiceRequestSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'service_type') String serviceType,
    String status,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'provider_name') String? providerName,
  });
}

/// @nodoc
class __$$DisputeServiceRequestSummaryImplCopyWithImpl<$Res>
    extends
        _$DisputeServiceRequestSummaryCopyWithImpl<
          $Res,
          _$DisputeServiceRequestSummaryImpl
        >
    implements _$$DisputeServiceRequestSummaryImplCopyWith<$Res> {
  __$$DisputeServiceRequestSummaryImplCopyWithImpl(
    _$DisputeServiceRequestSummaryImpl _value,
    $Res Function(_$DisputeServiceRequestSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DisputeServiceRequestSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceType = null,
    Object? status = null,
    Object? customerName = freezed,
    Object? providerName = freezed,
  }) {
    return _then(
      _$DisputeServiceRequestSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceType: null == serviceType
            ? _value.serviceType
            : serviceType // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        providerName: freezed == providerName
            ? _value.providerName
            : providerName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DisputeServiceRequestSummaryImpl
    implements _DisputeServiceRequestSummary {
  const _$DisputeServiceRequestSummaryImpl({
    required this.id,
    @JsonKey(name: 'service_type') required this.serviceType,
    required this.status,
    @JsonKey(name: 'customer_name') this.customerName,
    @JsonKey(name: 'provider_name') this.providerName,
  });

  factory _$DisputeServiceRequestSummaryImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$DisputeServiceRequestSummaryImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'service_type')
  final String serviceType;
  @override
  final String status;
  @override
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @override
  @JsonKey(name: 'provider_name')
  final String? providerName;

  @override
  String toString() {
    return 'DisputeServiceRequestSummary(id: $id, serviceType: $serviceType, status: $status, customerName: $customerName, providerName: $providerName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisputeServiceRequestSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serviceType, serviceType) ||
                other.serviceType == serviceType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.providerName, providerName) ||
                other.providerName == providerName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    serviceType,
    status,
    customerName,
    providerName,
  );

  /// Create a copy of DisputeServiceRequestSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisputeServiceRequestSummaryImplCopyWith<
    _$DisputeServiceRequestSummaryImpl
  >
  get copyWith =>
      __$$DisputeServiceRequestSummaryImplCopyWithImpl<
        _$DisputeServiceRequestSummaryImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisputeServiceRequestSummaryImplToJson(this);
  }
}

abstract class _DisputeServiceRequestSummary
    implements DisputeServiceRequestSummary {
  const factory _DisputeServiceRequestSummary({
    required final String id,
    @JsonKey(name: 'service_type') required final String serviceType,
    required final String status,
    @JsonKey(name: 'customer_name') final String? customerName,
    @JsonKey(name: 'provider_name') final String? providerName,
  }) = _$DisputeServiceRequestSummaryImpl;

  factory _DisputeServiceRequestSummary.fromJson(Map<String, dynamic> json) =
      _$DisputeServiceRequestSummaryImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'service_type')
  String get serviceType;
  @override
  String get status;
  @override
  @JsonKey(name: 'customer_name')
  String? get customerName;
  @override
  @JsonKey(name: 'provider_name')
  String? get providerName;

  /// Create a copy of DisputeServiceRequestSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisputeServiceRequestSummaryImplCopyWith<
    _$DisputeServiceRequestSummaryImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

DisputeDto _$DisputeDtoFromJson(Map<String, dynamic> json) {
  return _DisputeDto.fromJson(json);
}

/// @nodoc
mixin _$DisputeDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_request')
  String get serviceRequest => throw _privateConstructorUsedError;
  @JsonKey(name: 'raised_by')
  String? get raisedBy => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  DisputeStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_request_summary')
  DisputeServiceRequestSummary? get serviceRequestSummary =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'raised_by_name')
  String? get raisedByName => throw _privateConstructorUsedError;
  @JsonKey(name: 'raised_by_email')
  String? get raisedByEmail => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_by_name')
  String? get resolvedByName => throw _privateConstructorUsedError;

  /// Serializes this DisputeDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DisputeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisputeDtoCopyWith<DisputeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisputeDtoCopyWith<$Res> {
  factory $DisputeDtoCopyWith(
    DisputeDto value,
    $Res Function(DisputeDto) then,
  ) = _$DisputeDtoCopyWithImpl<$Res, DisputeDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'service_request') String serviceRequest,
    @JsonKey(name: 'raised_by') String? raisedBy,
    String? reason,
    DisputeStatus status,
    @JsonKey(name: 'resolved_by') String? resolvedBy,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'service_request_summary')
    DisputeServiceRequestSummary? serviceRequestSummary,
    @JsonKey(name: 'raised_by_name') String? raisedByName,
    @JsonKey(name: 'raised_by_email') String? raisedByEmail,
    @JsonKey(name: 'resolved_by_name') String? resolvedByName,
  });

  $DisputeServiceRequestSummaryCopyWith<$Res>? get serviceRequestSummary;
}

/// @nodoc
class _$DisputeDtoCopyWithImpl<$Res, $Val extends DisputeDto>
    implements $DisputeDtoCopyWith<$Res> {
  _$DisputeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DisputeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceRequest = null,
    Object? raisedBy = freezed,
    Object? reason = freezed,
    Object? status = null,
    Object? resolvedBy = freezed,
    Object? createdAt = null,
    Object? serviceRequestSummary = freezed,
    Object? raisedByName = freezed,
    Object? raisedByEmail = freezed,
    Object? resolvedByName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceRequest: null == serviceRequest
                ? _value.serviceRequest
                : serviceRequest // ignore: cast_nullable_to_non_nullable
                      as String,
            raisedBy: freezed == raisedBy
                ? _value.raisedBy
                : raisedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as DisputeStatus,
            resolvedBy: freezed == resolvedBy
                ? _value.resolvedBy
                : resolvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceRequestSummary: freezed == serviceRequestSummary
                ? _value.serviceRequestSummary
                : serviceRequestSummary // ignore: cast_nullable_to_non_nullable
                      as DisputeServiceRequestSummary?,
            raisedByName: freezed == raisedByName
                ? _value.raisedByName
                : raisedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            raisedByEmail: freezed == raisedByEmail
                ? _value.raisedByEmail
                : raisedByEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolvedByName: freezed == resolvedByName
                ? _value.resolvedByName
                : resolvedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of DisputeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DisputeServiceRequestSummaryCopyWith<$Res>? get serviceRequestSummary {
    if (_value.serviceRequestSummary == null) {
      return null;
    }

    return $DisputeServiceRequestSummaryCopyWith<$Res>(
      _value.serviceRequestSummary!,
      (value) {
        return _then(_value.copyWith(serviceRequestSummary: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$DisputeDtoImplCopyWith<$Res>
    implements $DisputeDtoCopyWith<$Res> {
  factory _$$DisputeDtoImplCopyWith(
    _$DisputeDtoImpl value,
    $Res Function(_$DisputeDtoImpl) then,
  ) = __$$DisputeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'service_request') String serviceRequest,
    @JsonKey(name: 'raised_by') String? raisedBy,
    String? reason,
    DisputeStatus status,
    @JsonKey(name: 'resolved_by') String? resolvedBy,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'service_request_summary')
    DisputeServiceRequestSummary? serviceRequestSummary,
    @JsonKey(name: 'raised_by_name') String? raisedByName,
    @JsonKey(name: 'raised_by_email') String? raisedByEmail,
    @JsonKey(name: 'resolved_by_name') String? resolvedByName,
  });

  @override
  $DisputeServiceRequestSummaryCopyWith<$Res>? get serviceRequestSummary;
}

/// @nodoc
class __$$DisputeDtoImplCopyWithImpl<$Res>
    extends _$DisputeDtoCopyWithImpl<$Res, _$DisputeDtoImpl>
    implements _$$DisputeDtoImplCopyWith<$Res> {
  __$$DisputeDtoImplCopyWithImpl(
    _$DisputeDtoImpl _value,
    $Res Function(_$DisputeDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DisputeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceRequest = null,
    Object? raisedBy = freezed,
    Object? reason = freezed,
    Object? status = null,
    Object? resolvedBy = freezed,
    Object? createdAt = null,
    Object? serviceRequestSummary = freezed,
    Object? raisedByName = freezed,
    Object? raisedByEmail = freezed,
    Object? resolvedByName = freezed,
  }) {
    return _then(
      _$DisputeDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceRequest: null == serviceRequest
            ? _value.serviceRequest
            : serviceRequest // ignore: cast_nullable_to_non_nullable
                  as String,
        raisedBy: freezed == raisedBy
            ? _value.raisedBy
            : raisedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as DisputeStatus,
        resolvedBy: freezed == resolvedBy
            ? _value.resolvedBy
            : resolvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceRequestSummary: freezed == serviceRequestSummary
            ? _value.serviceRequestSummary
            : serviceRequestSummary // ignore: cast_nullable_to_non_nullable
                  as DisputeServiceRequestSummary?,
        raisedByName: freezed == raisedByName
            ? _value.raisedByName
            : raisedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        raisedByEmail: freezed == raisedByEmail
            ? _value.raisedByEmail
            : raisedByEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolvedByName: freezed == resolvedByName
            ? _value.resolvedByName
            : resolvedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DisputeDtoImpl implements _DisputeDto {
  const _$DisputeDtoImpl({
    required this.id,
    @JsonKey(name: 'service_request') required this.serviceRequest,
    @JsonKey(name: 'raised_by') this.raisedBy,
    this.reason,
    required this.status,
    @JsonKey(name: 'resolved_by') this.resolvedBy,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'service_request_summary') this.serviceRequestSummary,
    @JsonKey(name: 'raised_by_name') this.raisedByName,
    @JsonKey(name: 'raised_by_email') this.raisedByEmail,
    @JsonKey(name: 'resolved_by_name') this.resolvedByName,
  });

  factory _$DisputeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisputeDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'service_request')
  final String serviceRequest;
  @override
  @JsonKey(name: 'raised_by')
  final String? raisedBy;
  @override
  final String? reason;
  @override
  final DisputeStatus status;
  @override
  @JsonKey(name: 'resolved_by')
  final String? resolvedBy;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'service_request_summary')
  final DisputeServiceRequestSummary? serviceRequestSummary;
  @override
  @JsonKey(name: 'raised_by_name')
  final String? raisedByName;
  @override
  @JsonKey(name: 'raised_by_email')
  final String? raisedByEmail;
  @override
  @JsonKey(name: 'resolved_by_name')
  final String? resolvedByName;

  @override
  String toString() {
    return 'DisputeDto(id: $id, serviceRequest: $serviceRequest, raisedBy: $raisedBy, reason: $reason, status: $status, resolvedBy: $resolvedBy, createdAt: $createdAt, serviceRequestSummary: $serviceRequestSummary, raisedByName: $raisedByName, raisedByEmail: $raisedByEmail, resolvedByName: $resolvedByName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisputeDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serviceRequest, serviceRequest) ||
                other.serviceRequest == serviceRequest) &&
            (identical(other.raisedBy, raisedBy) ||
                other.raisedBy == raisedBy) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.serviceRequestSummary, serviceRequestSummary) ||
                other.serviceRequestSummary == serviceRequestSummary) &&
            (identical(other.raisedByName, raisedByName) ||
                other.raisedByName == raisedByName) &&
            (identical(other.raisedByEmail, raisedByEmail) ||
                other.raisedByEmail == raisedByEmail) &&
            (identical(other.resolvedByName, resolvedByName) ||
                other.resolvedByName == resolvedByName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    serviceRequest,
    raisedBy,
    reason,
    status,
    resolvedBy,
    createdAt,
    serviceRequestSummary,
    raisedByName,
    raisedByEmail,
    resolvedByName,
  );

  /// Create a copy of DisputeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisputeDtoImplCopyWith<_$DisputeDtoImpl> get copyWith =>
      __$$DisputeDtoImplCopyWithImpl<_$DisputeDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisputeDtoImplToJson(this);
  }
}

abstract class _DisputeDto implements DisputeDto {
  const factory _DisputeDto({
    required final String id,
    @JsonKey(name: 'service_request') required final String serviceRequest,
    @JsonKey(name: 'raised_by') final String? raisedBy,
    final String? reason,
    required final DisputeStatus status,
    @JsonKey(name: 'resolved_by') final String? resolvedBy,
    @JsonKey(name: 'created_at') required final String createdAt,
    @JsonKey(name: 'service_request_summary')
    final DisputeServiceRequestSummary? serviceRequestSummary,
    @JsonKey(name: 'raised_by_name') final String? raisedByName,
    @JsonKey(name: 'raised_by_email') final String? raisedByEmail,
    @JsonKey(name: 'resolved_by_name') final String? resolvedByName,
  }) = _$DisputeDtoImpl;

  factory _DisputeDto.fromJson(Map<String, dynamic> json) =
      _$DisputeDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'service_request')
  String get serviceRequest;
  @override
  @JsonKey(name: 'raised_by')
  String? get raisedBy;
  @override
  String? get reason;
  @override
  DisputeStatus get status;
  @override
  @JsonKey(name: 'resolved_by')
  String? get resolvedBy;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'service_request_summary')
  DisputeServiceRequestSummary? get serviceRequestSummary;
  @override
  @JsonKey(name: 'raised_by_name')
  String? get raisedByName;
  @override
  @JsonKey(name: 'raised_by_email')
  String? get raisedByEmail;
  @override
  @JsonKey(name: 'resolved_by_name')
  String? get resolvedByName;

  /// Create a copy of DisputeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisputeDtoImplCopyWith<_$DisputeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
