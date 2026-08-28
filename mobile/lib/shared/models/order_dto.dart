import 'package:freezed_annotation/freezed_annotation.dart';

import 'spare_part_summary.dart';

part 'order_dto.freezed.dart';
part 'order_dto.g.dart';

/// Mirrors apps/orders/models.py's OrderStatus.
enum OrderStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PAID')
  paid,
  @JsonValue('DISPATCHED')
  dispatched,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('CANCELLED')
  cancelled,
}

/// Mirrors apps/orders/models.py's PaymentMethod — the wire values POST
/// /orders/{id}/pay expects. AIRTEL_MONEY/TIGO_PESA/HALOPESA/CARD route to
/// Flutterwave, MPESA to Selcom (apps/orders/gateways/routing.py); the app
/// doesn't need to know that split, only which method to send.
enum PaymentMethod {
  card('CARD', 'Card'),
  airtelMoney('AIRTEL_MONEY', 'Airtel Money'),
  tigoPesa('TIGO_PESA', 'Tigo Pesa'),
  haloPesa('HALOPESA', 'HaloPesa'),
  mpesa('MPESA', 'M-Pesa');

  const PaymentMethod(this.wireValue, this.label);
  final String wireValue;
  final String label;
}

/// Mirrors apps/orders/serializers.py's OrderItemSerializer.
@freezed
class OrderItemDto with _$OrderItemDto {
  const factory OrderItemDto({
    required String id,
    @JsonKey(name: 'spare_part') required SparePartSummary sparePart,
    required int quantity,
    @JsonKey(name: 'unit_price') required String unitPrice,
  }) = _OrderItemDto;

  factory OrderItemDto.fromJson(Map<String, dynamic> json) => _$OrderItemDtoFromJson(json);
}

/// Mirrors apps/orders/serializers.py's OrderSerializer.
@freezed
class OrderDto with _$OrderDto {
  const factory OrderDto({
    required String id,
    required OrderStatus status,
    @JsonKey(name: 'total_amount') required String totalAmount,
    @JsonKey(name: 'delivery_address') String? deliveryAddress,
    required List<OrderItemDto> items,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _OrderDto;

  factory OrderDto.fromJson(Map<String, dynamic> json) => _$OrderDtoFromJson(json);
}
