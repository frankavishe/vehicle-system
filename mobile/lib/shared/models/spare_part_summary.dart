import 'package:freezed_annotation/freezed_annotation.dart';

part 'spare_part_summary.freezed.dart';
part 'spare_part_summary.g.dart';

/// Nested read-only vendor summary embedded in a spare part — mirrors
/// apps/catalog/serializers.py's VendorSummarySerializer.
@freezed
class VendorSummary with _$VendorSummary {
  const factory VendorSummary({required String id, required String name}) = _VendorSummary;

  factory VendorSummary.fromJson(Map<String, dynamic> json) => _$VendorSummaryFromJson(json);
}

/// Mirrors apps/catalog/serializers.py's SparePartListSerializer (all
/// fields below are shared with SparePartDetailSerializer, which only adds
/// `description` on top — kept optional here since list responses omit it).
/// Originally scoped to just what the mechanic's parts-request picker
/// needed (id/title/sku/price/stockQuantity); extended for the customer
/// shop screens with the rest of the serializer's fields.
@freezed
class SparePartSummary with _$SparePartSummary {
  const factory SparePartSummary({
    required String id,
    required String title,
    required String sku,
    required String price,
    @JsonKey(name: 'stock_quantity') required int stockQuantity,
    String? category,
    @JsonKey(name: 'compatible_make') String? compatibleMake,
    @JsonKey(name: 'compatible_model') String? compatibleModel,
    @JsonKey(name: 'year_start') int? yearStart,
    @JsonKey(name: 'year_end') int? yearEnd,
    @JsonKey(name: 'image_url') String? imageUrl,
    VendorSummary? vendor,
    // Only present on GET /parts/{id} (SparePartDetailSerializer); null in
    // list/facet responses.
    String? description,
  }) = _SparePartSummary;

  factory SparePartSummary.fromJson(Map<String, dynamic> json) =>
      _$SparePartSummaryFromJson(json);
}
