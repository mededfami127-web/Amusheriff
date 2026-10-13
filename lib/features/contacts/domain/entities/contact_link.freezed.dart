// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContactLink {

 String get id; ContactKind get kind; String get label; String get value; bool get isPrimary; bool get isVisible; int get sortOrder; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ContactLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactLinkCopyWith<ContactLink> get copyWith => _$ContactLinkCopyWithImpl<ContactLink>(this as ContactLink, _$identity);

  /// Serializes this ContactLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContactLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactLink&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.isPrimary, _this.isPrimary) || other.isPrimary == _this.isPrimary)&&(identical(other.isVisible, _this.isVisible) || other.isVisible == _this.isVisible)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContactLink;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.label,_this.value,_this.isPrimary,_this.isVisible,_this.sortOrder,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as ContactLink;
  return 'ContactLink(id: ${_this.id}, kind: ${_this.kind}, label: ${_this.label}, value: ${_this.value}, isPrimary: ${_this.isPrimary}, isVisible: ${_this.isVisible}, sortOrder: ${_this.sortOrder}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ContactLinkCopyWith<$Res>  {
  factory $ContactLinkCopyWith(ContactLink value, $Res Function(ContactLink) _then) = _$ContactLinkCopyWithImpl;
@useResult
$Res call({
 String id, ContactKind kind, String label, String value, bool isPrimary, bool isVisible, int sortOrder, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ContactLinkCopyWithImpl<$Res>
    implements $ContactLinkCopyWith<$Res> {
  _$ContactLinkCopyWithImpl(this._self, this._then);

  final ContactLink _self;
  final $Res Function(ContactLink) _then;

/// Create a copy of ContactLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? label = null,Object? value = null,Object? isPrimary = null,Object? isVisible = null,Object? sortOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(ContactLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ContactKind,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactLink].
extension ContactLinkPatterns on ContactLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactLink value)  $default,){
final _that = this;
switch (_that) {
case _ContactLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactLink value)?  $default,){
final _that = this;
switch (_that) {
case _ContactLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ContactKind kind,  String label,  String value,  bool isPrimary,  bool isVisible,  int sortOrder,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactLink() when $default != null:
return $default(_that.id,_that.kind,_that.label,_that.value,_that.isPrimary,_that.isVisible,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ContactKind kind,  String label,  String value,  bool isPrimary,  bool isVisible,  int sortOrder,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ContactLink():
return $default(_that.id,_that.kind,_that.label,_that.value,_that.isPrimary,_that.isVisible,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ContactKind kind,  String label,  String value,  bool isPrimary,  bool isVisible,  int sortOrder,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ContactLink() when $default != null:
return $default(_that.id,_that.kind,_that.label,_that.value,_that.isPrimary,_that.isVisible,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _ContactLink extends ContactLink {
  const _ContactLink({required this.id, required this.kind, required this.label, required this.value, this.isPrimary = false, this.isVisible = true, this.sortOrder = 0, this.createdAt, this.updatedAt}): super._();
  factory _ContactLink.fromJson(Map<String, dynamic> json) => _$ContactLinkFromJson(json);

@override final  String id;
@override final  ContactKind kind;
@override final  String label;
@override final  String value;
@override@JsonKey() final  bool isPrimary;
@override@JsonKey() final  bool isVisible;
@override@JsonKey() final  int sortOrder;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ContactLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactLinkCopyWith<_ContactLink> get copyWith => __$ContactLinkCopyWithImpl<_ContactLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactLinkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactLink&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,label,value,isPrimary,isVisible,sortOrder,createdAt,updatedAt);
}

@override
String toString() {
    return 'ContactLink(id: $id, kind: $kind, label: $label, value: $value, isPrimary: $isPrimary, isVisible: $isVisible, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ContactLinkCopyWith<$Res> implements $ContactLinkCopyWith<$Res> {
  factory _$ContactLinkCopyWith(_ContactLink value, $Res Function(_ContactLink) _then) = __$ContactLinkCopyWithImpl;
@override @useResult
$Res call({
 String id, ContactKind kind, String label, String value, bool isPrimary, bool isVisible, int sortOrder, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ContactLinkCopyWithImpl<$Res>
    implements _$ContactLinkCopyWith<$Res> {
  __$ContactLinkCopyWithImpl(this._self, this._then);

  final _ContactLink _self;
  final $Res Function(_ContactLink) _then;

/// Create a copy of ContactLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? label = null,Object? value = null,Object? isPrimary = null,Object? isVisible = null,Object? sortOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ContactLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ContactKind,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
