// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SiteSettings _$SiteSettingsFromJson(
  Map<String, dynamic> json,
) => _SiteSettings(
  id: (json['id'] as num?)?.toInt() ?? 1,
  storeNameEn:
      json['store_name_en'] as String? ??
      'Amusheriff Arabiyan Mejlis and Furniture',
  storeNameAm: json['store_name_am'] as String? ?? 'አሙሸሪፍ አረቢያን መጅሊስ እና ፈርኒቸር',
  storeNameAr: json['store_name_ar'] as String? ?? 'أمشريف عربيان مجلس والأثاث',
  storeNameOm:
      json['store_name_om'] as String? ??
      'Amusheriff Arabiyaan Majlis fi Meeshaa Manaa',
  tagline: json['tagline'] as String?,
  about: json['about'] as String?,
  logoPath: json['logo_path'] as String?,
  currencyCode: json['currency_code'] as String? ?? 'ETB',
  defaultLanguage: json['default_language'] as String? ?? 'en',
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SiteSettingsToJson(_SiteSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'store_name_en': instance.storeNameEn,
      'store_name_am': instance.storeNameAm,
      'store_name_ar': instance.storeNameAr,
      'store_name_om': instance.storeNameOm,
      'tagline': ?instance.tagline,
      'about': ?instance.about,
      'logo_path': ?instance.logoPath,
      'currency_code': instance.currencyCode,
      'default_language': instance.defaultLanguage,
      'updated_at': ?instance.updatedAt?.toIso8601String(),
    };
