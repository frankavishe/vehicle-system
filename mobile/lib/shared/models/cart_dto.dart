import 'package:freezed_annotation/freezed_annotation.dart';

import 'spare_part_summary.dart';

part 'cart_dto.freezed.dart';
part 'cart_dto.g.dart';

/// Mirrors apps/orders/serializers.py's CartItemSerializer.
@freezed
class CartItemDto with _$CartItemDto {
  const factory CartItemDto({
    required String id,
    @JsonKey(name: 'spare_part') required SparePartSummary sparePart,
    required int quantity,
  }) = _CartItemDto;

  factory CartItemDto.fromJson(Map<String, dynamic> json) => _$CartItemDtoFromJson(json);
}

/// `total`'s wire type is genuinely inconsistent with every other money
/// field in the API (price/unit_price/total_amount all render as strings
/// via DecimalField's COERCE_DECIMAL_TO_STRING): CartSerializer.get_total
/// is a SerializerMethodField returning a raw Decimal, which DRF's JSON
/// encoder renders as a bare number instead — confirmed against the live
/// API, and covered by apps/orders/tests/test_cart.py's own numeric
/// assertions, so it's the API's actual contract, not a bug to route
/// around by changing the backend. web/'s formatTZS(value: string |
/// number) already handles this defensively; this mirrors that here
/// rather than assuming String like ServiceRequestDto's fare fields.
String _totalFromJson(dynamic value) =>
    value is num ? value.toStringAsFixed(2) : value as String;

/// Mirrors apps/orders/serializers.py's CartSerializer.
@freezed
class CartDto with _$CartDto {
  const factory CartDto({
    required String id,
    required List<CartItemDto> items,
    @JsonKey(fromJson: _totalFromJson) required String total,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _CartDto;

  factory CartDto.fromJson(Map<String, dynamic> json) => _$CartDtoFromJson(json);
}
