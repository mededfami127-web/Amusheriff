import 'package:flutter/material.dart';

import '../errors/app_failure.dart';
import '../errors/error_localizer.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/brand_colors.dart';
import '../theme/typography.dart';
import 'empty_state.dart';
import 'gradient_button.dart';

/// Renders an [AppFailure] with a localized message and a retry affordance.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.failure,
    this.onRetry,
    this.compact = false,
  });

  final AppFailure failure;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return EmptyState(
      title: l10n.stateErrorTitle,
      message: localizeFailure(l10n, failure),
      icon: _iconFor(failure),
      compact: compact,
      action: onRetry != null && failure.isRetryable
          ? GradientButton(
              label: l10n.actionRetry,
              icon: Icons.refresh_rounded,
              expand: false,
              height: 48,
              onPressed: onRetry,
            )
          : null,
    );
  }

  IconData _iconFor(AppFailure failure) => switch (failure) {
        NetworkFailure() => Icons.wifi_off_rounded,
        TimeoutFailure() => Icons.hourglass_bottom_rounded,
        AuthFailure() => Icons.lock_outline_rounded,
        PermissionFailure() => Icons.gpp_maybe_outlined,
        NotFoundFailure() => Icons.search_off_rounded,
        ValidationFailure() => Icons.rule_folder_outlined,
        MediaFailure() || StorageFailure() => Icons.cloud_off_rounded,
        ServerFailure() => Icons.dns_outlined,
        UnknownFailure() => Icons.error_outline_rounded,
      };
}

/// Non-scrolling inline error banner, for use inside a form or sheet.
class InlineFailureBanner extends StatelessWidget {
  const InlineFailureBanner({super.key, required this.failure, this.onRetry});

  final AppFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: (dark ? BrandColors.gold : BrandColors.danger)
            .withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (dark ? BrandColors.gold : BrandColors.danger)
              .withValues(alpha: 0.45),
        ),
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
            TextButton(
              onPressed: onRetry,
              child: Text(l10n.actionRetry),
            ),
        ],
      ),
    );
  }
}
