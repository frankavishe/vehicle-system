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
  });
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
          )
          as $Val,
    );
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
  });
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
  String toString() {
    return 'SparePartSummary(id: $id, title: $title, sku: $sku, price: $price, stockQuantity: $stockQuantity)';
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
                other.stockQuantity == stockQuantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, sku, price, stockQuantity);

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

  /// Create a copy of SparePartSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SparePartSummaryImplCopyWith<_$SparePartSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
