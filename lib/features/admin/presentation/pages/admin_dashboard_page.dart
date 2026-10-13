import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_scaffold.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final AsyncValue<int> categories =
        ref.watch(adminCategoriesCountProvider);
    final AsyncValue<int> products =
        ref.watch(adminProductsCountProvider);
    final AsyncValue<int> inquiries =
        ref.watch(adminInquiriesWeekProvider);
    final AsyncValue<List<MapEntry<String, int>>> mostContacted =
        ref.watch(mostContactedProductsProvider);

    return AdminScaffold(
      title: l10n.adminDashboard,
      selectedRoute: Routes.adminRoot,
      floatingActionButton: FloatingActionButton(
        backgroundColor: BrandColors.royalViolet,
        foregroundColor: BrandColors.ivory,
        child: const Icon(Icons.add, size: 28),
        onPressed: () =>
            Navigator.of(context).pushNamed(Routes.adminProducts),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.adminDashboardTitle, style: BrandTypography.displayMedium),
            const SizedBox(height: 24),
            _StatsCard(
              label: l10n.adminStatsCategories,
              value: categories.value ?? 0,
              loading: categories.isLoading,
              error: categories.hasError,
            ),
            const SizedBox(height: 14),
            _StatsCard(
              label: l10n.adminStatsProducts,
              value: products.value ?? 0,
              loading: products.isLoading,
              error: products.hasError,
            ),
            const SizedBox(height: 14),
            _StatsCard(
              label: l10n.adminInquiriesWeek,
              value: inquiries.value ?? 0,
              loading: inquiries.isLoading,
              error: inquiries.hasError,
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.adminMostContacted),
            if (mostContacted.isLoading)
              const _LoadingIndicator()
            else if (mostContacted.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  mostContacted.error.toString(),
                  style: BrandTypography.bodySmall,
                ),
              )
            else if (mostContacted.value == null ||
                mostContacted.value!.isEmpty)
              Text(l10n.adminNoInquiriesYet,
                  style: BrandTypography.bodySmall)
            else
              _MostContactedList(
                  entries: mostContacted.value!),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.label,
    required this.value,
    required this.loading,
    required this.error,
  });

  final String label;
  final int value;
  final bool loading;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: BrandTypography.bodySmall),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: BrandTypography.displayWeighted(700, size: 36),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: BrandTypography.displaySmall.copyWith(
          color: BrandColors.goldLight,
        ),
      ),
    );
  }
}

class _MostContactedList extends StatelessWidget {
  const _MostContactedList({required this.entries});

  final List<MapEntry<String, int>> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
     shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          title: Text(entry.key),
          trailing: Text(entry.value.toString()),
        );
      },
    );
  }
}
