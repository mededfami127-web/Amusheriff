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
      errorBuilder: (_, __, ___) => _FallbackBadge(size: size),
    );
  }
}

class _FallbackBadge extends StatelessWidget {
  const _FallbackBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: BrandGradients.brand,
      ),
      child: Icon(
        Icons.account_circle_outlined,
        size: size * 0.7,
        color: BrandColors.ivory,
      ),
    );
  }
}

/// The brand name in the active locale, set in the gold display face with the
/// Amharic and Arabic lines rendered in their own scripts.
///
/// Text only. No image or asset path depends on locale.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    required this.english,
    this.secondary,
    this.amharic,
    this.arabic,
    this.alignment = CrossAxisAlignment.start,
    this.compact = false,
  });

  /// First line of the name, set large — "Amusheriff".
  final String english;

  /// The rest of the name, set smaller underneath when the full name is too
  /// long for one line — "Arabiyan Mejlis and Furniture".
  final String? secondary;
  final String? amharic;
  final String? arabic;
  final CrossAxisAlignment alignment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color heading = dark ? BrandColors.goldLight : BrandColors.charcoal;
    final TextAlign textAlign = alignment == CrossAxisAlignment.center
        ? TextAlign.center
        : TextAlign.start;
    final String? under = secondary?.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: <Widget>[
        ShaderMask(
          shaderCallback: BrandGradients.goldHorizontal.createShader,
          blendMode: BlendMode.srcIn,
          child: Text(
            english,
            textAlign: textAlign,
            style:
                (compact
                        ? BrandTypography.displayWeighted(700, size: 17)
                        : BrandTypography.brandTitle)
                    .copyWith(
                      color: BrandColors.gold,
                      letterSpacing: compact ? 1.0 : 2.4,
                    ),
          ),
        ),
        // Second line of the shop name. Never ellipsised: the app bar shows
        // the whole name, so it stays legible on a narrow phone.
        if (under != null && under.isNotEmpty)
          Text(
            under,
            textAlign: textAlign,
            softWrap: true,
            style: BrandTypography.bodySmall.copyWith(
              color: heading.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
              fontSize: compact ? 10.5 : 12,
              height: 1.15,
              letterSpacing: 0.2,
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
    this.secondary,
    this.amharic,
    this.arabic,
    this.logoSize = 40,
    this.compact = true,
  });

  final String english;
  final String? secondary;
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
            secondary: secondary,
            amharic: amharic,
            arabic: arabic,
            compact: compact,
          ),
        ),
      ],
    );
  }
}
