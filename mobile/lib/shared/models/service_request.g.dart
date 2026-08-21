// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceRequestDtoImpl _$$ServiceRequestDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ServiceRequestDtoImpl(
  id: json['id'] as String,
  customer: json['customer'] == null
      ? null
      : UserSummary.fromJson(json['customer'] as Map<String, dynamic>),
  provider: json['provider'] == null
      ? null
      : UserSummary.fromJson(json['provider'] as Map<String, dynamic>),
  serviceType: $enumDecode(_$ServiceTypeEnumMap, json['service_type']),
  status: $enumDecode(_$ServiceStatusEnumMap, json['status']),
  pickupLocation: LatLngPoint.fromJson(
    json['pickup_location'] as Map<String, dynamic>,
  ),
  dropoffLocation: json['dropoff_location'] == null
      ? null
      : LatLngPoint.fromJson(json['dropoff_location'] as Map<String, dynamic>),
  problemDescription: json['problem_description'] as String?,
  estimatedFare: json['estimated_fare'] as String?,
  finalFare: json['final_fare'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$$ServiceRequestDtoImplToJson(
  _$ServiceRequestDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'customer': instance.customer,
  'provider': instance.provider,
  'service_type': _$ServiceTypeEnumMap[instance.serviceType]!,
  'status': _$ServiceStatusEnumMap[instance.status]!,
  'pickup_location': instance.pickupLocation,
  'dropoff_location': instance.dropoffLocation,
  'problem_description': instance.problemDescription,
  'estimated_fare': instance.estimatedFare,
  'final_fare': instance.finalFare,
  'created_at': instance.createdAt,
};

const _$ServiceTypeEnumMap = {
  ServiceType.mechanic: 'MECHANIC',
  ServiceType.recovery: 'RECOVERY',
};

const _$ServiceStatusEnumMap = {
  ServiceStatus.pending: 'PENDING',
  ServiceStatus.accepted: 'ACCEPTED',
  ServiceStatus.enRoute: 'EN_ROUTE',
  ServiceStatus.inProgress: 'IN_PROGRESS',
  ServiceStatus.completed: 'COMPLETED',
  ServiceStatus.cancelled: 'CANCELLED',
};
