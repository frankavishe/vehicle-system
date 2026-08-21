// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spare_part_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SparePartSummaryImpl _$$SparePartSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$SparePartSummaryImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  sku: json['sku'] as String,
  price: json['price'] as String,
  stockQuantity: (json['stock_quantity'] as num).toInt(),
);

Map<String, dynamic> _$$SparePartSummaryImplToJson(
  _$SparePartSummaryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'sku': instance.sku,
  'price': instance.price,
  'stock_quantity': instance.stockQuantity,
};
