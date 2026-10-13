import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../widgets/admin_scaffold.dart';
import 'admin_category_editor_sheet.dart';

/// Category manager: reorder by drag, create, edit, hide and delete.
///
/// Deleting is blocked while the category still holds products — the dialog
/// offers to move them instead, so a product can never be stranded.
class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Category>> async = ref.watch(allCategoriesProvider);
    final AsyncValue<Map<String, int>> counts =
        ref.watch(categoryProductCountsProvider);

    late final Widget body;
    body = async.when<Widget>(
      loading: () => const _CategorySkeleton(),
      error: (Object error, StackTrace __) => ErrorStateView(
        failure: ErrorMapper.map(error),
        onRetry: () => ref.invalidate(allCategoriesProvider),
      ),
      data: (List<Category> categories) {
        if (categories.isEmpty) {
          return EmptyState(
            title: l10n.adminNoCategories,
            message: l10n.adminCreateCategory,
            icon: Icons.category_outlined,
            action: GradientButton(
              label: l10n.adminCreateCategory,
              icon: Icons.add_rounded,
              expand: false,
              height: 48,
              onPressed: () => showCategoryEditorSheet(context),
            ),
          );
        }
        return _ReorderableCategoryList(
          categories: categories,
          counts: counts.value ?? const <String, int>{},
        );
      },
    );

    return AdminScaffold(
      title: l10n.adminCategories,
      selectedRoute: Routes.adminCategories,
      floatingActionButton: categoriesAreEmpty(async)
          ? null
          : FloatingActionButton.extended(
              backgroundColor: BrandColors.royalViolet,
              foregroundColor: BrandColors.ivory,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.adminCreateCategory),
              onPressed: () => showCategoryEditorSheet(context),
            ),
      child: body,
    );
  }

  bool categoriesAreEmpty(AsyncValue<List<Category>> value) =>
      value.value?.isEmpty ?? false;
}

class _ReorderableCategoryList extends ConsumerWidget {
  const _ReorderableCategoryList({
    required this.categories,
    required this.counts,
  });

  final List<Category> categories;
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      buildDefaultDragHandles: true,
      itemCount: categories.length,
      onReorderItem: (int oldIndex, int newIndex) async {
        // `onReorderItem` has already adjusted for the removal.
        final List<Category> moved = List<Category>.from(categories);
        final Category item = moved.removeAt(oldIndex);
        moved.insert(newIndex, item);
        await ref
            .read(categoryRepositoryProvider)
            .reorder(moved.map((Category c) => c.id).toList(growable: false));
      },
      itemBuilder: (BuildContext context, int index) {
        final Category category = categories[index];
        return _CategoryTile(
          key: ValueKey<String>(category.id),
          index: index,
          category: category,
          productCount: counts[category.id] ?? 0,
          dragLabel: l10n.adminDragToReorder,
        );
      },
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({
    super.key,
    required this.index,
    required this.category,
    required this.productCount,
    required this.dragLabel,
  });

  final int index;
  final Category category;
  final int productCount;
  final String dragLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: dark ? BrandColors.plumSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Row(
        children: <Widget>[
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: BrandTypography.mutedOn(Theme.of(context).brightness),
                semanticLabel: dragLabel,
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(category.name, style: BrandTypography.titleMedium),
              subtitle: Text(
                '${category.slug} · $productCount',
                style: BrandTypography.bodySmall.copyWith(
                  color: BrandTypography.mutedOn(
                    Theme.of(context).brightness,
                  ),
                ),
              ),
              onTap: () => showCategoryEditorSheet(context, category: category),
            ),
          ),
          IconButton(
            tooltip: category.isVisible ? l10n.adminHide : l10n.adminShow,
            icon: Icon(
              category.isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: category.isVisible ? BrandColors.gold : BrandColors.danger,
            ),
            onPressed: () async {
              await ref.read(categoryRepositoryProvider).setVisibility(
                    category.id,
                    isVisible: !category.isVisible,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.adminCategoryHidden)),
                );
              }
            },
          ),
          IconButton(
            tooltip: l10n.actionEdit,
            icon: const Icon(Icons.edit_outlined, color: BrandColors.gold),
            onPressed: () => showCategoryEditorSheet(context, category: category),
          ),
          IconButton(
            tooltip: l10n.actionDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: BrandColors.danger),
            onPressed: () => confirmCategoryDeletion(
              context,
              ref,
              category: category,
              productCount: productCount,
            ),
          ),
        ],
      ),
    );
  }


}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) => Container(
        height: 72,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: (dark ? BrandColors.plumSurface : Colors.grey.shade200)
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
