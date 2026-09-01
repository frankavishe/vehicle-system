// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PayoutItemDtoImpl _$$PayoutItemDtoImplFromJson(Map<String, dynamic> json) =>
    _$PayoutItemDtoImpl(
      id: json['id'] as String,
      serviceRequest: json['service_request'] as String?,
      amount: json['amount'] as String,
    );

Map<String, dynamic> _$$PayoutItemDtoImplToJson(_$PayoutItemDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'service_request': instance.serviceRequest,
      'amount': instance.amount,
    };

_$PayoutDtoImpl _$$PayoutDtoImplFromJson(Map<String, dynamic> json) =>
    _$PayoutDtoImpl(
      id: json['id'] as String,
      provider: json['provider'] as String,
      amount: json['amount'] as String,
      periodStart: json['period_start'] as String?,
      periodEnd: json['period_end'] as String?,
      isManual: json['is_manual'] as bool,
      providerGateway: json['provider_gateway'] as String,
      gatewayTransactionId: json['gateway_transaction_id'] as String?,
      status: $enumDecode(_$PayoutStatusEnumMap, json['status']),
      createdAt: json['created_at'] as String,
      paidAt: json['paid_at'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => PayoutItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PayoutDtoImplToJson(_$PayoutDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider': instance.provider,
      'amount': instance.amount,
      'period_start': instance.periodStart,
      'period_end': instance.periodEnd,
      'is_manual': instance.isManual,
      'provider_gateway': instance.providerGateway,
      'gateway_transaction_id': instance.gatewayTransactionId,
      'status': _$PayoutStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt,
      'paid_at': instance.paidAt,
      'items': instance.items,
    };

const _$PayoutStatusEnumMap = {
  PayoutStatus.pending: 'PENDING',
  PayoutStatus.processing: 'PROCESSING',
  PayoutStatus.paid: 'PAID',
  PayoutStatus.failed: 'FAILED',
};
