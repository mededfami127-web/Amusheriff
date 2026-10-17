import 'package:flutter/material.dart';

import 'brand_colors.dart';

/// ASM type scale.
///
/// * Display / brand headings — Playfair Display (gold serif, variable `wght`).
/// * Body & UI — Poppins (clean sans).
/// * Arabic — Cairo, with Noto Naskh Arabic as fallback.
/// * Amharic — Noto Sans Ethiopic.
///
/// All families are bundled under `assets/fonts/`; nothing is fetched at
/// runtime.
abstract final class BrandTypography {
  const BrandTypography._();

  static const String displayFamily = 'PlayfairDisplay';
  static const String bodyFamily = 'Poppins';
  static const String arabicFamily = 'Cairo';
  static const String arabicDisplayFamily = 'NotoNaskhArabic';
  static const String ethiopicFamily = 'NotoSansEthiopic';

  /// Families applied, in order, when a glyph is missing from the primary run.
  /// This is what makes Amharic and Arabic render correctly even when the
  /// active locale is English.
  static const List<String> globalFallback = <String>[
    bodyFamily,
    ethiopicFamily,
    arabicFamily,
  ];

  static List<FontVariation> _weight(double w) => <FontVariation>[
    FontVariation('wght', w),
  ];

  // ── Display (Playfair Display) ────────────────────────────────────────────
  static const TextStyle brandTitle = TextStyle(
    fontFamily: displayFamily,
    fontSize: 34,
    height: 1.12,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w700,
    fontVariations: <FontVariation>[FontVariation('wght', 700)],
  );

  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFamily,
    fontSize: 40,
    height: 1.10,
    letterSpacing: 0.4,
    fontVariations: <FontVariation>[FontVariation('wght', 700)],
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFamily,
    fontSize: 30,
    height: 1.16,
    letterSpacing: 0.3,
    fontVariations: <FontVariation>[FontVariation('wght', 650)],
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: displayFamily,
    fontSize: 24,
    height: 1.20,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
  );

  // ── Body (Poppins) ────────────────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 20,
    height: 1.30,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 17,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    height: 1.50,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    height: 1.50,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12.5,
    height: 1.45,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  /// Price scale — always rendered with the gold gradient shader.
  static const TextStyle price = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const TextStyle priceStruck = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.lineThrough,
  );

  /// Convenience accessor for a specific variable weight on the display face.
  static TextStyle displayWeighted(double wght, {double size = 32}) =>
      TextStyle(
        fontFamily: displayFamily,
        fontSize: size,
        height: 1.14,
        fontVariations: _weight(wght),
      );

  /// Locale-aware body style: Arabic and Amharic get their own faces so that
  /// glyph shaping is correct rather than falling back to a tofu box.
  static TextStyle bodyForLocale(Locale locale, {TextStyle? base}) {
    final TextStyle style = base ?? bodyMedium;
    switch (locale.languageCode) {
      case 'ar':
        return style.copyWith(
          fontFamily: arabicFamily,
          fontFamilyFallback: const [arabicDisplayFamily, bodyFamily],
          height: 1.75,
        );
      case 'am':
        return style.copyWith(
          fontFamily: ethiopicFamily,
          fontFamilyFallback: const [bodyFamily],
          height: 1.65,
        );
      default:
        return style;
    }
  }

  /// Locale-aware display style for serif headings.
  static TextStyle displayForLocale(Locale locale, {TextStyle? base}) {
    final TextStyle style = base ?? displayMedium;
    switch (locale.languageCode) {
      case 'ar':
        return style.copyWith(
          fontFamily: arabicDisplayFamily,
          fontFamilyFallback: const [arabicFamily],
          fontVariations: _weight(700),
          height: 1.45,
        );
      case 'am':
        return style.copyWith(
          fontFamily: ethiopicFamily,
          fontFamilyFallback: const [displayFamily, bodyFamily],
          fontVariations: _weight(700),
          height: 1.35,
        );
      default:
        return style;
    }
  }

  /// Text theme wired into Material 3, with gold-on-dark defaults resolved by
  /// [ThemeData.colorScheme].
  static TextTheme textTheme(Color body, Color muted, Color heading) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: heading),
      displayMedium: displayMedium.copyWith(color: heading),
      displaySmall: displaySmall.copyWith(color: heading),
      headlineLarge: displaySmall.copyWith(color: heading, fontSize: 26),
      headlineMedium: displayWeighted(600, size: 22).copyWith(color: heading),
      headlineSmall: displayWeighted(600, size: 20).copyWith(color: heading),
      titleLarge: titleLarge.copyWith(color: heading),
      titleMedium: titleMedium.copyWith(color: body),
      titleSmall: labelLarge.copyWith(color: body),
      bodyLarge: bodyLarge.copyWith(color: body),
      bodyMedium: bodyMedium.copyWith(color: body),
      bodySmall: bodySmall.copyWith(color: muted),
      labelLarge: labelLarge.copyWith(color: body),
      labelMedium: labelSmall.copyWith(color: muted),
      labelSmall: labelSmall.copyWith(color: muted),
    );
  }

  /// Muted tone used for secondary copy on each surface brightness.
  static Color mutedOn(Brightness brightness) => brightness == Brightness.dark
      ? BrandColors.goldLight.withValues(alpha: 0.72)
      : BrandColors.charcoal.withValues(alpha: 0.60);
}
