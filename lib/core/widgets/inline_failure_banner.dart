import 'package:flutter/material.dart';

import '../errors/app_failure.dart';
import '../errors/error_localizer.dart';
import '../errors/error_mapper.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/brand_colors.dart';
import '../theme/typography.dart';

/// Inline banner that surfaces a typed failure next to the form that produced it.
///
/// Retryable failures get a retry affordance; passing [onDismiss] adds a close
/// button for forms that own the failure state themselves.
///
/// [showDetails] is for the admin surfaces: a refused Save used to show only
/// "The service is temporarily unavailable", which tells the owner nothing
/// about *which* column, policy or constraint refused it. With it set, the
/// original Supabase answer (`PGRST204: Could not find the 'title_om' column …`)
/// is printed on a second line under the friendly sentence. Storefront
/// surfaces leave it off, so a shopper never reads a SQLSTATE.
class InlineFailureBanner extends StatelessWidget {
  const InlineFailureBanner({
    super.key,
    required this.failure,
    this.onRetry,
    this.onDismiss,
    this.showDetails = false,
  });

  final AppFailure failure;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showDetails;

  /// The backend's own words for this failure, or `null` when it has none.
  String? get _detail => technicalDetailFor(failure);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = dark ? BrandColors.gold : BrandColors.danger;
    final String? detail = showDetails ? _detail : null;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  localizeFailure(l10n, failure),
                  style: BrandTypography.bodySmall.copyWith(
                    color: dark ? BrandColors.goldLight : BrandColors.danger,
                  ),
                ),
                if (detail != null) ...<Widget>[
                  const SizedBox(height: 4),
                  SelectableText(
                    '${l10n.errorDetailsLabel}: $detail',
                    style: BrandTypography.labelSmall.copyWith(
                      color: (dark ? BrandColors.goldLight : BrandColors.danger)
                          .withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ],
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
