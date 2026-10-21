import 'package:freezed_annotation/freezed_annotation.dart';

part 'site_settings.freezed.dart';
part 'site_settings.g.dart';

/// Owner-editable storefront settings. Backed by the single-row
/// `public.site_settings` table (id = 1), so every client sees the same
/// brand copy and the admin can change it live.
@freezed
abstract class SiteSettings with _$SiteSettings {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory SiteSettings({
    @Default(1) int id,
    @Default('Amusheriff Arabiyan Mejlis and Furniture') String storeNameEn,
    @Default('አሙሸሪፍ አረቢያን መጅሊስ እና ፈርኒቸር') String storeNameAm,
    @Default('أمشريف عربيان مجلس والأثاث') String storeNameAr,
    @Default('Amusheriff Arabiyaan Majlis fi Meeshaa Manaa') String storeNameOm,
    String? tagline,
    String? about,
    String? logoPath,
    @Default('ETB') String currencyCode,
    @Default('en') String defaultLanguage,
    DateTime? updatedAt,
  }) = _SiteSettings;

  const SiteSettings._();

  factory SiteSettings.fromJson(Map<String, dynamic> json) =>
      _$SiteSettingsFromJson(json);

  /// Compile-time defaults, used before the first row arrives from Supabase.
  static const SiteSettings fallback = SiteSettings();

  String storeNameFor(String languageCode) => switch (languageCode) {
    'am' => _pick(storeNameAm, storeNameEn),
    'ar' => _pick(storeNameAr, storeNameEn),
    'om' => _pick(storeNameOm, storeNameEn),
    _ => _pick(storeNameEn, storeNameAm),
  };

  bool get hasAbout => about != null && about!.trim().isNotEmpty;
  bool get hasTagline => tagline != null && tagline!.trim().isNotEmpty;
}

String _pick(String primary, String fallback) =>
    primary.trim().isNotEmpty ? primary : fallback;

/// Languages the storefront ships with.
enum AppLanguage {
  en('en', 'English', 'English'),
  am('am', 'አማርኛ', 'Amharic'),
  ar('ar', 'العربية', 'Arabic'),
  om('om', 'Afaan Oromoo', 'Oromo');

  const AppLanguage(this.code, this.nativeName, this.englishName);

  final String code;
  final String nativeName;
  final String englishName;

  bool get isRtl => this == AppLanguage.ar;

  static AppLanguage fromCode(String? code) => AppLanguage.values.firstWhere(
    (AppLanguage l) => l.code == code,
    orElse: () => AppLanguage.en,
  );

  /// Resolves the device locale to a supported language, defaulting to English.
  static AppLanguage fromDeviceLocale(String? languageCode) {
    final String code = (languageCode ?? 'en').toLowerCase();
    return AppLanguage.values.firstWhere(
      (AppLanguage l) => l.code == code,
      orElse: () => AppLanguage.en,
    );
  }
}
