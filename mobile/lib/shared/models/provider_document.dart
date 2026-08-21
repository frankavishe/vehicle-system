import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider_document.freezed.dart';
part 'provider_document.g.dart';

/// Mirrors apps/providers/serializers.py's ProviderDocumentSerializer.
@freezed
class ProviderDocumentDto with _$ProviderDocumentDto {
  const factory ProviderDocumentDto({
    required String id,
    @JsonKey(name: 'doc_type') String? docType,
    @JsonKey(name: 'file_url') String? fileUrl,
    required bool verified,
    @JsonKey(name: 'uploaded_at') required String uploadedAt,
  }) = _ProviderDocumentDto;

  factory ProviderDocumentDto.fromJson(Map<String, dynamic> json) =>
      _$ProviderDocumentDtoFromJson(json);
}
