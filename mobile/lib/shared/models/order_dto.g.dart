// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemDtoImpl _$$OrderItemDtoImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemDtoImpl(
      id: json['id'] as String,
      sparePart: SparePartSummary.fromJson(
        json['spare_part'] as Map<String, dynamic>,
      ),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: json['unit_price'] as String,
    );

Map<String, dynamic> _$$OrderItemDtoImplToJson(_$OrderItemDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'spare_part': instance.sparePart,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
    };

_$OrderDtoImpl _$$OrderDtoImplFromJson(Map<String, dynamic> json) =>
    _$OrderDtoImpl(
      id: json['id'] as String,
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      totalAmount: json['total_amount'] as String,
      deliveryAddress: json['delivery_address'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$OrderDtoImplToJson(_$OrderDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'total_amount': instance.totalAmount,
      'delivery_address': instance.deliveryAddress,
      'items': instance.items,
      'created_at': instance.createdAt,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'PENDING',
  OrderStatus.paid: 'PAID',
  OrderStatus.dispatched: 'DISPATCHED',
  OrderStatus.delivered: 'DELIVERED',
  OrderStatus.cancelled: 'CANCELLED',
};
