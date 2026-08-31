import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispute_dto.freezed.dart';
part 'dispute_dto.g.dart';

/// Mirrors apps/admin_ops/models.py's DisputeStatus.
enum DisputeStatus {
  @JsonValue('OPEN')
  open,
  @JsonValue('RESOLVED')
  resolved,
}

/// Mirrors DisputeSerializer's `service_request_summary` field
/// (contracts/admin-mobile-api.md) — job detail without a second lookup.
@freezed
class DisputeServiceRequestSummary with _$DisputeServiceRequestSummary {
  const factory DisputeServiceRequestSummary({
    required String id,
    @JsonKey(name: 'service_type') required String serviceType,
    required String status,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'provider_name') String? providerName,
  }) = _DisputeServiceRequestSummary;

  factory DisputeServiceRequestSummary.fromJson(Map<String, dynamic> json) =>
      _$DisputeServiceRequestSummaryFromJson(json);
}

/// Mirrors apps/admin_ops/serializers.py's DisputeSerializer, including
/// the 4 additive read-only fields 003-admin-mobile-app adds
/// (spec.md FR-002/FR-003, research.md §3).
@freezed
class DisputeDto with _$DisputeDto {
  const factory DisputeDto({
    required String id,
    @JsonKey(name: 'service_request') required String serviceRequest,
    @JsonKey(name: 'raised_by') String? raisedBy,
    String? reason,
    required DisputeStatus status,
    @JsonKey(name: 'resolved_by') String? resolvedBy,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'service_request_summary') DisputeServiceRequestSummary? serviceRequestSummary,
    @JsonKey(name: 'raised_by_name') String? raisedByName,
    @JsonKey(name: 'raised_by_email') String? raisedByEmail,
    @JsonKey(name: 'resolved_by_name') String? resolvedByName,
  }) = _DisputeDto;

  factory DisputeDto.fromJson(Map<String, dynamic> json) => _$DisputeDtoFromJson(json);
}
