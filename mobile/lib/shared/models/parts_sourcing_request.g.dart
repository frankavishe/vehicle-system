// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parts_sourcing_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartsSourcingRequestDtoImpl _$$PartsSourcingRequestDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PartsSourcingRequestDtoImpl(
  id: json['id'] as String,
  serviceRequestId: json['service_request'] as String,
  requestedById: json['requested_by'] as String?,
  sparePartId: json['spare_part'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  status: $enumDecode(_$PartsSourcingStatusEnumMap, json['status']),
  order: json['order'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$$PartsSourcingRequestDtoImplToJson(
  _$PartsSourcingRequestDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'service_request': instance.serviceRequestId,
  'requested_by': instance.requestedById,
  'spare_part': instance.sparePartId,
  'quantity': instance.quantity,
  'status': _$PartsSourcingStatusEnumMap[instance.status]!,
  'order': instance.order,
  'created_at': instance.createdAt,
};

const _$PartsSourcingStatusEnumMap = {
  PartsSourcingStatus.pending: 'PENDING',
  PartsSourcingStatus.approved: 'APPROVED',
  PartsSourcingStatus.rejected: 'REJECTED',
  PartsSourcingStatus.ordered: 'ORDERED',
};
