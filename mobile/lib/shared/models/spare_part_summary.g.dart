// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spare_part_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VendorSummaryImpl _$$VendorSummaryImplFromJson(Map<String, dynamic> json) =>
    _$VendorSummaryImpl(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$$VendorSummaryImplToJson(_$VendorSummaryImpl instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_$SparePartSummaryImpl _$$SparePartSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$SparePartSummaryImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  sku: json['sku'] as String,
  price: json['price'] as String,
  stockQuantity: (json['stock_quantity'] as num).toInt(),
  category: json['category'] as String?,
  compatibleMake: json['compatible_make'] as String?,
  compatibleModel: json['compatible_model'] as String?,
  yearStart: (json['year_start'] as num?)?.toInt(),
  yearEnd: (json['year_end'] as num?)?.toInt(),
  imageUrl: json['image_url'] as String?,
  vendor: json['vendor'] == null
      ? null
      : VendorSummary.fromJson(json['vendor'] as Map<String, dynamic>),
  description: json['description'] as String?,
);

Map<String, dynamic> _$$SparePartSummaryImplToJson(
  _$SparePartSummaryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'sku': instance.sku,
  'price': instance.price,
  'stock_quantity': instance.stockQuantity,
  'category': instance.category,
  'compatible_make': instance.compatibleMake,
  'compatible_model': instance.compatibleModel,
  'year_start': instance.yearStart,
  'year_end': instance.yearEnd,
  'image_url': instance.imageUrl,
  'vendor': instance.vendor,
  'description': instance.description,
};
