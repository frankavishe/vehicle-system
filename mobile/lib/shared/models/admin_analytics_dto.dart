import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_analytics_dto.freezed.dart';
part 'admin_analytics_dto.g.dart';

/// Mirrors apps/admin_ops/views.py's AdminAnalyticsView response,
/// including the 3 additive fields 003-admin-mobile-app adds (spec.md
/// FR-004, research.md §7) — `has_alert` is server-computed so this app
/// never picks its own threshold (the actual number lives in the
/// backend's FAILURE_ALERT_THRESHOLD setting, not here).
@freezed
class AdminAnalyticsDto with _$AdminAnalyticsDto {
  const factory AdminAnalyticsDto({
    @JsonKey(name: 'orders_by_status') required Map<String, int> ordersByStatus,
    @JsonKey(name: 'service_requests_by_status') required Map<String, int> serviceRequestsByStatus,
    required String revenue,
    @JsonKey(name: 'active_providers') required int activeProviders,
    @JsonKey(name: 'open_disputes') required int openDisputes,
    @JsonKey(name: 'failed_notifications_recent') required int failedNotificationsRecent,
    @JsonKey(name: 'failed_payments_recent') required int failedPaymentsRecent,
    @JsonKey(name: 'has_alert') required bool hasAlert,
  }) = _AdminAnalyticsDto;

  factory AdminAnalyticsDto.fromJson(Map<String, dynamic> json) =>
      _$AdminAnalyticsDtoFromJson(json);
}
