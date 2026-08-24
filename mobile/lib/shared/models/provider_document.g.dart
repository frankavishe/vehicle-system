// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProviderDocumentDtoImpl _$$ProviderDocumentDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ProviderDocumentDtoImpl(
  id: json['id'] as String,
  docType: json['doc_type'] as String?,
  fileUrl: json['file_url'] as String?,
  verified: json['verified'] as bool,
  uploadedAt: json['uploaded_at'] as String,
);

Map<String, dynamic> _$$ProviderDocumentDtoImplToJson(
  _$ProviderDocumentDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'doc_type': instance.docType,
  'file_url': instance.fileUrl,
  'verified': instance.verified,
  'uploaded_at': instance.uploadedAt,
};
