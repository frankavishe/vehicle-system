import 'package:freezed_annotation/freezed_annotation.dart';

import 'lat_lng_point.dart';

part 'order_shipment_dto.freezed.dart';
part 'order_shipment_dto.g.dart';

/// Mirrors apps/orders/serializers.py's OrderShipmentSerializer. Only
/// exists once an admin has set courier info on the order (GET
/// /orders/{id}/shipment 404s until then — see
/// AutoserveApi.getOrderShipment).
@freezed
class OrderShipmentDto with _$OrderShipmentDto {
  const factory OrderShipmentDto({
    required String id,
    @JsonKey(name: 'courier_name') String? courierName,
    @JsonKey(name: 'tracking_ref') String? trackingRef,
    @JsonKey(name: 'dispatched_at') String? dispatchedAt,
    @JsonKey(name: 'delivered_at') String? deliveredAt,
    @JsonKey(name: 'current_location') LatLngPoint? currentLocation,
  }) = _OrderShipmentDto;

  factory OrderShipmentDto.fromJson(Map<String, dynamic> json) =>
      _$OrderShipmentDtoFromJson(json);
}
