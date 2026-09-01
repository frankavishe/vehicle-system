// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_analytics_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminAnalyticsDtoImpl _$$AdminAnalyticsDtoImplFromJson(
  Map<String, dynamic> json,
) => _$AdminAnalyticsDtoImpl(
  ordersByStatus: Map<String, int>.from(json['orders_by_status'] as Map),
  serviceRequestsByStatus: Map<String, int>.from(
    json['service_requests_by_status'] as Map,
  ),
  revenue: json['revenue'] as String,
  activeProviders: (json['active_providers'] as num).toInt(),
  openDisputes: (json['open_disputes'] as num).toInt(),
  failedNotificationsRecent: (json['failed_notifications_recent'] as num)
      .toInt(),
  failedPaymentsRecent: (json['failed_payments_recent'] as num).toInt(),
  hasAlert: json['has_alert'] as bool,
);

Map<String, dynamic> _$$AdminAnalyticsDtoImplToJson(
  _$AdminAnalyticsDtoImpl instance,
) => <String, dynamic>{
  'orders_by_status': instance.ordersByStatus,
  'service_requests_by_status': instance.serviceRequestsByStatus,
  'revenue': instance.revenue,
  'active_providers': instance.activeProviders,
  'open_disputes': instance.openDisputes,
  'failed_notifications_recent': instance.failedNotificationsRecent,
  'failed_payments_recent': instance.failedPaymentsRecent,
  'has_alert': instance.hasAlert,
};
