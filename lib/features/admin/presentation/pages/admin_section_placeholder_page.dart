import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';

/// A wired route whose editor UI lands in Part 2.
///
/// The route, the guard and the repository behind it already exist, so Part 2
/// only has to replace this widget — no routing or data work is left over.
class AdminSectionPlaceholderPage extends ConsumerWidget {
  const AdminSectionPlaceholderPage({
    super.key,
    required this.titleKey,
    required this.icon,
    this.plannedFor = 'Part 2',
    this.detail,
  });

  final String titleKey;
  final IconData icon;
  final String plannedFor;
  final String? detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String title = switch (titleKey) {
      'adminCategories' => l10n.adminCategories,
      'adminProducts' => l10n.adminProducts,
      'adminMedia' => l10n.adminMedia,
      'adminContacts' => l10n.adminContacts,
      'adminSiteSettings' => l10n.adminSiteSettings,
      'adminInquiries' => l10n.adminInquiries,
      _ => l10n.adminDashboard,
    };

    return AppScaffold(
      showLockup: false,
      title: title,
      body: EmptyState(
        title: title,
        message: detail == null
            ? '$title — $plannedFor'
            : '$title · $detail — $plannedFor',
        icon: icon,
        action: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Route guarded · repository wired · RLS enforced',
            textAlign: TextAlign.center,
            style: BrandTypography.bodySmall.copyWith(
              color: BrandColors.gold,
            ),
          ),
        ),
      ),
    );
  }
}
