// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_analytics_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AdminAnalyticsDto _$AdminAnalyticsDtoFromJson(Map<String, dynamic> json) {
  return _AdminAnalyticsDto.fromJson(json);
}

/// @nodoc
mixin _$AdminAnalyticsDto {
  @JsonKey(name: 'orders_by_status')
  Map<String, int> get ordersByStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_requests_by_status')
  Map<String, int> get serviceRequestsByStatus =>
      throw _privateConstructorUsedError;
  String get revenue => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_providers')
  int get activeProviders => throw _privateConstructorUsedError;
  @JsonKey(name: 'open_disputes')
  int get openDisputes => throw _privateConstructorUsedError;
  @JsonKey(name: 'failed_notifications_recent')
  int get failedNotificationsRecent => throw _privateConstructorUsedError;
  @JsonKey(name: 'failed_payments_recent')
  int get failedPaymentsRecent => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_alert')
  bool get hasAlert => throw _privateConstructorUsedError;

  /// Serializes this AdminAnalyticsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminAnalyticsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminAnalyticsDtoCopyWith<AdminAnalyticsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminAnalyticsDtoCopyWith<$Res> {
  factory $AdminAnalyticsDtoCopyWith(
    AdminAnalyticsDto value,
    $Res Function(AdminAnalyticsDto) then,
  ) = _$AdminAnalyticsDtoCopyWithImpl<$Res, AdminAnalyticsDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'orders_by_status') Map<String, int> ordersByStatus,
    @JsonKey(name: 'service_requests_by_status')
    Map<String, int> serviceRequestsByStatus,
    String revenue,
    @JsonKey(name: 'active_providers') int activeProviders,
    @JsonKey(name: 'open_disputes') int openDisputes,
    @JsonKey(name: 'failed_notifications_recent') int failedNotificationsRecent,
    @JsonKey(name: 'failed_payments_recent') int failedPaymentsRecent,
    @JsonKey(name: 'has_alert') bool hasAlert,
  });
}

/// @nodoc
class _$AdminAnalyticsDtoCopyWithImpl<$Res, $Val extends AdminAnalyticsDto>
    implements $AdminAnalyticsDtoCopyWith<$Res> {
  _$AdminAnalyticsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminAnalyticsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ordersByStatus = null,
    Object? serviceRequestsByStatus = null,
    Object? revenue = null,
    Object? activeProviders = null,
    Object? openDisputes = null,
    Object? failedNotificationsRecent = null,
    Object? failedPaymentsRecent = null,
    Object? hasAlert = null,
  }) {
    return _then(
      _value.copyWith(
            ordersByStatus: null == ordersByStatus
                ? _value.ordersByStatus
                : ordersByStatus // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            serviceRequestsByStatus: null == serviceRequestsByStatus
                ? _value.serviceRequestsByStatus
                : serviceRequestsByStatus // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as String,
            activeProviders: null == activeProviders
                ? _value.activeProviders
                : activeProviders // ignore: cast_nullable_to_non_nullable
                      as int,
            openDisputes: null == openDisputes
                ? _value.openDisputes
                : openDisputes // ignore: cast_nullable_to_non_nullable
                      as int,
            failedNotificationsRecent: null == failedNotificationsRecent
                ? _value.failedNotificationsRecent
                : failedNotificationsRecent // ignore: cast_nullable_to_non_nullable
                      as int,
            failedPaymentsRecent: null == failedPaymentsRecent
                ? _value.failedPaymentsRecent
                : failedPaymentsRecent // ignore: cast_nullable_to_non_nullable
                      as int,
            hasAlert: null == hasAlert
                ? _value.hasAlert
                : hasAlert // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminAnalyticsDtoImplCopyWith<$Res>
    implements $AdminAnalyticsDtoCopyWith<$Res> {
  factory _$$AdminAnalyticsDtoImplCopyWith(
    _$AdminAnalyticsDtoImpl value,
    $Res Function(_$AdminAnalyticsDtoImpl) then,
  ) = __$$AdminAnalyticsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'orders_by_status') Map<String, int> ordersByStatus,
    @JsonKey(name: 'service_requests_by_status')
    Map<String, int> serviceRequestsByStatus,
    String revenue,
    @JsonKey(name: 'active_providers') int activeProviders,
    @JsonKey(name: 'open_disputes') int openDisputes,
    @JsonKey(name: 'failed_notifications_recent') int failedNotificationsRecent,
    @JsonKey(name: 'failed_payments_recent') int failedPaymentsRecent,
    @JsonKey(name: 'has_alert') bool hasAlert,
  });
}

/// @nodoc
class __$$AdminAnalyticsDtoImplCopyWithImpl<$Res>
    extends _$AdminAnalyticsDtoCopyWithImpl<$Res, _$AdminAnalyticsDtoImpl>
    implements _$$AdminAnalyticsDtoImplCopyWith<$Res> {
  __$$AdminAnalyticsDtoImplCopyWithImpl(
    _$AdminAnalyticsDtoImpl _value,
    $Res Function(_$AdminAnalyticsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminAnalyticsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ordersByStatus = null,
    Object? serviceRequestsByStatus = null,
    Object? revenue = null,
    Object? activeProviders = null,
    Object? openDisputes = null,
    Object? failedNotificationsRecent = null,
    Object? failedPaymentsRecent = null,
    Object? hasAlert = null,
  }) {
    return _then(
      _$AdminAnalyticsDtoImpl(
        ordersByStatus: null == ordersByStatus
            ? _value._ordersByStatus
            : ordersByStatus // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        serviceRequestsByStatus: null == serviceRequestsByStatus
            ? _value._serviceRequestsByStatus
            : serviceRequestsByStatus // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as String,
        activeProviders: null == activeProviders
            ? _value.activeProviders
            : activeProviders // ignore: cast_nullable_to_non_nullable
                  as int,
        openDisputes: null == openDisputes
            ? _value.openDisputes
            : openDisputes // ignore: cast_nullable_to_non_nullable
                  as int,
        failedNotificationsRecent: null == failedNotificationsRecent
            ? _value.failedNotificationsRecent
            : failedNotificationsRecent // ignore: cast_nullable_to_non_nullable
                  as int,
        failedPaymentsRecent: null == failedPaymentsRecent
            ? _value.failedPaymentsRecent
            : failedPaymentsRecent // ignore: cast_nullable_to_non_nullable
                  as int,
        hasAlert: null == hasAlert
            ? _value.hasAlert
            : hasAlert // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminAnalyticsDtoImpl implements _AdminAnalyticsDto {
  const _$AdminAnalyticsDtoImpl({
    @JsonKey(name: 'orders_by_status')
    required final Map<String, int> ordersByStatus,
    @JsonKey(name: 'service_requests_by_status')
    required final Map<String, int> serviceRequestsByStatus,
    required this.revenue,
    @JsonKey(name: 'active_providers') required this.activeProviders,
    @JsonKey(name: 'open_disputes') required this.openDisputes,
    @JsonKey(name: 'failed_notifications_recent')
    required this.failedNotificationsRecent,
    @JsonKey(name: 'failed_payments_recent') required this.failedPaymentsRecent,
    @JsonKey(name: 'has_alert') required this.hasAlert,
  }) : _ordersByStatus = ordersByStatus,
       _serviceRequestsByStatus = serviceRequestsByStatus;

  factory _$AdminAnalyticsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminAnalyticsDtoImplFromJson(json);

  final Map<String, int> _ordersByStatus;
  @override
  @JsonKey(name: 'orders_by_status')
  Map<String, int> get ordersByStatus {
    if (_ordersByStatus is EqualUnmodifiableMapView) return _ordersByStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_ordersByStatus);
  }

  final Map<String, int> _serviceRequestsByStatus;
  @override
  @JsonKey(name: 'service_requests_by_status')
  Map<String, int> get serviceRequestsByStatus {
    if (_serviceRequestsByStatus is EqualUnmodifiableMapView)
      return _serviceRequestsByStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_serviceRequestsByStatus);
  }

  @override
  final String revenue;
  @override
  @JsonKey(name: 'active_providers')
  final int activeProviders;
  @override
  @JsonKey(name: 'open_disputes')
  final int openDisputes;
  @override
  @JsonKey(name: 'failed_notifications_recent')
  final int failedNotificationsRecent;
  @override
  @JsonKey(name: 'failed_payments_recent')
  final int failedPaymentsRecent;
  @override
  @JsonKey(name: 'has_alert')
  final bool hasAlert;

  @override
  String toString() {
    return 'AdminAnalyticsDto(ordersByStatus: $ordersByStatus, serviceRequestsByStatus: $serviceRequestsByStatus, revenue: $revenue, activeProviders: $activeProviders, openDisputes: $openDisputes, failedNotificationsRecent: $failedNotificationsRecent, failedPaymentsRecent: $failedPaymentsRecent, hasAlert: $hasAlert)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminAnalyticsDtoImpl &&
            const DeepCollectionEquality().equals(
              other._ordersByStatus,
              _ordersByStatus,
            ) &&
            const DeepCollectionEquality().equals(
              other._serviceRequestsByStatus,
              _serviceRequestsByStatus,
            ) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.activeProviders, activeProviders) ||
                other.activeProviders == activeProviders) &&
            (identical(other.openDisputes, openDisputes) ||
                other.openDisputes == openDisputes) &&
            (identical(
                  other.failedNotificationsRecent,
                  failedNotificationsRecent,
                ) ||
                other.failedNotificationsRecent == failedNotificationsRecent) &&
            (identical(other.failedPaymentsRecent, failedPaymentsRecent) ||
                other.failedPaymentsRecent == failedPaymentsRecent) &&
            (identical(other.hasAlert, hasAlert) ||
                other.hasAlert == hasAlert));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_ordersByStatus),
    const DeepCollectionEquality().hash(_serviceRequestsByStatus),
    revenue,
    activeProviders,
    openDisputes,
    failedNotificationsRecent,
    failedPaymentsRecent,
    hasAlert,
  );

  /// Create a copy of AdminAnalyticsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminAnalyticsDtoImplCopyWith<_$AdminAnalyticsDtoImpl> get copyWith =>
      __$$AdminAnalyticsDtoImplCopyWithImpl<_$AdminAnalyticsDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminAnalyticsDtoImplToJson(this);
  }
}

abstract class _AdminAnalyticsDto implements AdminAnalyticsDto {
  const factory _AdminAnalyticsDto({
    @JsonKey(name: 'orders_by_status')
    required final Map<String, int> ordersByStatus,
    @JsonKey(name: 'service_requests_by_status')
    required final Map<String, int> serviceRequestsByStatus,
    required final String revenue,
    @JsonKey(name: 'active_providers') required final int activeProviders,
    @JsonKey(name: 'open_disputes') required final int openDisputes,
    @JsonKey(name: 'failed_notifications_recent')
    required final int failedNotificationsRecent,
    @JsonKey(name: 'failed_payments_recent')
    required final int failedPaymentsRecent,
    @JsonKey(name: 'has_alert') required final bool hasAlert,
  }) = _$AdminAnalyticsDtoImpl;

  factory _AdminAnalyticsDto.fromJson(Map<String, dynamic> json) =
      _$AdminAnalyticsDtoImpl.fromJson;

  @override
  @JsonKey(name: 'orders_by_status')
  Map<String, int> get ordersByStatus;
  @override
  @JsonKey(name: 'service_requests_by_status')
  Map<String, int> get serviceRequestsByStatus;
  @override
  String get revenue;
  @override
  @JsonKey(name: 'active_providers')
  int get activeProviders;
  @override
  @JsonKey(name: 'open_disputes')
  int get openDisputes;
  @override
  @JsonKey(name: 'failed_notifications_recent')
  int get failedNotificationsRecent;
  @override
  @JsonKey(name: 'failed_payments_recent')
  int get failedPaymentsRecent;
  @override
  @JsonKey(name: 'has_alert')
  bool get hasAlert;

  /// Create a copy of AdminAnalyticsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminAnalyticsDtoImplCopyWith<_$AdminAnalyticsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
