// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inquiry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Inquiry {

 String get id; String get channel; String? get productId; String? get deviceId; String? get productTitle; DateTime? get createdAt;
/// Create a copy of Inquiry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InquiryCopyWith<Inquiry> get copyWith => _$InquiryCopyWithImpl<Inquiry>(this as Inquiry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Inquiry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Inquiry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.channel, _this.channel) || other.channel == _this.channel)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.productTitle, _this.productTitle) || other.productTitle == _this.productTitle)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as Inquiry;
  return Object.hash(runtimeType,_this.id,_this.channel,_this.productId,_this.deviceId,_this.productTitle,_this.createdAt);
}

@override
String toString() {
  final _this = this as Inquiry;
  return 'Inquiry(id: ${_this.id}, channel: ${_this.channel}, productId: ${_this.productId}, deviceId: ${_this.deviceId}, productTitle: ${_this.productTitle}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $InquiryCopyWith<$Res>  {
  factory $InquiryCopyWith(Inquiry value, $Res Function(Inquiry) _then) = _$InquiryCopyWithImpl;
@useResult
$Res call({
 String id, String channel, String? productId, String? deviceId, String? productTitle, DateTime? createdAt
});




}
/// @nodoc
class _$InquiryCopyWithImpl<$Res>
    implements $InquiryCopyWith<$Res> {
  _$InquiryCopyWithImpl(this._self, this._then);

  final Inquiry _self;
  final $Res Function(Inquiry) _then;

/// Create a copy of Inquiry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channel = null,Object? productId = freezed,Object? deviceId = freezed,Object? productTitle = freezed,Object? createdAt = freezed,}) {
  return _then(Inquiry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,productTitle: freezed == productTitle ? _self.productTitle : productTitle // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Inquiry].
extension InquiryPatterns on Inquiry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Inquiry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Inquiry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Inquiry value)  $default,){
final _that = this;
switch (_that) {
case _Inquiry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Inquiry value)?  $default,){
final _that = this;
switch (_that) {
case _Inquiry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String channel,  String? productId,  String? deviceId,  String? productTitle,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Inquiry() when $default != null:
return $default(_that.id,_that.channel,_that.productId,_that.deviceId,_that.productTitle,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String channel,  String? productId,  String? deviceId,  String? productTitle,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Inquiry():
return $default(_that.id,_that.channel,_that.productId,_that.deviceId,_that.productTitle,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String channel,  String? productId,  String? deviceId,  String? productTitle,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Inquiry() when $default != null:
return $default(_that.id,_that.channel,_that.productId,_that.deviceId,_that.productTitle,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _Inquiry extends Inquiry {
  const _Inquiry({required this.id, required this.channel, this.productId, this.deviceId, this.productTitle, this.createdAt}): super._();
  

@override final  String id;
@override final  String channel;
@override final  String? productId;
@override final  String? deviceId;
@override final  String? productTitle;
@override final  DateTime? createdAt;

/// Create a copy of Inquiry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InquiryCopyWith<_Inquiry> get copyWith => __$InquiryCopyWithImpl<_Inquiry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Inquiry&&(identical(other.id, id) || other.id == id)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.productTitle, productTitle) || other.productTitle == productTitle)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,channel,productId,deviceId,productTitle,createdAt);
}

@override
String toString() {
    return 'Inquiry(id: $id, channel: $channel, productId: $productId, deviceId: $deviceId, productTitle: $productTitle, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InquiryCopyWith<$Res> implements $InquiryCopyWith<$Res> {
  factory _$InquiryCopyWith(_Inquiry value, $Res Function(_Inquiry) _then) = __$InquiryCopyWithImpl;
@override @useResult
$Res call({
 String id, String channel, String? productId, String? deviceId, String? productTitle, DateTime? createdAt
});




}
/// @nodoc
class __$InquiryCopyWithImpl<$Res>
    implements _$InquiryCopyWith<$Res> {
  __$InquiryCopyWithImpl(this._self, this._then);

  final _Inquiry _self;
  final $Res Function(_Inquiry) _then;

/// Create a copy of Inquiry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channel = null,Object? productId = freezed,Object? deviceId = freezed,Object? productTitle = freezed,Object? createdAt = freezed,}) {
  return _then(_Inquiry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,productTitle: freezed == productTitle ? _self.productTitle : productTitle // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
