import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';
import '../theme/gradients.dart';
import '../theme/typography.dart';

/// Primary call-to-action: purple→magenta gradient pill with optional gold
/// hairline, leading icon and inline loading spinner.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.height = 54,
    this.gradient = BrandGradients.brand,
    this.foreground = BrandColors.ivory,
    this.goldBorder = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final double height;
  final Gradient gradient;
  final Color foreground;
  final bool goldBorder;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    final Widget content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? SizedBox(
              key: const ValueKey<String>('loading'),
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(foreground),
              ),
            )
          : Row(
              key: const ValueKey<String>('label'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 19, color: foreground),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: BrandTypography.labelLarge.copyWith(
                      color: foreground,
                      fontSize: 15.5,
                    ),
                  ),
                ),
              ],
            ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        width: expand ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          border: goldBorder
              ? Border.all(color: BrandColors.gold.withValues(alpha: 0.55))
              : null,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: BrandColors.royalViolet.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(14),
            splashColor: Colors.white.withValues(alpha: 0.14),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
