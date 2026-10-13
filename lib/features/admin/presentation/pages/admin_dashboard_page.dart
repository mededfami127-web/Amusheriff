import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/gold_divider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../contacts/presentation/providers/contact_providers.dart';

/// The owner's home: live counts, the section list and sign-out.
///
/// Reaching this widget already means the guard confirmed `is_admin = true`;
/// the provider watch here just avoids rendering stale counts.
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final AsyncValue<bool> adminStatus = ref.watch(adminStatusProvider);

    if (adminStatus.isLoading) {
      return const AppScaffold(
        showLockup: false,
        title: '',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final int categoryCount =
        ref.watch(allCategoriesProvider).value?.length ?? 0;
    final int productCount = ref.watch(adminProductsProvider()).value?.length ?? 0;
    final int contactCount =
        ref.watch(allContactLinksProvider).value?.length ?? 0;
    final String email =
        ref.watch(currentUserProvider)?.email ?? '—';

    return AppScaffold(
      showLockup: false,
      title: l10n.adminDashboard,
      actions: <Widget>[
        IconButton(
          tooltip: l10n.adminSignOut,
          icon: const Icon(Icons.logout_rounded),
          onPressed: () async {
            await ref.read(adminAuthControllerProvider.notifier).signOut();
            if (context.mounted) context.go(Routes.storefront);
          },
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: BrandGradients.brand,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.adminDashboard,
                  style: BrandTypography.brandTitle.copyWith(
                    fontSize: 24,
                    color: BrandColors.ivory,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: BrandTypography.bodySmall.copyWith(
                    color: BrandColors.ivory.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatTile(
                  label: l10n.adminCategories,
                  value: '$categoryCount',
                  icon: Icons.category_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: l10n.adminProducts,
                  value: '$productCount',
                  icon: Icons.chair_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: l10n.adminContacts,
                  value: '$contactCount',
                  icon: Icons.share_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const GoldDivider(withOrnament: true),
          const SizedBox(height: 18),
          _NavTile(
            label: l10n.adminCategories,
            icon: Icons.category_outlined,
            route: Routes.adminCategories,
          ),
          _NavTile(
            label: l10n.adminProducts,
            icon: Icons.chair_outlined,
            route: Routes.adminProducts,
          ),
          _NavTile(
            label: l10n.adminContacts,
            icon: Icons.share_outlined,
            route: Routes.adminContacts,
          ),
          _NavTile(
            label: l10n.adminSiteSettings,
            icon: Icons.tune_outlined,
            route: Routes.adminSiteSettings,
          ),
          _NavTile(
            label: l10n.adminInquiries,
            icon: Icons.insights_outlined,
            route: Routes.adminInquiries,
          ),
          _NavTile(
            label: l10n.adminChangePassword,
            icon: Icons.password_rounded,
            route: Routes.adminChangePassword,
          ),
          const SizedBox(height: 22),
          Text(
            dark ? 'Dark surface active' : 'Light surface active',
            textAlign: TextAlign.center,
            style: BrandTypography.bodySmall.copyWith(
              color: BrandTypography.mutedOn(Theme.of(context).brightness),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: dark ? BrandColors.plumSurface : Colors.white,
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 19, color: BrandColors.gold),
          const SizedBox(height: 10),
          Text(
            value,
            style: BrandTypography.displayWeighted(700, size: 24).copyWith(
              color: dark ? BrandColors.goldLight : BrandColors.charcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BrandTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: dark ? BrandColors.plumSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 20, color: BrandColors.gold),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label, style: BrandTypography.titleMedium),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: BrandTypography.mutedOn(
                    Theme.of(context).brightness,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
