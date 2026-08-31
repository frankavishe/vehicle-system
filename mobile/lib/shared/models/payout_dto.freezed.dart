// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payout_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PayoutItemDto _$PayoutItemDtoFromJson(Map<String, dynamic> json) {
  return _PayoutItemDto.fromJson(json);
}

/// @nodoc
mixin _$PayoutItemDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_request')
  String? get serviceRequest => throw _privateConstructorUsedError;
  String get amount => throw _privateConstructorUsedError;

  /// Serializes this PayoutItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayoutItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayoutItemDtoCopyWith<PayoutItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayoutItemDtoCopyWith<$Res> {
  factory $PayoutItemDtoCopyWith(
    PayoutItemDto value,
    $Res Function(PayoutItemDto) then,
  ) = _$PayoutItemDtoCopyWithImpl<$Res, PayoutItemDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'service_request') String? serviceRequest,
    String amount,
  });
}

/// @nodoc
class _$PayoutItemDtoCopyWithImpl<$Res, $Val extends PayoutItemDto>
    implements $PayoutItemDtoCopyWith<$Res> {
  _$PayoutItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayoutItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceRequest = freezed,
    Object? amount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceRequest: freezed == serviceRequest
                ? _value.serviceRequest
                : serviceRequest // ignore: cast_nullable_to_non_nullable
                      as String?,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PayoutItemDtoImplCopyWith<$Res>
    implements $PayoutItemDtoCopyWith<$Res> {
  factory _$$PayoutItemDtoImplCopyWith(
    _$PayoutItemDtoImpl value,
    $Res Function(_$PayoutItemDtoImpl) then,
  ) = __$$PayoutItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'service_request') String? serviceRequest,
    String amount,
  });
}

/// @nodoc
class __$$PayoutItemDtoImplCopyWithImpl<$Res>
    extends _$PayoutItemDtoCopyWithImpl<$Res, _$PayoutItemDtoImpl>
    implements _$$PayoutItemDtoImplCopyWith<$Res> {
  __$$PayoutItemDtoImplCopyWithImpl(
    _$PayoutItemDtoImpl _value,
    $Res Function(_$PayoutItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PayoutItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceRequest = freezed,
    Object? amount = null,
  }) {
    return _then(
      _$PayoutItemDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceRequest: freezed == serviceRequest
            ? _value.serviceRequest
            : serviceRequest // ignore: cast_nullable_to_non_nullable
                  as String?,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PayoutItemDtoImpl implements _PayoutItemDto {
  const _$PayoutItemDtoImpl({
    required this.id,
    @JsonKey(name: 'service_request') this.serviceRequest,
    required this.amount,
  });

  factory _$PayoutItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayoutItemDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'service_request')
  final String? serviceRequest;
  @override
  final String amount;

  @override
  String toString() {
    return 'PayoutItemDto(id: $id, serviceRequest: $serviceRequest, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayoutItemDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serviceRequest, serviceRequest) ||
                other.serviceRequest == serviceRequest) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, serviceRequest, amount);

  /// Create a copy of PayoutItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayoutItemDtoImplCopyWith<_$PayoutItemDtoImpl> get copyWith =>
      __$$PayoutItemDtoImplCopyWithImpl<_$PayoutItemDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayoutItemDtoImplToJson(this);
  }
}

abstract class _PayoutItemDto implements PayoutItemDto {
  const factory _PayoutItemDto({
    required final String id,
    @JsonKey(name: 'service_request') final String? serviceRequest,
    required final String amount,
  }) = _$PayoutItemDtoImpl;

  factory _PayoutItemDto.fromJson(Map<String, dynamic> json) =
      _$PayoutItemDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'service_request')
  String? get serviceRequest;
  @override
  String get amount;

  /// Create a copy of PayoutItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayoutItemDtoImplCopyWith<_$PayoutItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PayoutDto _$PayoutDtoFromJson(Map<String, dynamic> json) {
  return _PayoutDto.fromJson(json);
}

/// @nodoc
mixin _$PayoutDto {
  String get id => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  String get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_start')
  String? get periodStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_end')
  String? get periodEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_manual')
  bool get isManual => throw _privateConstructorUsedError;
  @JsonKey(name: 'provider_gateway')
  String get providerGateway => throw _privateConstructorUsedError;
  @JsonKey(name: 'gateway_transaction_id')
  String? get gatewayTransactionId => throw _privateConstructorUsedError;
  PayoutStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_at')
  String? get paidAt => throw _privateConstructorUsedError;
  List<PayoutItemDto> get items => throw _privateConstructorUsedError;

  /// Serializes this PayoutDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayoutDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayoutDtoCopyWith<PayoutDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayoutDtoCopyWith<$Res> {
  factory $PayoutDtoCopyWith(PayoutDto value, $Res Function(PayoutDto) then) =
      _$PayoutDtoCopyWithImpl<$Res, PayoutDto>;
  @useResult
  $Res call({
    String id,
    String provider,
    String amount,
    @JsonKey(name: 'period_start') String? periodStart,
    @JsonKey(name: 'period_end') String? periodEnd,
    @JsonKey(name: 'is_manual') bool isManual,
    @JsonKey(name: 'provider_gateway') String providerGateway,
    @JsonKey(name: 'gateway_transaction_id') String? gatewayTransactionId,
    PayoutStatus status,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'paid_at') String? paidAt,
    List<PayoutItemDto> items,
  });
}

/// @nodoc
class _$PayoutDtoCopyWithImpl<$Res, $Val extends PayoutDto>
    implements $PayoutDtoCopyWith<$Res> {
  _$PayoutDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayoutDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? provider = null,
    Object? amount = null,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
    Object? isManual = null,
    Object? providerGateway = null,
    Object? gatewayTransactionId = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? paidAt = freezed,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as String,
            periodStart: freezed == periodStart
                ? _value.periodStart
                : periodStart // ignore: cast_nullable_to_non_nullable
                      as String?,
            periodEnd: freezed == periodEnd
                ? _value.periodEnd
                : periodEnd // ignore: cast_nullable_to_non_nullable
                      as String?,
            isManual: null == isManual
                ? _value.isManual
                : isManual // ignore: cast_nullable_to_non_nullable
                      as bool,
            providerGateway: null == providerGateway
                ? _value.providerGateway
                : providerGateway // ignore: cast_nullable_to_non_nullable
                      as String,
            gatewayTransactionId: freezed == gatewayTransactionId
                ? _value.gatewayTransactionId
                : gatewayTransactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PayoutStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            paidAt: freezed == paidAt
                ? _value.paidAt
                : paidAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<PayoutItemDto>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PayoutDtoImplCopyWith<$Res>
    implements $PayoutDtoCopyWith<$Res> {
  factory _$$PayoutDtoImplCopyWith(
    _$PayoutDtoImpl value,
    $Res Function(_$PayoutDtoImpl) then,
  ) = __$$PayoutDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String provider,
    String amount,
    @JsonKey(name: 'period_start') String? periodStart,
    @JsonKey(name: 'period_end') String? periodEnd,
    @JsonKey(name: 'is_manual') bool isManual,
    @JsonKey(name: 'provider_gateway') String providerGateway,
    @JsonKey(name: 'gateway_transaction_id') String? gatewayTransactionId,
    PayoutStatus status,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'paid_at') String? paidAt,
    List<PayoutItemDto> items,
  });
}

/// @nodoc
class __$$PayoutDtoImplCopyWithImpl<$Res>
    extends _$PayoutDtoCopyWithImpl<$Res, _$PayoutDtoImpl>
    implements _$$PayoutDtoImplCopyWith<$Res> {
  __$$PayoutDtoImplCopyWithImpl(
    _$PayoutDtoImpl _value,
    $Res Function(_$PayoutDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PayoutDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? provider = null,
    Object? amount = null,
    Object? periodStart = freezed,
    Object? periodEnd = freezed,
    Object? isManual = null,
    Object? providerGateway = null,
    Object? gatewayTransactionId = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? paidAt = freezed,
    Object? items = null,
  }) {
    return _then(
      _$PayoutDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as String,
        periodStart: freezed == periodStart
            ? _value.periodStart
            : periodStart // ignore: cast_nullable_to_non_nullable
                  as String?,
        periodEnd: freezed == periodEnd
            ? _value.periodEnd
            : periodEnd // ignore: cast_nullable_to_non_nullable
                  as String?,
        isManual: null == isManual
            ? _value.isManual
            : isManual // ignore: cast_nullable_to_non_nullable
                  as bool,
        providerGateway: null == providerGateway
            ? _value.providerGateway
            : providerGateway // ignore: cast_nullable_to_non_nullable
                  as String,
        gatewayTransactionId: freezed == gatewayTransactionId
            ? _value.gatewayTransactionId
            : gatewayTransactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PayoutStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        paidAt: freezed == paidAt
            ? _value.paidAt
            : paidAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<PayoutItemDto>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PayoutDtoImpl implements _PayoutDto {
  const _$PayoutDtoImpl({
    required this.id,
    required this.provider,
    required this.amount,
    @JsonKey(name: 'period_start') this.periodStart,
    @JsonKey(name: 'period_end') this.periodEnd,
    @JsonKey(name: 'is_manual') required this.isManual,
    @JsonKey(name: 'provider_gateway') required this.providerGateway,
    @JsonKey(name: 'gateway_transaction_id') this.gatewayTransactionId,
    required this.status,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'paid_at') this.paidAt,
    required final List<PayoutItemDto> items,
  }) : _items = items;

  factory _$PayoutDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayoutDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String provider;
  @override
  final String amount;
  @override
  @JsonKey(name: 'period_start')
  final String? periodStart;
  @override
  @JsonKey(name: 'period_end')
  final String? periodEnd;
  @override
  @JsonKey(name: 'is_manual')
  final bool isManual;
  @override
  @JsonKey(name: 'provider_gateway')
  final String providerGateway;
  @override
  @JsonKey(name: 'gateway_transaction_id')
  final String? gatewayTransactionId;
  @override
  final PayoutStatus status;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'paid_at')
  final String? paidAt;
  final List<PayoutItemDto> _items;
  @override
  List<PayoutItemDto> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'PayoutDto(id: $id, provider: $provider, amount: $amount, periodStart: $periodStart, periodEnd: $periodEnd, isManual: $isManual, providerGateway: $providerGateway, gatewayTransactionId: $gatewayTransactionId, status: $status, createdAt: $createdAt, paidAt: $paidAt, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayoutDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.isManual, isManual) ||
                other.isManual == isManual) &&
            (identical(other.providerGateway, providerGateway) ||
                other.providerGateway == providerGateway) &&
            (identical(other.gatewayTransactionId, gatewayTransactionId) ||
                other.gatewayTransactionId == gatewayTransactionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    provider,
    amount,
    periodStart,
    periodEnd,
    isManual,
    providerGateway,
    gatewayTransactionId,
    status,
    createdAt,
    paidAt,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of PayoutDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayoutDtoImplCopyWith<_$PayoutDtoImpl> get copyWith =>
      __$$PayoutDtoImplCopyWithImpl<_$PayoutDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayoutDtoImplToJson(this);
  }
}

abstract class _PayoutDto implements PayoutDto {
  const factory _PayoutDto({
    required final String id,
    required final String provider,
    required final String amount,
    @JsonKey(name: 'period_start') final String? periodStart,
    @JsonKey(name: 'period_end') final String? periodEnd,
    @JsonKey(name: 'is_manual') required final bool isManual,
    @JsonKey(name: 'provider_gateway') required final String providerGateway,
    @JsonKey(name: 'gateway_transaction_id') final String? gatewayTransactionId,
    required final PayoutStatus status,
    @JsonKey(name: 'created_at') required final String createdAt,
    @JsonKey(name: 'paid_at') final String? paidAt,
    required final List<PayoutItemDto> items,
  }) = _$PayoutDtoImpl;

  factory _PayoutDto.fromJson(Map<String, dynamic> json) =
      _$PayoutDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get provider;
  @override
  String get amount;
  @override
  @JsonKey(name: 'period_start')
  String? get periodStart;
  @override
  @JsonKey(name: 'period_end')
  String? get periodEnd;
  @override
  @JsonKey(name: 'is_manual')
  bool get isManual;
  @override
  @JsonKey(name: 'provider_gateway')
  String get providerGateway;
  @override
  @JsonKey(name: 'gateway_transaction_id')
  String? get gatewayTransactionId;
  @override
  PayoutStatus get status;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'paid_at')
  String? get paidAt;
  @override
  List<PayoutItemDto> get items;

  /// Create a copy of PayoutDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayoutDtoImplCopyWith<_$PayoutDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
