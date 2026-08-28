// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CartItemDto _$CartItemDtoFromJson(Map<String, dynamic> json) {
  return _CartItemDto.fromJson(json);
}

/// @nodoc
mixin _$CartItemDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'spare_part')
  SparePartSummary get sparePart => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;

  /// Serializes this CartItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartItemDtoCopyWith<CartItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemDtoCopyWith<$Res> {
  factory $CartItemDtoCopyWith(
    CartItemDto value,
    $Res Function(CartItemDto) then,
  ) = _$CartItemDtoCopyWithImpl<$Res, CartItemDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'spare_part') SparePartSummary sparePart,
    int quantity,
  });

  $SparePartSummaryCopyWith<$Res> get sparePart;
}

/// @nodoc
class _$CartItemDtoCopyWithImpl<$Res, $Val extends CartItemDto>
    implements $CartItemDtoCopyWith<$Res> {
  _$CartItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sparePart = null,
    Object? quantity = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sparePart: null == sparePart
                ? _value.sparePart
                : sparePart // ignore: cast_nullable_to_non_nullable
                      as SparePartSummary,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of CartItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SparePartSummaryCopyWith<$Res> get sparePart {
    return $SparePartSummaryCopyWith<$Res>(_value.sparePart, (value) {
      return _then(_value.copyWith(sparePart: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartItemDtoImplCopyWith<$Res>
    implements $CartItemDtoCopyWith<$Res> {
  factory _$$CartItemDtoImplCopyWith(
    _$CartItemDtoImpl value,
    $Res Function(_$CartItemDtoImpl) then,
  ) = __$$CartItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'spare_part') SparePartSummary sparePart,
    int quantity,
  });

  @override
  $SparePartSummaryCopyWith<$Res> get sparePart;
}

/// @nodoc
class __$$CartItemDtoImplCopyWithImpl<$Res>
    extends _$CartItemDtoCopyWithImpl<$Res, _$CartItemDtoImpl>
    implements _$$CartItemDtoImplCopyWith<$Res> {
  __$$CartItemDtoImplCopyWithImpl(
    _$CartItemDtoImpl _value,
    $Res Function(_$CartItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CartItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sparePart = null,
    Object? quantity = null,
  }) {
    return _then(
      _$CartItemDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sparePart: null == sparePart
            ? _value.sparePart
            : sparePart // ignore: cast_nullable_to_non_nullable
                  as SparePartSummary,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CartItemDtoImpl implements _CartItemDto {
  const _$CartItemDtoImpl({
    required this.id,
    @JsonKey(name: 'spare_part') required this.sparePart,
    required this.quantity,
  });

  factory _$CartItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartItemDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'spare_part')
  final SparePartSummary sparePart;
  @override
  final int quantity;

  @override
  String toString() {
    return 'CartItemDto(id: $id, sparePart: $sparePart, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sparePart, sparePart) ||
                other.sparePart == sparePart) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, sparePart, quantity);

  /// Create a copy of CartItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemDtoImplCopyWith<_$CartItemDtoImpl> get copyWith =>
      __$$CartItemDtoImplCopyWithImpl<_$CartItemDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartItemDtoImplToJson(this);
  }
}

abstract class _CartItemDto implements CartItemDto {
  const factory _CartItemDto({
    required final String id,
    @JsonKey(name: 'spare_part') required final SparePartSummary sparePart,
    required final int quantity,
  }) = _$CartItemDtoImpl;

  factory _CartItemDto.fromJson(Map<String, dynamic> json) =
      _$CartItemDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'spare_part')
  SparePartSummary get sparePart;
  @override
  int get quantity;

  /// Create a copy of CartItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartItemDtoImplCopyWith<_$CartItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CartDto _$CartDtoFromJson(Map<String, dynamic> json) {
  return _CartDto.fromJson(json);
}

/// @nodoc
mixin _$CartDto {
  String get id => throw _privateConstructorUsedError;
  List<CartItemDto> get items => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _totalFromJson)
  String get total => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CartDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartDtoCopyWith<CartDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartDtoCopyWith<$Res> {
  factory $CartDtoCopyWith(CartDto value, $Res Function(CartDto) then) =
      _$CartDtoCopyWithImpl<$Res, CartDto>;
  @useResult
  $Res call({
    String id,
    List<CartItemDto> items,
    @JsonKey(fromJson: _totalFromJson) String total,
    @JsonKey(name: 'updated_at') String updatedAt,
  });
}

/// @nodoc
class _$CartDtoCopyWithImpl<$Res, $Val extends CartDto>
    implements $CartDtoCopyWith<$Res> {
  _$CartDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? items = null,
    Object? total = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<CartItemDto>,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CartDtoImplCopyWith<$Res> implements $CartDtoCopyWith<$Res> {
  factory _$$CartDtoImplCopyWith(
    _$CartDtoImpl value,
    $Res Function(_$CartDtoImpl) then,
  ) = __$$CartDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    List<CartItemDto> items,
    @JsonKey(fromJson: _totalFromJson) String total,
    @JsonKey(name: 'updated_at') String updatedAt,
  });
}

/// @nodoc
class __$$CartDtoImplCopyWithImpl<$Res>
    extends _$CartDtoCopyWithImpl<$Res, _$CartDtoImpl>
    implements _$$CartDtoImplCopyWith<$Res> {
  __$$CartDtoImplCopyWithImpl(
    _$CartDtoImpl _value,
    $Res Function(_$CartDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CartDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? items = null,
    Object? total = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CartDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CartItemDto>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CartDtoImpl implements _CartDto {
  const _$CartDtoImpl({
    required this.id,
    required final List<CartItemDto> items,
    @JsonKey(fromJson: _totalFromJson) required this.total,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : _items = items;

  factory _$CartDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartDtoImplFromJson(json);

  @override
  final String id;
  final List<CartItemDto> _items;
  @override
  List<CartItemDto> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey(fromJson: _totalFromJson)
  final String total;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @override
  String toString() {
    return 'CartDto(id: $id, items: $items, total: $total, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_items),
    total,
    updatedAt,
  );

  /// Create a copy of CartDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartDtoImplCopyWith<_$CartDtoImpl> get copyWith =>
      __$$CartDtoImplCopyWithImpl<_$CartDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartDtoImplToJson(this);
  }
}

abstract class _CartDto implements CartDto {
  const factory _CartDto({
    required final String id,
    required final List<CartItemDto> items,
    @JsonKey(fromJson: _totalFromJson) required final String total,
    @JsonKey(name: 'updated_at') required final String updatedAt,
  }) = _$CartDtoImpl;

  factory _CartDto.fromJson(Map<String, dynamic> json) = _$CartDtoImpl.fromJson;

  @override
  String get id;
  @override
  List<CartItemDto> get items;
  @override
  @JsonKey(fromJson: _totalFromJson)
  String get total;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt;

  /// Create a copy of CartDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartDtoImplCopyWith<_$CartDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
