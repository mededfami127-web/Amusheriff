import 'package:flutter/material.dart';

import '../errors/app_failure.dart';
import '../errors/error_localizer.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/brand_colors.dart';
import '../theme/typography.dart';

/// Inline banner that surfaces a typed failure next to the form that produced it.
///
/// Retryable failures get a retry affordance; passing [onDismiss] adds a close
/// button for forms that own the failure state themselves.
class InlineFailureBanner extends StatelessWidget {
  const InlineFailureBanner({
    super.key,
    required this.failure,
    this.onRetry,
    this.onDismiss,
  });

  final AppFailure failure;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = dark ? BrandColors.gold : BrandColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: dark ? BrandColors.goldLight : BrandColors.danger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              localizeFailure(l10n, failure),
              style: BrandTypography.bodySmall.copyWith(
                color: dark ? BrandColors.goldLight : BrandColors.danger,
              ),
            ),
          ),
          if (onRetry != null && failure.isRetryable)
            TextButton(onPressed: onRetry, child: Text(l10n.actionRetry)),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              tooltip: l10n.actionCancel,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}
