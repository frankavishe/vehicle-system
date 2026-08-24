import 'package:freezed_annotation/freezed_annotation.dart';

part 'parts_sourcing_request.freezed.dart';
part 'parts_sourcing_request.g.dart';

enum PartsSourcingStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('ORDERED')
  ordered,
}

/// Mirrors apps/dispatch/serializers.py's PartsSourcingRequestSerializer —
/// a plain ModelSerializer, so every FK renders as its bare id (no nested
/// object), matching the shapes here.
@freezed
class PartsSourcingRequestDto with _$PartsSourcingRequestDto {
  const factory PartsSourcingRequestDto({
    required String id,
    @JsonKey(name: 'service_request') required String serviceRequestId,
    @JsonKey(name: 'requested_by') String? requestedById,
    @JsonKey(name: 'spare_part') String? sparePartId,
    required int quantity,
    required PartsSourcingStatus status,
    String? order,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _PartsSourcingRequestDto;

  factory PartsSourcingRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PartsSourcingRequestDtoFromJson(json);
}
