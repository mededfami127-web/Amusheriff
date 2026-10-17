import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';
import '../theme/gradients.dart';
import '../theme/typography.dart';

/// The ASM badge (`assets/brand/logo.png`).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 48, this.onDark = false});

  final double size;

  /// Renders the transparent monogram variant instead of the solid badge.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      onDark ? 'assets/brand/logo_transparent.png' : 'assets/brand/logo.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
      semanticLabel: 'ASM',
    );
  }
}

/// The brand name in the active locale, set in the gold display face with the
/// Amharic and Arabic lines rendered in their own scripts.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    required this.english,
    this.amharic,
    this.arabic,
    this.alignment = CrossAxisAlignment.start,
    this.compact = false,
  });

  final String english;
  final String? amharic;
  final String? arabic;
  final CrossAxisAlignment alignment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color heading = dark ? BrandColors.goldLight : BrandColors.charcoal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: <Widget>[
        ShaderMask(
          shaderCallback: BrandGradients.goldHorizontal.createShader,
          blendMode: BlendMode.srcIn,
          child: Text(
            english.toUpperCase(),
            textAlign: alignment == CrossAxisAlignment.center
                ? TextAlign.center
                : TextAlign.start,
            style:
                (compact
                        ? BrandTypography.displayWeighted(700, size: 17)
                        : BrandTypography.brandTitle)
                    .copyWith(
                      color: BrandColors.gold,
                      letterSpacing: compact ? 2.4 : 3.2,
                    ),
          ),
        ),
        if (!compact && (amharic != null || arabic != null)) ...<Widget>[
          const SizedBox(height: 6),
          if (amharic != null && amharic!.trim().isNotEmpty)
            Text(
              amharic!,
              style: BrandTypography.bodyForLocale(
                const Locale('am'),
                base: BrandTypography.bodySmall,
              ).copyWith(color: heading.withValues(alpha: 0.82)),
            ),
          if (arabic != null && arabic!.trim().isNotEmpty)
            Text(
              arabic!,
              textDirection: TextDirection.rtl,
              style: BrandTypography.bodyForLocale(
                const Locale('ar'),
                base: BrandTypography.bodySmall,
              ).copyWith(color: BrandColors.gold.withValues(alpha: 0.9)),
            ),
        ],
      ],
    );
  }
}

/// Lockup used in the app bar and splash: badge + wordmark.
class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    required this.english,
    this.amharic,
    this.arabic,
    this.logoSize = 40,
    this.compact = true,
  });

  final String english;
  final String? amharic;
  final String? arabic;
  final double logoSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BrandLogo(size: logoSize),
        const SizedBox(width: 12),
        Flexible(
          child: BrandWordmark(
            english: english,
            amharic: amharic,
            arabic: arabic,
            compact: compact,
          ),
        ),
      ],
    );
  }
}
