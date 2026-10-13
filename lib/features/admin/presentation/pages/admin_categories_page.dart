import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_scaffold.dart';
import 'admin_category_editor_sheet.dart';

/// Category list with drag-to-reorder, visibility toggles and delete.
class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Category>> async = ref.watch(allCategoriesProvider);

    return AdminScaffold(
      title: l10n.adminCategories,
      selectedRoute: Routes.adminCategories,
      floatingActionButton: FloatingActionButton(
        backgroundColor: BrandColors.royalViolet,
        foregroundColor: BrandColors.ivory,
        tooltip: l10n.adminCreateCategory,
        onPressed: () => _openSheet(context, ref, null),
        child: const Icon(Icons.add, size: 28),
      ),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorStateView(
          failure: ErrorMapper.map(error),
          onRetry: () => ref.invalidate(allCategoriesProvider),
        ),
        data: (List<Category> categories) {
          if (categories.isEmpty) {
            return EmptyState(
              title: l10n.adminCategories,
              message: l10n.adminNoCategories,
              icon: Icons.category_outlined,
              action: FilledButton.icon(
                onPressed: () => _openSheet(context, ref, null),
                icon: const Icon(Icons.add),
                label: Text(l10n.adminCreateCategory),
              ),
            );
          }
          return _CategoryList(
            categories: categories,
            onEditRequested: (Category category) =>
                _openSheet(context, ref, category),
          );
        },
      ),
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref, Category? existing) {
    ref.read(categoryEditorControllerProvider.notifier).load(existing);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CategoryEditorSheet(existing: existing),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList({
    required this.categories,
    required this.onEditRequested,
  });

  final List<Category> categories;
  final ValueChanged<Category> onEditRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      onReorderItem: (int oldIndex, int newIndex) {
        final List<Category> ordered = <Category>[...categories];
        final Category moved = ordered.removeAt(oldIndex);
        ordered.insert(newIndex, moved);
        ref
            .read(categoryRepositoryProvider)
            .reorder(ordered.map((Category c) => c.id).toList(growable: false));
      },
      children: <Widget>[
        for (final Category category in categories)
          _CategoryTile(
            key: ValueKey<String>(category.id),
            category: category,
            onEdit: () => onEditRequested(category),
          ),
      ],
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({
    super.key,
    required this.category,
    required this.onEdit,
  });

  final Category category;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).languageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: category.hasCover
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  category.coverPath!,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _CategoryAvatar(),
                ),
              )
            : const _CategoryAvatar(),
        title: Text(
          category.nameFor(locale),
          style: BrandTypography.titleMedium,
        ),
        subtitle: Text(
          '${category.slug} · ${category.productCount}',
          style: BrandTypography.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(
                category.isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              tooltip: category.isVisible ? l10n.adminHide : l10n.adminShow,
              onPressed: () => ref
                  .read(categoryRepositoryProvider)
                  .setVisibility(category.id, isVisible: !category.isVisible),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.actionEdit,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: l10n.actionDelete,
              onPressed: () => _confirmDelete(context, ref, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: Text(l10n.adminConfirmDeleteCategory),
            content: Text(
              category.productCount == 0
                  ? l10n.adminConfirmDeleteMessage
                  : l10n.adminCategoryHasProducts(category.productCount),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: BrandColors.danger,
                  foregroundColor: BrandColors.ivory,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.actionDelete),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(categoryRepositoryProvider).delete(category.id);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminCategoryDeleted)),
      );
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizeFailure(l10n, ErrorMapper.map(error)))),
      );
    }
  }
}

class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      backgroundColor: BrandColors.royalViolet,
      child: Icon(Icons.category_outlined, color: BrandColors.ivory),
    );
  }
}
