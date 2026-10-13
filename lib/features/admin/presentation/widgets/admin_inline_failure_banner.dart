import 'package:flutter/material.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/error_localizer.dart';
import '../../../../core/theme/brand_colors.dart';

class InlineFailureBanner extends StatelessWidget {
  const InlineFailureBanner({
    super.key,
    required this.failure,
    this.onDismiss,
  });

  final AppFailure failure;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String message = failure.localizedMessage(l10n);
    final bool blocking = failure.isBlocking;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: blocking
            ? BrandColors.error.withValues(alpha: 0.10)
            : BrandColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: blocking
              ? BrandColors.error.withValues(alpha: 0.5)
              : BrandColors.gold.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            blocking ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            size: 18,
            color: blocking ? BrandColors.error : BrandColors.goldLight,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: BrandTypography.bodySmall.copyWith(
                color: blocking ? BrandColors.error : BrandColors.charcoal,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}
