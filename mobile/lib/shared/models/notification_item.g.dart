// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationItemImpl _$$NotificationItemImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationItemImpl(
  id: json['id'] as String,
  category: $enumDecode(_$NotificationCategoryEnumMap, json['category']),
  title: json['title'] as String,
  body: json['body'] as String,
  deliveryStatus: json['delivery_status'] as String,
  smsFallbackSent: json['sms_fallback_sent'] as bool,
  read: json['read'] as bool,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$$NotificationItemImplToJson(
  _$NotificationItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'category': _$NotificationCategoryEnumMap[instance.category]!,
  'title': instance.title,
  'body': instance.body,
  'delivery_status': instance.deliveryStatus,
  'sms_fallback_sent': instance.smsFallbackSent,
  'read': instance.read,
  'created_at': instance.createdAt,
};

const _$NotificationCategoryEnumMap = {
  NotificationCategory.jobAlert: 'JOB_ALERT',
  NotificationCategory.orderUpdate: 'ORDER_UPDATE',
  NotificationCategory.dispatch: 'DISPATCH',
  NotificationCategory.dispute: 'DISPUTE',
  NotificationCategory.general: 'GENERAL',
};
