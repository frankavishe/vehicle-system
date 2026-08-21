import 'package:freezed_annotation/freezed_annotation.dart';

part 'spare_part_summary.freezed.dart';
part 'spare_part_summary.g.dart';

/// Minimal projection of apps/catalog/serializers.py's
/// SparePartListSerializer — only what the mechanic's parts-request
/// picker needs.
@freezed
class SparePartSummary with _$SparePartSummary {
  const factory SparePartSummary({
    required String id,
    required String title,
    required String sku,
    required String price,
    @JsonKey(name: 'stock_quantity') required int stockQuantity,
  }) = _SparePartSummary;

  factory SparePartSummary.fromJson(Map<String, dynamic> json) =>
      _$SparePartSummaryFromJson(json);
}
