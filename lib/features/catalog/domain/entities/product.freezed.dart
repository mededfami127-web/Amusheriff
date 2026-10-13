// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get id; String get categoryId; String get title; String? get titleAm; String? get titleAr; String? get description; String? get descriptionAm; String? get descriptionAr; double get price; double? get compareAtPrice; String get currencyCode; bool get isAvailable; bool get isFeatured; bool get isPublished; int get sortOrder; DateTime? get createdAt; DateTime? get updatedAt;/// Embedded media, present when the query selected `product_media(*)`.
@JsonKey(name: 'product_media') List<ProductMedia> get media;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Product;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.titleAm, _this.titleAm) || other.titleAm == _this.titleAm)&&(identical(other.titleAr, _this.titleAr) || other.titleAr == _this.titleAr)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.descriptionAm, _this.descriptionAm) || other.descriptionAm == _this.descriptionAm)&&(identical(other.descriptionAr, _this.descriptionAr) || other.descriptionAr == _this.descriptionAr)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.compareAtPrice, _this.compareAtPrice) || other.compareAtPrice == _this.compareAtPrice)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.isAvailable, _this.isAvailable) || other.isAvailable == _this.isAvailable)&&(identical(other.isFeatured, _this.isFeatured) || other.isFeatured == _this.isFeatured)&&(identical(other.isPublished, _this.isPublished) || other.isPublished == _this.isPublished)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.media, _this.media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Product;
  return Object.hash(runtimeType,_this.id,_this.categoryId,_this.title,_this.titleAm,_this.titleAr,_this.description,_this.descriptionAm,_this.descriptionAr,_this.price,_this.compareAtPrice,_this.currencyCode,_this.isAvailable,_this.isFeatured,_this.isPublished,_this.sortOrder,_this.createdAt,_this.updatedAt,const DeepCollectionEquality().hash(_this.media));
}

@override
String toString() {
  final _this = this as Product;
  return 'Product(id: ${_this.id}, categoryId: ${_this.categoryId}, title: ${_this.title}, titleAm: ${_this.titleAm}, titleAr: ${_this.titleAr}, description: ${_this.description}, descriptionAm: ${_this.descriptionAm}, descriptionAr: ${_this.descriptionAr}, price: ${_this.price}, compareAtPrice: ${_this.compareAtPrice}, currencyCode: ${_this.currencyCode}, isAvailable: ${_this.isAvailable}, isFeatured: ${_this.isFeatured}, isPublished: ${_this.isPublished}, sortOrder: ${_this.sortOrder}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, media: ${_this.media})';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String categoryId, String title, String? titleAm, String? titleAr, String? description, String? descriptionAm, String? descriptionAr, double price, double? compareAtPrice, String currencyCode, bool isAvailable, bool isFeatured, bool isPublished, int sortOrder, DateTime? createdAt, DateTime? updatedAt,@JsonKey(name: 'product_media') List<ProductMedia> media
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = null,Object? title = null,Object? titleAm = freezed,Object? titleAr = freezed,Object? description = freezed,Object? descriptionAm = freezed,Object? descriptionAr = freezed,Object? price = null,Object? compareAtPrice = freezed,Object? currencyCode = null,Object? isAvailable = null,Object? isFeatured = null,Object? isPublished = null,Object? sortOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? media = null,}) {
  return _then(Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,titleAm: freezed == titleAm ? _self.titleAm : titleAm // ignore: cast_nullable_to_non_nullable
as String?,titleAr: freezed == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,descriptionAm: freezed == descriptionAm ? _self.descriptionAm : descriptionAm // ignore: cast_nullable_to_non_nullable
as String?,descriptionAr: freezed == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,compareAtPrice: freezed == compareAtPrice ? _self.compareAtPrice : compareAtPrice // ignore: cast_nullable_to_non_nullable
as double?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<ProductMedia>,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String categoryId,  String title,  String? titleAm,  String? titleAr,  String? description,  String? descriptionAm,  String? descriptionAr,  double price,  double? compareAtPrice,  String currencyCode,  bool isAvailable,  bool isFeatured,  bool isPublished,  int sortOrder,  DateTime? createdAt,  DateTime? updatedAt, @JsonKey(name: 'product_media')  List<ProductMedia> media)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.categoryId,_that.title,_that.titleAm,_that.titleAr,_that.description,_that.descriptionAm,_that.descriptionAr,_that.price,_that.compareAtPrice,_that.currencyCode,_that.isAvailable,_that.isFeatured,_that.isPublished,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.media);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String categoryId,  String title,  String? titleAm,  String? titleAr,  String? description,  String? descriptionAm,  String? descriptionAr,  double price,  double? compareAtPrice,  String currencyCode,  bool isAvailable,  bool isFeatured,  bool isPublished,  int sortOrder,  DateTime? createdAt,  DateTime? updatedAt, @JsonKey(name: 'product_media')  List<ProductMedia> media)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.categoryId,_that.title,_that.titleAm,_that.titleAr,_that.description,_that.descriptionAm,_that.descriptionAr,_that.price,_that.compareAtPrice,_that.currencyCode,_that.isAvailable,_that.isFeatured,_that.isPublished,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.media);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String categoryId,  String title,  String? titleAm,  String? titleAr,  String? description,  String? descriptionAm,  String? descriptionAr,  double price,  double? compareAtPrice,  String currencyCode,  bool isAvailable,  bool isFeatured,  bool isPublished,  int sortOrder,  DateTime? createdAt,  DateTime? updatedAt, @JsonKey(name: 'product_media')  List<ProductMedia> media)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.categoryId,_that.title,_that.titleAm,_that.titleAr,_that.description,_that.descriptionAm,_that.descriptionAr,_that.price,_that.compareAtPrice,_that.currencyCode,_that.isAvailable,_that.isFeatured,_that.isPublished,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.media);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _Product extends Product {
  const _Product({required this.id, required this.categoryId, required this.title, this.titleAm, this.titleAr, this.description, this.descriptionAm, this.descriptionAr, required this.price, this.compareAtPrice, this.currencyCode = 'ETB', this.isAvailable = true, this.isFeatured = false, this.isPublished = true, this.sortOrder = 0, this.createdAt, this.updatedAt, @JsonKey(name: 'product_media')  List<ProductMedia> media = const <ProductMedia>[]}): _media = media,super._();
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override final  String categoryId;
@override final  String title;
@override final  String? titleAm;
@override final  String? titleAr;
@override final  String? description;
@override final  String? descriptionAm;
@override final  String? descriptionAr;
@override final  double price;
@override final  double? compareAtPrice;
@override@JsonKey() final  String currencyCode;
@override@JsonKey() final  bool isAvailable;
@override@JsonKey() final  bool isFeatured;
@override@JsonKey() final  bool isPublished;
@override@JsonKey() final  int sortOrder;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
/// Embedded media, present when the query selected `product_media(*)`.
 final  List<ProductMedia> _media;
/// Embedded media, present when the query selected `product_media(*)`.
@override@JsonKey(name: 'product_media') List<ProductMedia> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}


/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.title, title) || other.title == title)&&(identical(other.titleAm, titleAm) || other.titleAm == titleAm)&&(identical(other.titleAr, titleAr) || other.titleAr == titleAr)&&(identical(other.description, description) || other.description == description)&&(identical(other.descriptionAm, descriptionAm) || other.descriptionAm == descriptionAm)&&(identical(other.descriptionAr, descriptionAr) || other.descriptionAr == descriptionAr)&&(identical(other.price, price) || other.price == price)&&(identical(other.compareAtPrice, compareAtPrice) || other.compareAtPrice == compareAtPrice)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.media, _media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,categoryId,title,titleAm,titleAr,description,descriptionAm,descriptionAr,price,compareAtPrice,currencyCode,isAvailable,isFeatured,isPublished,sortOrder,createdAt,updatedAt,const DeepCollectionEquality().hash(_media));
}

@override
String toString() {
    return 'Product(id: $id, categoryId: $categoryId, title: $title, titleAm: $titleAm, titleAr: $titleAr, description: $description, descriptionAm: $descriptionAm, descriptionAr: $descriptionAr, price: $price, compareAtPrice: $compareAtPrice, currencyCode: $currencyCode, isAvailable: $isAvailable, isFeatured: $isFeatured, isPublished: $isPublished, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, media: $media)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String categoryId, String title, String? titleAm, String? titleAr, String? description, String? descriptionAm, String? descriptionAr, double price, double? compareAtPrice, String currencyCode, bool isAvailable, bool isFeatured, bool isPublished, int sortOrder, DateTime? createdAt, DateTime? updatedAt,@JsonKey(name: 'product_media') List<ProductMedia> media
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = null,Object? title = null,Object? titleAm = freezed,Object? titleAr = freezed,Object? description = freezed,Object? descriptionAm = freezed,Object? descriptionAr = freezed,Object? price = null,Object? compareAtPrice = freezed,Object? currencyCode = null,Object? isAvailable = null,Object? isFeatured = null,Object? isPublished = null,Object? sortOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? media = null,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,titleAm: freezed == titleAm ? _self.titleAm : titleAm // ignore: cast_nullable_to_non_nullable
as String?,titleAr: freezed == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,descriptionAm: freezed == descriptionAm ? _self.descriptionAm : descriptionAm // ignore: cast_nullable_to_non_nullable
as String?,descriptionAr: freezed == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,compareAtPrice: freezed == compareAtPrice ? _self.compareAtPrice : compareAtPrice // ignore: cast_nullable_to_non_nullable
as double?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<ProductMedia>,
  ));
}


}

// dart format on
