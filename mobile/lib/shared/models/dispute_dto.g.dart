// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DisputeServiceRequestSummaryImpl _$$DisputeServiceRequestSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$DisputeServiceRequestSummaryImpl(
  id: json['id'] as String,
  serviceType: json['service_type'] as String,
  status: json['status'] as String,
  customerName: json['customer_name'] as String?,
  providerName: json['provider_name'] as String?,
);

Map<String, dynamic> _$$DisputeServiceRequestSummaryImplToJson(
  _$DisputeServiceRequestSummaryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'service_type': instance.serviceType,
  'status': instance.status,
  'customer_name': instance.customerName,
  'provider_name': instance.providerName,
};

_$DisputeDtoImpl _$$DisputeDtoImplFromJson(Map<String, dynamic> json) =>
    _$DisputeDtoImpl(
      id: json['id'] as String,
      serviceRequest: json['service_request'] as String,
      raisedBy: json['raised_by'] as String?,
      reason: json['reason'] as String?,
      status: $enumDecode(_$DisputeStatusEnumMap, json['status']),
      resolvedBy: json['resolved_by'] as String?,
      createdAt: json['created_at'] as String,
      serviceRequestSummary: json['service_request_summary'] == null
          ? null
          : DisputeServiceRequestSummary.fromJson(
              json['service_request_summary'] as Map<String, dynamic>,
            ),
      raisedByName: json['raised_by_name'] as String?,
      raisedByEmail: json['raised_by_email'] as String?,
      resolvedByName: json['resolved_by_name'] as String?,
    );

Map<String, dynamic> _$$DisputeDtoImplToJson(_$DisputeDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'service_request': instance.serviceRequest,
      'raised_by': instance.raisedBy,
      'reason': instance.reason,
      'status': _$DisputeStatusEnumMap[instance.status]!,
      'resolved_by': instance.resolvedBy,
      'created_at': instance.createdAt,
      'service_request_summary': instance.serviceRequestSummary,
      'raised_by_name': instance.raisedByName,
      'raised_by_email': instance.raisedByEmail,
      'resolved_by_name': instance.resolvedByName,
    };

const _$DisputeStatusEnumMap = {
  DisputeStatus.open: 'OPEN',
  DisputeStatus.resolved: 'RESOLVED',
};
