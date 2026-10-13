import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';
import '../theme/gradients.dart';
import '../theme/typography.dart';
import 'gold_divider.dart';

/// Centred, brand-styled empty state.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.chair_outlined,
    this.action,
    this.compact = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: compact ? 28 : 56),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: compact ? 68 : 88,
              height: compact ? 68 : 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: BrandGradients.brand,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: BrandColors.royalViolet.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, color: BrandColors.ivory, size: compact ? 30 : 38),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: BrandTypography.displayForLocale(
                Localizations.localeOf(context),
                base: BrandTypography.displaySmall,
              ).copyWith(
                color: dark ? BrandColors.goldLight : BrandColors.charcoal,
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(width: 90, child: GoldDivider(withOrnament: true)),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: BrandTypography.bodyMedium.copyWith(
                  color: BrandTypography.mutedOn(
                    Theme.of(context).brightness,
                  ),
                ),
              ),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: 26),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
