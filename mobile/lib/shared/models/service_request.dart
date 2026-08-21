import 'package:freezed_annotation/freezed_annotation.dart';

import 'lat_lng_point.dart';
import 'user_summary.dart';

part 'service_request.freezed.dart';
part 'service_request.g.dart';

enum ServiceType {
  @JsonValue('MECHANIC')
  mechanic,
  @JsonValue('RECOVERY')
  recovery,
}

enum ServiceStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('EN_ROUTE')
  enRoute,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
}

/// The `@JsonValue` strings above are the single source of truth for the
/// wire format, but there's no reverse (enum -> wire string) accessor
/// generated for a plain field send like `PATCH .../status` — this covers
/// that one gap without hand-duplicating the mapping elsewhere.
const _wireValues = {
  ServiceStatus.pending: 'PENDING',
  ServiceStatus.accepted: 'ACCEPTED',
  ServiceStatus.enRoute: 'EN_ROUTE',
  ServiceStatus.inProgress: 'IN_PROGRESS',
  ServiceStatus.completed: 'COMPLETED',
  ServiceStatus.cancelled: 'CANCELLED',
};

String serviceStatusWireValue(ServiceStatus status) => _wireValues[status]!;

/// Client-side mirror of backend apps/dispatch/services/transitions.py's
/// ALLOWED_TRANSITIONS — for UI enablement only (e.g. graying out an
/// unreachable action button). The backend remains the sole enforcer;
/// this never substitutes for a real server-side check.
const allowedStatusTransitions = <ServiceStatus, Set<ServiceStatus>>{
  // ACCEPTED is only reachable via POST /accept, but the customer must
  // still be able to back out of a still-unaccepted request.
  ServiceStatus.pending: {ServiceStatus.cancelled},
  ServiceStatus.accepted: {ServiceStatus.enRoute, ServiceStatus.cancelled},
  ServiceStatus.enRoute: {ServiceStatus.inProgress, ServiceStatus.cancelled},
  ServiceStatus.inProgress: {ServiceStatus.completed, ServiceStatus.cancelled},
  ServiceStatus.completed: {},
  ServiceStatus.cancelled: {},
};

/// Mirrors apps/dispatch/serializers.py's ServiceRequestSerializer.
/// `estimated_fare`/`final_fare` are DRF DecimalFields, which render as
/// strings — kept as String? here, not double, to match the wire shape
/// exactly (same convention noted for web/'s order totals).
@freezed
class ServiceRequestDto with _$ServiceRequestDto {
  const factory ServiceRequestDto({
    required String id,
    UserSummary? customer,
    UserSummary? provider,
    @JsonKey(name: 'service_type') required ServiceType serviceType,
    required ServiceStatus status,
    @JsonKey(name: 'pickup_location') required LatLngPoint pickupLocation,
    @JsonKey(name: 'dropoff_location') LatLngPoint? dropoffLocation,
    @JsonKey(name: 'problem_description') String? problemDescription,
    @JsonKey(name: 'estimated_fare') String? estimatedFare,
    @JsonKey(name: 'final_fare') String? finalFare,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _ServiceRequestDto;

  factory ServiceRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ServiceRequestDtoFromJson(json);
}
