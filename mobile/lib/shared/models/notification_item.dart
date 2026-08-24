import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

enum NotificationCategory {
  @JsonValue('JOB_ALERT')
  jobAlert,
  @JsonValue('ORDER_UPDATE')
  orderUpdate,
  @JsonValue('DISPATCH')
  dispatch,
  @JsonValue('DISPUTE')
  dispute,
  @JsonValue('GENERAL')
  general,
}

/// Mirrors apps/notifications/serializers.py's NotificationSerializer.
@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required NotificationCategory category,
    required String title,
    required String body,
    @JsonKey(name: 'delivery_status') required String deliveryStatus,
    @JsonKey(name: 'sms_fallback_sent') required bool smsFallbackSent,
    required bool read,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}
