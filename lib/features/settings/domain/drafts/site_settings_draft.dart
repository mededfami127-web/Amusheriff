import 'package:flutter/foundation.dart';

import '../entities/site_settings.dart';

/// Write-side DTO for `public.site_settings` (the single row, id = 1).
@immutable
class SiteSettingsDraft {
  const SiteSettingsDraft({
    required this.storeNameEn,
    this.storeNameAm,
    this.storeNameAr,
    this.storeNameOm,
    this.tagline,
    this.about,
    this.logoPath,
    this.currencyCode = 'ETB',
    this.defaultLanguage = 'en',
  });

  final String storeNameEn;
  final String? storeNameAm;
  final String? storeNameAr;
  final String? storeNameOm;
  final String? tagline;
  final String? about;
  final String? logoPath;
  final String currencyCode;
  final String defaultLanguage;

  /// The row is a singleton, so this doubles as insert and update.
  Map<String, dynamic> toRow() => <String, dynamic>{
    'store_name_en': storeNameEn.trim(),
    'store_name_am': _nullIfBlank(storeNameAm),
    'store_name_ar': _nullIfBlank(storeNameAr),
    'store_name_om': _nullIfBlank(storeNameOm),
    'tagline': _nullIfBlank(tagline),
    'about': _nullIfBlank(about),
    'logo_path': _nullIfBlank(logoPath),
    'currency_code': currencyCode.trim().toUpperCase(),
    'default_language': AppLanguage.fromCode(defaultLanguage).code,
  };

  factory SiteSettingsDraft.fromEntity(SiteSettings settings) =>
      SiteSettingsDraft(
        storeNameEn: settings.storeNameEn,
        storeNameAm: settings.storeNameAm,
        storeNameAr: settings.storeNameAr,
        storeNameOm: settings.storeNameOm,
        tagline: settings.tagline,
        about: settings.about,
        logoPath: settings.logoPath,
        currencyCode: settings.currencyCode,
        defaultLanguage: settings.defaultLanguage,
      );
}

String? _nullIfBlank(String? value) {
  final String v = (value ?? '').trim();
  return v.isEmpty ? null : v;
}
