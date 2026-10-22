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

  /// The name to show for [languageCode], with the pre-rename spellings that
  /// still sit in `public.site_settings` replaced.
  ///
  /// The row is the source of truth for branding, so a project whose row was
  /// never updated kept rendering "Amu Sharif Arabiyan Majlis" no matter what
  /// the compiled defaults said. A stored value that is blank, one of the old
  /// spellings, or an old-brand name without the current wording ("Mejlis and
  /// Furniture") therefore falls back to [brandFallback] — the localised
  /// `appTitle` — instead of reaching the screen. A name the owner typed that
  /// is not an old spelling is shown exactly as typed.
  String displayName(String languageCode, {String? brandFallback}) {
    // The slot for the active language only: falling across to English first
    // would put an English legacy spelling on an Amharic screen.
    final String stored = switch (languageCode) {
      'am' => storeNameAm,
      'ar' => storeNameAr,
      'om' => storeNameOm,
      _ => storeNameEn,
    }.trim();
    if (stored.isNotEmpty && !isLegacyBrandName(stored)) return stored;
    final String fallback = (brandFallback ?? '').trim();
    return fallback.isNotEmpty ? fallback : canonicalBrandEn;
  }

  bool get hasAbout => about != null && about!.trim().isNotEmpty;
  bool get hasTagline => tagline != null && tagline!.trim().isNotEmpty;

  /// The brand as it reads after the rename.
  static const String canonicalBrandEn =
      'Amusheriff Arabiyan Mejlis and Furniture';

  /// Spellings shipped before the rename, lower-cased with single spaces.
  static const Set<String> legacyBrandNames = <String>{
    'amu sharif arabiyan majlis',
    'amu sharif arabian majlis',
    'amu sharif arabiyan majlis and furniture',
    'amu sharif majlis',
    'amu sharif',
    'amusheriff arabiyan majlis',
    'asmusheriff arabiyan majlis',
    'aamu sharif arabiyaan majlis',
    'አሙ ሸሪፍ አረቢያን መጅሊስ',
    'المجلس العربي عمو شريف',
  };

  /// Tokens that only the current brand carries, in every shipped script.
  static const List<String> _brandMarkers = <String>[
    'furniture',
    'mejlis and',
    'majlis and',
    'meeshaa',
    'ፈርኒቸር',
    'والأثاث',
  ];

  /// Tokens that identify the old shop name.
  static const List<String> _oldBrandMarkers = <String>[
    'amu sharif',
    'amusheriff',
    'asmusheriff',
    'aamu sharif',
    'عمو شريف',
    'አሙ ሸሪፍ',
  ];

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  static bool _hasAny(String haystack, List<String> needles) =>
      needles.any(haystack.contains);

  /// True when [value] is blank or still reads as the pre-rename shop name.
  ///
  /// Case, extra spaces and the legacy "Majlis"/"Majlis and" tail are all
  /// normalised away first, so "AMU SHARIF  ARABIYAN MAJLIS" matches too. A
  /// custom name the owner typed is not touched unless it also names the old
  /// shop *and* lacks the current wording.
  static bool isLegacyBrandName(String? value) {
    final String normalized = _normalize(value ?? '');
    if (normalized.isEmpty) return true;
    if (legacyBrandNames.contains(normalized)) return true;
    return _hasAny(normalized, _oldBrandMarkers) &&
        !_hasAny(normalized, _brandMarkers);
  }

  /// True only for a blank value or an exact old spelling — used where a free
  /// text field (the live hero title) must keep the owner's own words.
  static bool isOldBrandSpelling(String? value) {
    final String normalized = _normalize(value ?? '');
    return normalized.isEmpty || legacyBrandNames.contains(normalized);
  }
}

String _pick(String primary, String fallback) {
  if (primary.trim().isNotEmpty) return primary;
  if (fallback.trim().isNotEmpty) return fallback;
  return SiteSettings.canonicalBrandEn;
}

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
