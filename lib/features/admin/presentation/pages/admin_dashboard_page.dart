import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../inquiries/domain/entities/inquiry.dart';
import '../../../inquiries/presentation/providers/inquiry_providers.dart';
import '../widgets/admin_scaffold.dart';

/// Gateway home: the numbers the owner checks first, plus shortcuts into the
/// catalogue.
///
/// Every figure is derived from a stream the gateway is already subscribed to,
/// so the dashboard costs no extra round trips and updates live.
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final AsyncValue<List<Category>> categories =
        ref.watch(allCategoriesProvider);
    final AsyncValue<List<Product>> products =
        ref.watch(adminProductsProvider());
    final AsyncValue<List<Inquiry>> inquiries = ref.watch(adminInquiriesProvider);
    final int inquiriesThisWeek = ref.watch(inquiriesThisWeekProvider);
    final List<MapEntry<String, int>> mostContacted =
        ref.watch(mostContactedProductsProvider);

    return AdminScaffold(
      title: l10n.adminDashboard,
      selectedRoute: Routes.adminRoot,
      floatingActionButton: FloatingActionButton(
        backgroundColor: BrandColors.royalViolet,
        foregroundColor: BrandColors.ivory,
        tooltip: l10n.adminAddProduct,
        onPressed: () => context.go(Routes.adminProducts),
        child: const Icon(Icons.add, size: 28),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: <Widget>[
          Text(
            l10n.adminDashboard,
            style: BrandTypography.displayMedium,
          ),
          const SizedBox(height: 6),
          Text(l10n.adminSortOrderHint, style: BrandTypography.bodySmall),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatsCard(
                  label: l10n.adminStatsCategories,
                  icon: Icons.category_outlined,
                  value: categories.value?.length,
                  loading: categories.isLoading,
                  error: categories.hasError,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatsCard(
                  label: l10n.adminStatsProducts,
                  icon: Icons.chair_outlined,
                  value: products.value?.length,
                  loading: products.isLoading,
                  error: products.hasError,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatsCard(
                  label: l10n.adminInquiriesWeek,
                  icon: Icons.insights_outlined,
                  value: inquiriesThisWeek,
                  loading: inquiries.isLoading,
                  error: inquiries.hasError,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatsCard(
                  label: l10n.adminMostContacted,
                  icon: Icons.favorite_outline_rounded,
                  value: mostContacted.length,
                  loading: inquiries.isLoading,
                  error: inquiries.hasError,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _SectionHeader(title: l10n.adminQuickActions),
          const SizedBox(height: 10),
          _QuickAction(
            label: l10n.adminProducts,
            icon: Icons.chair_outlined,
            route: Routes.adminProducts,
          ),
          _QuickAction(
            label: l10n.adminCategories,
            icon: Icons.category_outlined,
            route: Routes.adminCategories,
          ),
          _QuickAction(
            label: l10n.adminContacts,
            icon: Icons.share_outlined,
            route: Routes.adminContacts,
          ),
          _QuickAction(
            label: l10n.adminInquiries,
            icon: Icons.insights_outlined,
            route: Routes.adminInquiries,
          ),
          _QuickAction(
            label: l10n.adminSiteSettings,
            icon: Icons.tune_outlined,
            route: Routes.adminSiteSettings,
          ),
          const SizedBox(height: 26),
          _SectionHeader(title: l10n.adminMostContacted),
          const SizedBox(height: 6),
          if (mostContacted.isEmpty)
            Text(l10n.adminNoInquiriesYet, style: BrandTypography.bodySmall)
          else
            for (final MapEntry<String, int> entry in mostContacted)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(
                  Icons.local_fire_department_outlined,
                  color: BrandColors.gold,
                  size: 20,
                ),
                title: Text(entry.key, style: BrandTypography.bodyMedium),
                trailing: Text(
                  entry.value.toString(),
                  style: BrandTypography.labelLarge,
                ),
              ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.loading,
    required this.error,
  });

  final String label;
  final IconData icon;
  final int? value;
  final bool loading;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String display = error
        ? '—'
        : loading && value == null
            ? '…'
            : (value ?? 0).toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? BrandColors.deepPlum : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: BrandColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: BrandTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            display,
            style: BrandTypography.displayWeighted(700, size: 30),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: BrandGradients.goldHorizontal.createShader,
      blendMode: BlendMode.srcIn,
      child: Text(
        title,
        style: BrandTypography.displaySmall.copyWith(
          fontSize: 18,
          color: BrandColors.gold,
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: BrandColors.gold),
        title: Text(label, style: BrandTypography.bodyLarge),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: dark ? BrandColors.goldLight : BrandColors.charcoal,
        ),
        onTap: () => context.go(route),
      ),
    );
  }
}
