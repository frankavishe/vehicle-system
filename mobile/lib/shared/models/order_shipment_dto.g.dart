// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_shipment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderShipmentDtoImpl _$$OrderShipmentDtoImplFromJson(
  Map<String, dynamic> json,
) => _$OrderShipmentDtoImpl(
  id: json['id'] as String,
  courierName: json['courier_name'] as String?,
  trackingRef: json['tracking_ref'] as String?,
  dispatchedAt: json['dispatched_at'] as String?,
  deliveredAt: json['delivered_at'] as String?,
  currentLocation: json['current_location'] == null
      ? null
      : LatLngPoint.fromJson(json['current_location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$OrderShipmentDtoImplToJson(
  _$OrderShipmentDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'courier_name': instance.courierName,
  'tracking_ref': instance.trackingRef,
  'dispatched_at': instance.dispatchedAt,
  'delivered_at': instance.deliveredAt,
  'current_location': instance.currentLocation,
};
