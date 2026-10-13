// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_media.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductMedia {

 String get id; String get productId; MediaKind get kind; String get storagePath; String? get thumbnailPath; int? get durationSeconds; bool get isCover; int get sortOrder; DateTime? get createdAt;
/// Create a copy of ProductMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductMediaCopyWith<ProductMedia> get copyWith => _$ProductMediaCopyWithImpl<ProductMedia>(this as ProductMedia, _$identity);

  /// Serializes this ProductMedia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProductMedia;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductMedia&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.storagePath, _this.storagePath) || other.storagePath == _this.storagePath)&&(identical(other.thumbnailPath, _this.thumbnailPath) || other.thumbnailPath == _this.thumbnailPath)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds)&&(identical(other.isCover, _this.isCover) || other.isCover == _this.isCover)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProductMedia;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.kind,_this.storagePath,_this.thumbnailPath,_this.durationSeconds,_this.isCover,_this.sortOrder,_this.createdAt);
}

@override
String toString() {
  final _this = this as ProductMedia;
  return 'ProductMedia(id: ${_this.id}, productId: ${_this.productId}, kind: ${_this.kind}, storagePath: ${_this.storagePath}, thumbnailPath: ${_this.thumbnailPath}, durationSeconds: ${_this.durationSeconds}, isCover: ${_this.isCover}, sortOrder: ${_this.sortOrder}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ProductMediaCopyWith<$Res>  {
  factory $ProductMediaCopyWith(ProductMedia value, $Res Function(ProductMedia) _then) = _$ProductMediaCopyWithImpl;
@useResult
$Res call({
 String id, String productId, MediaKind kind, String storagePath, String? thumbnailPath, int? durationSeconds, bool isCover, int sortOrder, DateTime? createdAt
});




}
/// @nodoc
class _$ProductMediaCopyWithImpl<$Res>
    implements $ProductMediaCopyWith<$Res> {
  _$ProductMediaCopyWithImpl(this._self, this._then);

  final ProductMedia _self;
  final $Res Function(ProductMedia) _then;

/// Create a copy of ProductMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? kind = null,Object? storagePath = null,Object? thumbnailPath = freezed,Object? durationSeconds = freezed,Object? isCover = null,Object? sortOrder = null,Object? createdAt = freezed,}) {
  return _then(ProductMedia(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MediaKind,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,thumbnailPath: freezed == thumbnailPath ? _self.thumbnailPath : thumbnailPath // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,isCover: null == isCover ? _self.isCover : isCover // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductMedia].
extension ProductMediaPatterns on ProductMedia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductMedia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductMedia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductMedia value)  $default,){
final _that = this;
switch (_that) {
case _ProductMedia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductMedia value)?  $default,){
final _that = this;
switch (_that) {
case _ProductMedia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productId,  MediaKind kind,  String storagePath,  String? thumbnailPath,  int? durationSeconds,  bool isCover,  int sortOrder,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductMedia() when $default != null:
return $default(_that.id,_that.productId,_that.kind,_that.storagePath,_that.thumbnailPath,_that.durationSeconds,_that.isCover,_that.sortOrder,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productId,  MediaKind kind,  String storagePath,  String? thumbnailPath,  int? durationSeconds,  bool isCover,  int sortOrder,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ProductMedia():
return $default(_that.id,_that.productId,_that.kind,_that.storagePath,_that.thumbnailPath,_that.durationSeconds,_that.isCover,_that.sortOrder,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productId,  MediaKind kind,  String storagePath,  String? thumbnailPath,  int? durationSeconds,  bool isCover,  int sortOrder,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductMedia() when $default != null:
return $default(_that.id,_that.productId,_that.kind,_that.storagePath,_that.thumbnailPath,_that.durationSeconds,_that.isCover,_that.sortOrder,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _ProductMedia extends ProductMedia {
  const _ProductMedia({required this.id, required this.productId, required this.kind, required this.storagePath, this.thumbnailPath, this.durationSeconds, this.isCover = false, this.sortOrder = 0, this.createdAt}): super._();
  factory _ProductMedia.fromJson(Map<String, dynamic> json) => _$ProductMediaFromJson(json);

@override final  String id;
@override final  String productId;
@override final  MediaKind kind;
@override final  String storagePath;
@override final  String? thumbnailPath;
@override final  int? durationSeconds;
@override@JsonKey() final  bool isCover;
@override@JsonKey() final  int sortOrder;
@override final  DateTime? createdAt;

/// Create a copy of ProductMedia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductMediaCopyWith<_ProductMedia> get copyWith => __$ProductMediaCopyWithImpl<_ProductMedia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductMediaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductMedia&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.thumbnailPath, thumbnailPath) || other.thumbnailPath == thumbnailPath)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.isCover, isCover) || other.isCover == isCover)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,kind,storagePath,thumbnailPath,durationSeconds,isCover,sortOrder,createdAt);
}

@override
String toString() {
    return 'ProductMedia(id: $id, productId: $productId, kind: $kind, storagePath: $storagePath, thumbnailPath: $thumbnailPath, durationSeconds: $durationSeconds, isCover: $isCover, sortOrder: $sortOrder, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProductMediaCopyWith<$Res> implements $ProductMediaCopyWith<$Res> {
  factory _$ProductMediaCopyWith(_ProductMedia value, $Res Function(_ProductMedia) _then) = __$ProductMediaCopyWithImpl;
@override @useResult
$Res call({
 String id, String productId, MediaKind kind, String storagePath, String? thumbnailPath, int? durationSeconds, bool isCover, int sortOrder, DateTime? createdAt
});




}
/// @nodoc
class __$ProductMediaCopyWithImpl<$Res>
    implements _$ProductMediaCopyWith<$Res> {
  __$ProductMediaCopyWithImpl(this._self, this._then);

  final _ProductMedia _self;
  final $Res Function(_ProductMedia) _then;

/// Create a copy of ProductMedia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? kind = null,Object? storagePath = null,Object? thumbnailPath = freezed,Object? durationSeconds = freezed,Object? isCover = null,Object? sortOrder = null,Object? createdAt = freezed,}) {
  return _then(_ProductMedia(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MediaKind,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,thumbnailPath: freezed == thumbnailPath ? _self.thumbnailPath : thumbnailPath // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,isCover: null == isCover ? _self.isCover : isCover // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
