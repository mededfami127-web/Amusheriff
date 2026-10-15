// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SiteSettings {

 int get id; String get storeNameEn; String get storeNameAm; String get storeNameAr; String get storeNameOm; String? get tagline; String? get about; String? get logoPath; String get currencyCode; String get defaultLanguage; DateTime? get updatedAt;
/// Create a copy of SiteSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteSettingsCopyWith<SiteSettings> get copyWith => _$SiteSettingsCopyWithImpl<SiteSettings>(this as SiteSettings, _$identity);

  /// Serializes this SiteSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SiteSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteSettings&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.storeNameEn, _this.storeNameEn) || other.storeNameEn == _this.storeNameEn)&&(identical(other.storeNameAm, _this.storeNameAm) || other.storeNameAm == _this.storeNameAm)&&(identical(other.storeNameAr, _this.storeNameAr) || other.storeNameAr == _this.storeNameAr)&&(identical(other.storeNameOm, _this.storeNameOm) || other.storeNameOm == _this.storeNameOm)&&(identical(other.tagline, _this.tagline) || other.tagline == _this.tagline)&&(identical(other.about, _this.about) || other.about == _this.about)&&(identical(other.logoPath, _this.logoPath) || other.logoPath == _this.logoPath)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.defaultLanguage, _this.defaultLanguage) || other.defaultLanguage == _this.defaultLanguage)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SiteSettings;
  return Object.hash(runtimeType,_this.id,_this.storeNameEn,_this.storeNameAm,_this.storeNameAr,_this.storeNameOm,_this.tagline,_this.about,_this.logoPath,_this.currencyCode,_this.defaultLanguage,_this.updatedAt);
}

@override
String toString() {
  final _this = this as SiteSettings;
  return 'SiteSettings(id: ${_this.id}, storeNameEn: ${_this.storeNameEn}, storeNameAm: ${_this.storeNameAm}, storeNameAr: ${_this.storeNameAr}, storeNameOm: ${_this.storeNameOm}, tagline: ${_this.tagline}, about: ${_this.about}, logoPath: ${_this.logoPath}, currencyCode: ${_this.currencyCode}, defaultLanguage: ${_this.defaultLanguage}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $SiteSettingsCopyWith<$Res>  {
  factory $SiteSettingsCopyWith(SiteSettings value, $Res Function(SiteSettings) _then) = _$SiteSettingsCopyWithImpl;
@useResult
$Res call({
 int id, String storeNameEn, String storeNameAm, String storeNameAr, String storeNameOm, String? tagline, String? about, String? logoPath, String currencyCode, String defaultLanguage, DateTime? updatedAt
});




}
/// @nodoc
class _$SiteSettingsCopyWithImpl<$Res>
    implements $SiteSettingsCopyWith<$Res> {
  _$SiteSettingsCopyWithImpl(this._self, this._then);

  final SiteSettings _self;
  final $Res Function(SiteSettings) _then;

/// Create a copy of SiteSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeNameEn = null,Object? storeNameAm = null,Object? storeNameAr = null,Object? storeNameOm = null,Object? tagline = freezed,Object? about = freezed,Object? logoPath = freezed,Object? currencyCode = null,Object? defaultLanguage = null,Object? updatedAt = freezed,}) {
  return _then(SiteSettings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeNameEn: null == storeNameEn ? _self.storeNameEn : storeNameEn // ignore: cast_nullable_to_non_nullable
as String,storeNameAm: null == storeNameAm ? _self.storeNameAm : storeNameAm // ignore: cast_nullable_to_non_nullable
as String,storeNameAr: null == storeNameAr ? _self.storeNameAr : storeNameAr // ignore: cast_nullable_to_non_nullable
as String,storeNameOm: null == storeNameOm ? _self.storeNameOm : storeNameOm // ignore: cast_nullable_to_non_nullable
as String,tagline: freezed == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String?,about: freezed == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as String?,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,defaultLanguage: null == defaultLanguage ? _self.defaultLanguage : defaultLanguage // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SiteSettings].
extension SiteSettingsPatterns on SiteSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SiteSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SiteSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SiteSettings value)  $default,){
final _that = this;
switch (_that) {
case _SiteSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SiteSettings value)?  $default,){
final _that = this;
switch (_that) {
case _SiteSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String storeNameEn,  String storeNameAm,  String storeNameAr,  String storeNameOm,  String? tagline,  String? about,  String? logoPath,  String currencyCode,  String defaultLanguage,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SiteSettings() when $default != null:
return $default(_that.id,_that.storeNameEn,_that.storeNameAm,_that.storeNameAr,_that.storeNameOm,_that.tagline,_that.about,_that.logoPath,_that.currencyCode,_that.defaultLanguage,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String storeNameEn,  String storeNameAm,  String storeNameAr,  String storeNameOm,  String? tagline,  String? about,  String? logoPath,  String currencyCode,  String defaultLanguage,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SiteSettings():
return $default(_that.id,_that.storeNameEn,_that.storeNameAm,_that.storeNameAr,_that.storeNameOm,_that.tagline,_that.about,_that.logoPath,_that.currencyCode,_that.defaultLanguage,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String storeNameEn,  String storeNameAm,  String storeNameAr,  String storeNameOm,  String? tagline,  String? about,  String? logoPath,  String currencyCode,  String defaultLanguage,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SiteSettings() when $default != null:
return $default(_that.id,_that.storeNameEn,_that.storeNameAm,_that.storeNameAr,_that.storeNameOm,_that.tagline,_that.about,_that.logoPath,_that.currencyCode,_that.defaultLanguage,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class _SiteSettings extends SiteSettings {
  const _SiteSettings({this.id = 1, this.storeNameEn = 'Amu Sharif Arabiyan Majlis', this.storeNameAm = 'አሙ ሸሪፍ አረቢያን መጅሊስ', this.storeNameAr = 'المجلس العربي عمو شريف', this.storeNameOm = 'Aamu Sharif Arabiyaan Majlis', this.tagline, this.about, this.logoPath, this.currencyCode = 'ETB', this.defaultLanguage = 'en', this.updatedAt}): super._();
  factory _SiteSettings.fromJson(Map<String, dynamic> json) => _$SiteSettingsFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String storeNameEn;
@override@JsonKey() final  String storeNameAm;
@override@JsonKey() final  String storeNameAr;
@override@JsonKey() final  String storeNameOm;
@override final  String? tagline;
@override final  String? about;
@override final  String? logoPath;
@override@JsonKey() final  String currencyCode;
@override@JsonKey() final  String defaultLanguage;
@override final  DateTime? updatedAt;

/// Create a copy of SiteSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteSettingsCopyWith<_SiteSettings> get copyWith => __$SiteSettingsCopyWithImpl<_SiteSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.storeNameEn, storeNameEn) || other.storeNameEn == storeNameEn)&&(identical(other.storeNameAm, storeNameAm) || other.storeNameAm == storeNameAm)&&(identical(other.storeNameAr, storeNameAr) || other.storeNameAr == storeNameAr)&&(identical(other.storeNameOm, storeNameOm) || other.storeNameOm == storeNameOm)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.about, about) || other.about == about)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.defaultLanguage, defaultLanguage) || other.defaultLanguage == defaultLanguage)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,storeNameEn,storeNameAm,storeNameAr,storeNameOm,tagline,about,logoPath,currencyCode,defaultLanguage,updatedAt);
}

@override
String toString() {
    return 'SiteSettings(id: $id, storeNameEn: $storeNameEn, storeNameAm: $storeNameAm, storeNameAr: $storeNameAr, storeNameOm: $storeNameOm, tagline: $tagline, about: $about, logoPath: $logoPath, currencyCode: $currencyCode, defaultLanguage: $defaultLanguage, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SiteSettingsCopyWith<$Res> implements $SiteSettingsCopyWith<$Res> {
  factory _$SiteSettingsCopyWith(_SiteSettings value, $Res Function(_SiteSettings) _then) = __$SiteSettingsCopyWithImpl;
@override @useResult
$Res call({
 int id, String storeNameEn, String storeNameAm, String storeNameAr, String storeNameOm, String? tagline, String? about, String? logoPath, String currencyCode, String defaultLanguage, DateTime? updatedAt
});




}
/// @nodoc
class __$SiteSettingsCopyWithImpl<$Res>
    implements _$SiteSettingsCopyWith<$Res> {
  __$SiteSettingsCopyWithImpl(this._self, this._then);

  final _SiteSettings _self;
  final $Res Function(_SiteSettings) _then;

/// Create a copy of SiteSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeNameEn = null,Object? storeNameAm = null,Object? storeNameAr = null,Object? storeNameOm = null,Object? tagline = freezed,Object? about = freezed,Object? logoPath = freezed,Object? currencyCode = null,Object? defaultLanguage = null,Object? updatedAt = freezed,}) {
  return _then(_SiteSettings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeNameEn: null == storeNameEn ? _self.storeNameEn : storeNameEn // ignore: cast_nullable_to_non_nullable
as String,storeNameAm: null == storeNameAm ? _self.storeNameAm : storeNameAm // ignore: cast_nullable_to_non_nullable
as String,storeNameAr: null == storeNameAr ? _self.storeNameAr : storeNameAr // ignore: cast_nullable_to_non_nullable
as String,storeNameOm: null == storeNameOm ? _self.storeNameOm : storeNameOm // ignore: cast_nullable_to_non_nullable
as String,tagline: freezed == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String?,about: freezed == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as String?,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,defaultLanguage: null == defaultLanguage ? _self.defaultLanguage : defaultLanguage // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
