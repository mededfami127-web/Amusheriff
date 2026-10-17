import 'package:flutter/material.dart';

import 'brand_colors.dart';
import 'gradients.dart';
import 'typography.dart';

/// Material 3 themes for ASM.
///
/// Light = ivory parchment with charcoal ink and gold hairlines.
/// Dark  = deep plum / charcoal with gold accents.
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: BrandColors.royalViolet,
          brightness: Brightness.light,
        ).copyWith(
          primary: BrandColors.royalViolet,
          onPrimary: BrandColors.ivory,
          secondary: BrandColors.gold,
          onSecondary: BrandColors.charcoal,
          tertiary: BrandColors.magenta,
          surface: BrandColors.ivory,
          onSurface: BrandColors.charcoal,
          surfaceContainerHighest: const Color(0xFFF1EADD),
          outline: BrandColors.goldHairline,
          error: BrandColors.danger,
        );
    return _base(scheme);
  }

  static ThemeData dark() {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: BrandColors.magenta,
          brightness: Brightness.dark,
        ).copyWith(
          primary: BrandColors.gold,
          onPrimary: BrandColors.charcoal,
          secondary: BrandColors.magenta,
          onSecondary: BrandColors.ivory,
          tertiary: BrandColors.royalViolet,
          surface: BrandColors.deepPlum,
          onSurface: BrandColors.ivory,
          surfaceContainerHighest: BrandColors.plumSurface,
          outline: BrandColors.goldHairline,
          error: const Color(0xFFFFB4AB),
        );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final bool isDark = scheme.brightness == Brightness.dark;
    final Color heading = isDark ? BrandColors.goldLight : BrandColors.charcoal;
    final Color muted = BrandTypography.mutedOn(scheme.brightness);
    final TextTheme text = BrandTypography.textTheme(
      scheme.onSurface,
      muted,
      heading,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      fontFamily: BrandTypography.bodyFamily,
      fontFamilyFallback: BrandTypography.globalFallback,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: heading,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: BrandTypography.displayWeighted(
          600,
          size: 22,
        ).copyWith(color: heading, letterSpacing: 1.4),
      ),
      cardTheme: CardThemeData(
        color: isDark ? BrandColors.plumSurface : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: BrandColors.goldHairline),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: BrandColors.goldHairline,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? BrandColors.plumSurface
            : Colors.white.withValues(alpha: 0.85),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: _inputBorder(BrandColors.goldHairline),
        enabledBorder: _inputBorder(BrandColors.goldHairline),
        focusedBorder: _inputBorder(BrandColors.gold, width: 1.6),
        errorBorder: _inputBorder(BrandColors.danger),
        focusedErrorBorder: _inputBorder(BrandColors.danger, width: 1.6),
        labelStyle: text.bodyMedium,
        hintStyle: text.bodyMedium?.copyWith(color: muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BrandColors.royalViolet,
          foregroundColor: BrandColors.ivory,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          textStyle: BrandTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark
              ? BrandColors.goldLight
              : BrandColors.charcoal,
          side: const BorderSide(color: BrandColors.gold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          textStyle: BrandTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark
              ? BrandColors.goldLight
              : BrandColors.royalViolet,
          textStyle: BrandTypography.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? BrandColors.plumSurface : Colors.white,
        selectedColor: BrandColors.royalViolet,
        side: const BorderSide(color: BrandColors.goldHairline),
        labelStyle: BrandTypography.labelSmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? BrandColors.plumSurface
            : BrandColors.charcoal,
        contentTextStyle: BrandTypography.bodyMedium.copyWith(
          color: BrandColors.ivory,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: BrandColors.gold,
        linearTrackColor: BrandColors.goldHairline,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  /// Gold hairline gradient rule used across headers and footers.
  static Widget get goldRule => Container(
    height: 1,
    decoration: const BoxDecoration(gradient: BrandGradients.goldHorizontal),
  );
}
