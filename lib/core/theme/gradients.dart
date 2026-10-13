import 'package:flutter/material.dart';

import 'brand_colors.dart';

/// Reusable ASM gradients: the purple→magenta brand sweep and the metallic
/// gold sheen used on headings, prices, borders and dividers.
abstract final class BrandGradients {
  const BrandGradients._();

  /// Primary brand sweep, left → right.
  static const LinearGradient brand = LinearGradient(
    colors: [BrandColors.royalViolet, BrandColors.magenta],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Vertical variant, handy for large hero panels.
  static const LinearGradient brandVertical = LinearGradient(
    colors: [BrandColors.royalViolet, BrandColors.magenta],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Metallic gold sheen for accents, prices and hairline rules.
  static const LinearGradient gold = LinearGradient(
    colors: [BrandColors.goldLight, BrandColors.goldDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldHorizontal = LinearGradient(
    colors: [BrandColors.goldLight, BrandColors.goldDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Warm accent sweep (orange → soft yellow), used very sparingly.
  static const LinearGradient warmAccent = LinearGradient(
    colors: [BrandColors.warmOrange, BrandColors.softYellow],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Wraps [child] in a gold shader fill, mimicking the logo wordmark.
  static Widget goldText({required Widget child}) => ShaderMask(
        shaderCallback: goldHorizontal.createShader,
        blendMode: BlendMode.srcIn,
        child: child,
      );
}
