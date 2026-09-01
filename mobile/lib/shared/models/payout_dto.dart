import 'package:freezed_annotation/freezed_annotation.dart';

part 'payout_dto.freezed.dart';
part 'payout_dto.g.dart';

/// Mirrors apps/admin_ops/models.py's PayoutStatus.
enum PayoutStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('PAID')
  paid,
  @JsonValue('FAILED')
  failed,
}

/// Mirrors apps/admin_ops/serializers.py's PayoutItemSerializer.
@freezed
class PayoutItemDto with _$PayoutItemDto {
  const factory PayoutItemDto({
    required String id,
    @JsonKey(name: 'service_request') String? serviceRequest,
    required String amount,
  }) = _PayoutItemDto;

  factory PayoutItemDto.fromJson(Map<String, dynamic> json) => _$PayoutItemDtoFromJson(json);
}

/// Mirrors apps/admin_ops/serializers.py's PayoutSerializer.
@freezed
class PayoutDto with _$PayoutDto {
  const factory PayoutDto({
    required String id,
    required String provider,
    required String amount,
    @JsonKey(name: 'period_start') String? periodStart,
    @JsonKey(name: 'period_end') String? periodEnd,
    @JsonKey(name: 'is_manual') required bool isManual,
    @JsonKey(name: 'provider_gateway') required String providerGateway,
    @JsonKey(name: 'gateway_transaction_id') String? gatewayTransactionId,
    required PayoutStatus status,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'paid_at') String? paidAt,
    required List<PayoutItemDto> items,
  }) = _PayoutDto;

  factory PayoutDto.fromJson(Map<String, dynamic> json) => _$PayoutDtoFromJson(json);
}
