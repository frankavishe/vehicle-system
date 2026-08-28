// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartItemDtoImpl _$$CartItemDtoImplFromJson(Map<String, dynamic> json) =>
    _$CartItemDtoImpl(
      id: json['id'] as String,
      sparePart: SparePartSummary.fromJson(
        json['spare_part'] as Map<String, dynamic>,
      ),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$$CartItemDtoImplToJson(_$CartItemDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'spare_part': instance.sparePart,
      'quantity': instance.quantity,
    };

_$CartDtoImpl _$$CartDtoImplFromJson(Map<String, dynamic> json) =>
    _$CartDtoImpl(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: _totalFromJson(json['total']),
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$CartDtoImplToJson(_$CartDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'items': instance.items,
      'total': instance.total,
      'updated_at': instance.updatedAt,
    };
