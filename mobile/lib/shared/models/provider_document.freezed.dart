// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProviderDocumentDto _$ProviderDocumentDtoFromJson(Map<String, dynamic> json) {
  return _ProviderDocumentDto.fromJson(json);
}

/// @nodoc
mixin _$ProviderDocumentDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'doc_type')
  String? get docType => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_url')
  String? get fileUrl => throw _privateConstructorUsedError;
  bool get verified => throw _privateConstructorUsedError;
  @JsonKey(name: 'uploaded_at')
  String get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this ProviderDocumentDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProviderDocumentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProviderDocumentDtoCopyWith<ProviderDocumentDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProviderDocumentDtoCopyWith<$Res> {
  factory $ProviderDocumentDtoCopyWith(
    ProviderDocumentDto value,
    $Res Function(ProviderDocumentDto) then,
  ) = _$ProviderDocumentDtoCopyWithImpl<$Res, ProviderDocumentDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'doc_type') String? docType,
    @JsonKey(name: 'file_url') String? fileUrl,
    bool verified,
    @JsonKey(name: 'uploaded_at') String uploadedAt,
  });
}

/// @nodoc
class _$ProviderDocumentDtoCopyWithImpl<$Res, $Val extends ProviderDocumentDto>
    implements $ProviderDocumentDtoCopyWith<$Res> {
  _$ProviderDocumentDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProviderDocumentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? docType = freezed,
    Object? fileUrl = freezed,
    Object? verified = null,
    Object? uploadedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            docType: freezed == docType
                ? _value.docType
                : docType // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileUrl: freezed == fileUrl
                ? _value.fileUrl
                : fileUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            verified: null == verified
                ? _value.verified
                : verified // ignore: cast_nullable_to_non_nullable
                      as bool,
            uploadedAt: null == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProviderDocumentDtoImplCopyWith<$Res>
    implements $ProviderDocumentDtoCopyWith<$Res> {
  factory _$$ProviderDocumentDtoImplCopyWith(
    _$ProviderDocumentDtoImpl value,
    $Res Function(_$ProviderDocumentDtoImpl) then,
  ) = __$$ProviderDocumentDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'doc_type') String? docType,
    @JsonKey(name: 'file_url') String? fileUrl,
    bool verified,
    @JsonKey(name: 'uploaded_at') String uploadedAt,
  });
}

/// @nodoc
class __$$ProviderDocumentDtoImplCopyWithImpl<$Res>
    extends _$ProviderDocumentDtoCopyWithImpl<$Res, _$ProviderDocumentDtoImpl>
    implements _$$ProviderDocumentDtoImplCopyWith<$Res> {
  __$$ProviderDocumentDtoImplCopyWithImpl(
    _$ProviderDocumentDtoImpl _value,
    $Res Function(_$ProviderDocumentDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProviderDocumentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? docType = freezed,
    Object? fileUrl = freezed,
    Object? verified = null,
    Object? uploadedAt = null,
  }) {
    return _then(
      _$ProviderDocumentDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        docType: freezed == docType
            ? _value.docType
            : docType // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileUrl: freezed == fileUrl
            ? _value.fileUrl
            : fileUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        verified: null == verified
            ? _value.verified
            : verified // ignore: cast_nullable_to_non_nullable
                  as bool,
        uploadedAt: null == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProviderDocumentDtoImpl implements _ProviderDocumentDto {
  const _$ProviderDocumentDtoImpl({
    required this.id,
    @JsonKey(name: 'doc_type') this.docType,
    @JsonKey(name: 'file_url') this.fileUrl,
    required this.verified,
    @JsonKey(name: 'uploaded_at') required this.uploadedAt,
  });

  factory _$ProviderDocumentDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProviderDocumentDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'doc_type')
  final String? docType;
  @override
  @JsonKey(name: 'file_url')
  final String? fileUrl;
  @override
  final bool verified;
  @override
  @JsonKey(name: 'uploaded_at')
  final String uploadedAt;

  @override
  String toString() {
    return 'ProviderDocumentDto(id: $id, docType: $docType, fileUrl: $fileUrl, verified: $verified, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProviderDocumentDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.docType, docType) || other.docType == docType) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.verified, verified) ||
                other.verified == verified) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, docType, fileUrl, verified, uploadedAt);

  /// Create a copy of ProviderDocumentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProviderDocumentDtoImplCopyWith<_$ProviderDocumentDtoImpl> get copyWith =>
      __$$ProviderDocumentDtoImplCopyWithImpl<_$ProviderDocumentDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProviderDocumentDtoImplToJson(this);
  }
}

abstract class _ProviderDocumentDto implements ProviderDocumentDto {
  const factory _ProviderDocumentDto({
    required final String id,
    @JsonKey(name: 'doc_type') final String? docType,
    @JsonKey(name: 'file_url') final String? fileUrl,
    required final bool verified,
    @JsonKey(name: 'uploaded_at') required final String uploadedAt,
  }) = _$ProviderDocumentDtoImpl;

  factory _ProviderDocumentDto.fromJson(Map<String, dynamic> json) =
      _$ProviderDocumentDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'doc_type')
  String? get docType;
  @override
  @JsonKey(name: 'file_url')
  String? get fileUrl;
  @override
  bool get verified;
  @override
  @JsonKey(name: 'uploaded_at')
  String get uploadedAt;

  /// Create a copy of ProviderDocumentDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProviderDocumentDtoImplCopyWith<_$ProviderDocumentDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
