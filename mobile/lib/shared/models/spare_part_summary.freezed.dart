// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spare_part_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VendorSummary _$VendorSummaryFromJson(Map<String, dynamic> json) {
  return _VendorSummary.fromJson(json);
}

/// @nodoc
mixin _$VendorSummary {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this VendorSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VendorSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorSummaryCopyWith<VendorSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorSummaryCopyWith<$Res> {
  factory $VendorSummaryCopyWith(
    VendorSummary value,
    $Res Function(VendorSummary) then,
  ) = _$VendorSummaryCopyWithImpl<$Res, VendorSummary>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$VendorSummaryCopyWithImpl<$Res, $Val extends VendorSummary>
    implements $VendorSummaryCopyWith<$Res> {
  _$VendorSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VendorSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VendorSummaryImplCopyWith<$Res>
    implements $VendorSummaryCopyWith<$Res> {
  factory _$$VendorSummaryImplCopyWith(
    _$VendorSummaryImpl value,
    $Res Function(_$VendorSummaryImpl) then,
  ) = __$$VendorSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$VendorSummaryImplCopyWithImpl<$Res>
    extends _$VendorSummaryCopyWithImpl<$Res, _$VendorSummaryImpl>
    implements _$$VendorSummaryImplCopyWith<$Res> {
  __$$VendorSummaryImplCopyWithImpl(
    _$VendorSummaryImpl _value,
    $Res Function(_$VendorSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VendorSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _$VendorSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorSummaryImpl implements _VendorSummary {
  const _$VendorSummaryImpl({required this.id, required this.name});

  factory _$VendorSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'VendorSummary(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of VendorSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorSummaryImplCopyWith<_$VendorSummaryImpl> get copyWith =>
      __$$VendorSummaryImplCopyWithImpl<_$VendorSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorSummaryImplToJson(this);
  }
}

abstract class _VendorSummary implements VendorSummary {
  const factory _VendorSummary({
    required final String id,
    required final String name,
  }) = _$VendorSummaryImpl;

  factory _VendorSummary.fromJson(Map<String, dynamic> json) =
      _$VendorSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;

  /// Create a copy of VendorSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorSummaryImplCopyWith<_$VendorSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SparePartSummary _$SparePartSummaryFromJson(Map<String, dynamic> json) {
  return _SparePartSummary.fromJson(json);
}

/// @nodoc
mixin _$SparePartSummary {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  String get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_quantity')
  int get stockQuantity => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'compatible_make')
  String? get compatibleMake => throw _privateConstructorUsedError;
  @JsonKey(name: 'compatible_model')
  String? get compatibleModel => throw _privateConstructorUsedError;
  @JsonKey(name: 'year_start')
  int? get yearStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'year_end')
  int? get yearEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  VendorSummary? get vendor =>
      throw _privateConstructorUsedError; // Only present on GET /parts/{id} (SparePartDetailSerializer); null in
  // list/facet responses.
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this SparePartSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SparePartSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SparePartSummaryCopyWith<SparePartSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SparePartSummaryCopyWith<$Res> {
  factory $SparePartSummaryCopyWith(
    SparePartSummary value,
    $Res Function(SparePartSummary) then,
  ) = _$SparePartSummaryCopyWithImpl<$Res, SparePartSummary>;
  @useResult
  $Res call({
    String id,
    String title,
    String sku,
    String price,
    @JsonKey(name: 'stock_quantity') int stockQuantity,
    String? category,
    @JsonKey(name: 'compatible_make') String? compatibleMake,
    @JsonKey(name: 'compatible_model') String? compatibleModel,
    @JsonKey(name: 'year_start') int? yearStart,
    @JsonKey(name: 'year_end') int? yearEnd,
    @JsonKey(name: 'image_url') String? imageUrl,
    VendorSummary? vendor,
    String? description,
  });

  $VendorSummaryCopyWith<$Res>? get vendor;
}

/// @nodoc
class _$SparePartSummaryCopyWithImpl<$Res, $Val extends SparePartSummary>
    implements $SparePartSummaryCopyWith<$Res> {
  _$SparePartSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SparePartSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? sku = null,
    Object? price = null,
    Object? stockQuantity = null,
    Object? category = freezed,
    Object? compatibleMake = freezed,
    Object? compatibleModel = freezed,
    Object? yearStart = freezed,
    Object? yearEnd = freezed,
    Object? imageUrl = freezed,
    Object? vendor = freezed,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            sku: null == sku
                ? _value.sku
                : sku // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String,
            stockQuantity: null == stockQuantity
                ? _value.stockQuantity
                : stockQuantity // ignore: cast_nullable_to_non_nullable
                      as int,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            compatibleMake: freezed == compatibleMake
                ? _value.compatibleMake
                : compatibleMake // ignore: cast_nullable_to_non_nullable
                      as String?,
            compatibleModel: freezed == compatibleModel
                ? _value.compatibleModel
                : compatibleModel // ignore: cast_nullable_to_non_nullable
                      as String?,
            yearStart: freezed == yearStart
                ? _value.yearStart
                : yearStart // ignore: cast_nullable_to_non_nullable
                      as int?,
            yearEnd: freezed == yearEnd
                ? _value.yearEnd
                : yearEnd // ignore: cast_nullable_to_non_nullable
                      as int?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            vendor: freezed == vendor
                ? _value.vendor
                : vendor // ignore: cast_nullable_to_non_nullable
                      as VendorSummary?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of SparePartSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VendorSummaryCopyWith<$Res>? get vendor {
    if (_value.vendor == null) {
      return null;
    }

    return $VendorSummaryCopyWith<$Res>(_value.vendor!, (value) {
      return _then(_value.copyWith(vendor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SparePartSummaryImplCopyWith<$Res>
    implements $SparePartSummaryCopyWith<$Res> {
  factory _$$SparePartSummaryImplCopyWith(
    _$SparePartSummaryImpl value,
    $Res Function(_$SparePartSummaryImpl) then,
  ) = __$$SparePartSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String sku,
    String price,
    @JsonKey(name: 'stock_quantity') int stockQuantity,
    String? category,
    @JsonKey(name: 'compatible_make') String? compatibleMake,
    @JsonKey(name: 'compatible_model') String? compatibleModel,
    @JsonKey(name: 'year_start') int? yearStart,
    @JsonKey(name: 'year_end') int? yearEnd,
    @JsonKey(name: 'image_url') String? imageUrl,
    VendorSummary? vendor,
    String? description,
  });

  @override
  $VendorSummaryCopyWith<$Res>? get vendor;
}

/// @nodoc
class __$$SparePartSummaryImplCopyWithImpl<$Res>
    extends _$SparePartSummaryCopyWithImpl<$Res, _$SparePartSummaryImpl>
    implements _$$SparePartSummaryImplCopyWith<$Res> {
  __$$SparePartSummaryImplCopyWithImpl(
    _$SparePartSummaryImpl _value,
    $Res Function(_$SparePartSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SparePartSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? sku = null,
    Object? price = null,
    Object? stockQuantity = null,
    Object? category = freezed,
    Object? compatibleMake = freezed,
    Object? compatibleModel = freezed,
    Object? yearStart = freezed,
    Object? yearEnd = freezed,
    Object? imageUrl = freezed,
    Object? vendor = freezed,
    Object? description = freezed,
  }) {
    return _then(
      _$SparePartSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        sku: null == sku
            ? _value.sku
            : sku // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String,
        stockQuantity: null == stockQuantity
            ? _value.stockQuantity
            : stockQuantity // ignore: cast_nullable_to_non_nullable
                  as int,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        compatibleMake: freezed == compatibleMake
            ? _value.compatibleMake
            : compatibleMake // ignore: cast_nullable_to_non_nullable
                  as String?,
        compatibleModel: freezed == compatibleModel
            ? _value.compatibleModel
            : compatibleModel // ignore: cast_nullable_to_non_nullable
                  as String?,
        yearStart: freezed == yearStart
            ? _value.yearStart
            : yearStart // ignore: cast_nullable_to_non_nullable
                  as int?,
        yearEnd: freezed == yearEnd
            ? _value.yearEnd
            : yearEnd // ignore: cast_nullable_to_non_nullable
                  as int?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        vendor: freezed == vendor
            ? _value.vendor
            : vendor // ignore: cast_nullable_to_non_nullable
                  as VendorSummary?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SparePartSummaryImpl implements _SparePartSummary {
  const _$SparePartSummaryImpl({
    required this.id,
    required this.title,
    required this.sku,
    required this.price,
    @JsonKey(name: 'stock_quantity') required this.stockQuantity,
    this.category,
    @JsonKey(name: 'compatible_make') this.compatibleMake,
    @JsonKey(name: 'compatible_model') this.compatibleModel,
    @JsonKey(name: 'year_start') this.yearStart,
    @JsonKey(name: 'year_end') this.yearEnd,
    @JsonKey(name: 'image_url') this.imageUrl,
    this.vendor,
    this.description,
  });

  factory _$SparePartSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SparePartSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String sku;
  @override
  final String price;
  @override
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  @override
  final String? category;
  @override
  @JsonKey(name: 'compatible_make')
  final String? compatibleMake;
  @override
  @JsonKey(name: 'compatible_model')
  final String? compatibleModel;
  @override
  @JsonKey(name: 'year_start')
  final int? yearStart;
  @override
  @JsonKey(name: 'year_end')
  final int? yearEnd;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  final VendorSummary? vendor;
  // Only present on GET /parts/{id} (SparePartDetailSerializer); null in
  // list/facet responses.
  @override
  final String? description;

  @override
  String toString() {
    return 'SparePartSummary(id: $id, title: $title, sku: $sku, price: $price, stockQuantity: $stockQuantity, category: $category, compatibleMake: $compatibleMake, compatibleModel: $compatibleModel, yearStart: $yearStart, yearEnd: $yearEnd, imageUrl: $imageUrl, vendor: $vendor, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SparePartSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.compatibleMake, compatibleMake) ||
                other.compatibleMake == compatibleMake) &&
            (identical(other.compatibleModel, compatibleModel) ||
                other.compatibleModel == compatibleModel) &&
            (identical(other.yearStart, yearStart) ||
                other.yearStart == yearStart) &&
            (identical(other.yearEnd, yearEnd) || other.yearEnd == yearEnd) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    sku,
    price,
    stockQuantity,
    category,
    compatibleMake,
    compatibleModel,
    yearStart,
    yearEnd,
    imageUrl,
    vendor,
    description,
  );

  /// Create a copy of SparePartSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SparePartSummaryImplCopyWith<_$SparePartSummaryImpl> get copyWith =>
      __$$SparePartSummaryImplCopyWithImpl<_$SparePartSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SparePartSummaryImplToJson(this);
  }
}

abstract class _SparePartSummary implements SparePartSummary {
  const factory _SparePartSummary({
    required final String id,
    required final String title,
    required final String sku,
    required final String price,
    @JsonKey(name: 'stock_quantity') required final int stockQuantity,
    final String? category,
    @JsonKey(name: 'compatible_make') final String? compatibleMake,
    @JsonKey(name: 'compatible_model') final String? compatibleModel,
    @JsonKey(name: 'year_start') final int? yearStart,
    @JsonKey(name: 'year_end') final int? yearEnd,
    @JsonKey(name: 'image_url') final String? imageUrl,
    final VendorSummary? vendor,
    final String? description,
  }) = _$SparePartSummaryImpl;

  factory _SparePartSummary.fromJson(Map<String, dynamic> json) =
      _$SparePartSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get sku;
  @override
  String get price;
  @override
  @JsonKey(name: 'stock_quantity')
  int get stockQuantity;
  @override
  String? get category;
  @override
  @JsonKey(name: 'compatible_make')
  String? get compatibleMake;
  @override
  @JsonKey(name: 'compatible_model')
  String? get compatibleModel;
  @override
  @JsonKey(name: 'year_start')
  int? get yearStart;
  @override
  @JsonKey(name: 'year_end')
  int? get yearEnd;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  VendorSummary? get vendor; // Only present on GET /parts/{id} (SparePartDetailSerializer); null in
  // list/facet responses.
  @override
  String? get description;

  /// Create a copy of SparePartSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SparePartSummaryImplCopyWith<_$SparePartSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
