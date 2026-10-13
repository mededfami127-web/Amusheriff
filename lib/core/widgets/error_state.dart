import 'package:flutter/material.dart';

import '../errors/app_failure.dart';
import '../errors/error_localizer.dart';
import '../l10n/generated/app_localizations.dart';
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
