import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/error_localizer.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/storage_urls.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/stream_utils.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../catalog/domain/drafts/catalog_drafts.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/repositories/catalog_repositories.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_scaffold.dart';
import 'admin_category_editor_sheet.dart';

/// Category list with drag-to-reorder, visibility toggles and delete.
///
/// Subcategories live inside their mother category's row: only top-level
/// categories are draggable, so the ordering RPC keeps receiving top-level ids,
/// and every subcategory is created and edited from the tile it belongs to.
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
            onAddSubcategoryRequested: (Category parent) =>
                _openSheet(context, ref, null, parent: parent),
          );
        },
      ),
    );
  }

  /// Opens the editor and reports what happened once it closes.
  ///
  /// The sheet pops `true` only when the row was written, so the confirmation
  /// message describes the real outcome instead of the sheet's intention. The
  /// draft is seeded here because the sheet, which cannot write a provider
  /// while it is being built, is always built one frame later.
  Future<void> _openSheet(
    BuildContext context,
    WidgetRef ref,
    Category? existing, {
    Category? parent,
  }) async {
    ref
        .read(categoryEditorControllerProvider.notifier)
        .load(existing, parentId: parent?.id);

    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CategoryEditorSheet(existing: existing, parent: parent),
    );

    if (saved != true || !context.mounted) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null
              ? l10n.adminCategoryCreated
              : l10n.adminCategoryUpdated,
        ),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList({
    required this.categories,
    required this.onEditRequested,
    required this.onAddSubcategoryRequested,
  });

  final List<Category> categories;
  final ValueChanged<Category> onEditRequested;
  final ValueChanged<Category> onAddSubcategoryRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Category> roots = categories
        .where((Category category) => category.parentId == null)
        .toList(growable: false);
    final Map<String, List<Category>> children = groupBy(
      categories.where((Category category) => category.parentId != null),
      (Category category) => category.parentId!,
    );
    for (final List<Category> siblings in children.values) {
      siblings.sort(_byOrderThenName);
    }
    // Every product, drafts included: the delete prompt must know about the
    // unpublished ones too, which the published-only count on the row misses.
    final List<Product> products =
        ref.watch(adminProductsProvider()).value ?? const <Product>[];
    List<Product> productsIn(String categoryId) => products
        .where((Product p) => p.categoryId == categoryId)
        .toList(growable: false);

    return ReorderableListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      onReorderItem: (int oldIndex, int newIndex) {
        final List<Category> ordered = <Category>[...roots];
        final Category moved = ordered.removeAt(oldIndex);
        ordered.insert(newIndex, moved);
        ref
            .read(categoryRepositoryProvider)
            .reorder(ordered.map((Category c) => c.id).toList(growable: false));
      },
      children: <Widget>[
        for (final Category root in roots)
          Column(
            key: ValueKey<String>(root.id),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _CategoryTile(
                category: root,
                subcategories: children[root.id] ?? const <Category>[],
                products: productsIn(root.id),
                moveTargets: roots
                    .where((Category other) => other.id != root.id)
                    .toList(growable: false),
                onEdit: () => onEditRequested(root),
                onAddSubcategory: () => onAddSubcategoryRequested(root),
              ),
              for (final Category child
                  in children[root.id] ?? const <Category>[])
                _CategoryTile(
                  key: ValueKey<String>(child.id),
                  category: child,
                  isSubcategory: true,
                  products: productsIn(child.id),
                  moveTargets: roots
                      .where((Category other) => other.id != root.id)
                      .toList(growable: false),
                  onEdit: () => onEditRequested(child),
                ),
            ],
          ),
      ],
    );
  }

  /// Subcategories keep the order the owner set, then fall back to the name so
  /// two rows that both sit at 0 are still stable and readable.
  static int _byOrderThenName(Category a, Category b) {
    final int byOrder = a.sortOrder.compareTo(b.sortOrder);
    if (byOrder != 0) return byOrder;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({
    super.key,
    required this.category,
    required this.onEdit,
    this.isSubcategory = false,
    this.subcategories = const <Category>[],
    this.products = const <Product>[],
    this.moveTargets = const <Category>[],
    this.onAddSubcategory,
  });

  final Category category;
  final VoidCallback onEdit;

  /// True when [category] sits inside its mother's row.
  final bool isSubcategory;

  /// Subcategories directly under [category]; used by the delete prompt, which
  /// offers to move them under another root instead of refusing the delete.
  final List<Category> subcategories;

  /// Products filed here, published or not. `on delete restrict` refuses the
  /// write while any exist, so the prompt has to count the drafts too — and
  /// offers to move them in one go.
  final List<Product> products;

  /// Roots a delete could move the rows to. Empty when this is the only root.
  final List<Category> moveTargets;
  final VoidCallback? onAddSubcategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: EdgeInsets.only(
        left: isSubcategory ? 22 : 0,
        bottom: isSubcategory ? 6 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            margin: EdgeInsets.only(bottom: isSubcategory ? 4 : 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: category.hasCover
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      // `cover_path` is a path inside the public `brand` bucket,
                      // not a packaged asset: `Image.asset` could never decode
                      // it, so an uploaded cover was invisible here.
                      child: CachedNetworkImage(
                        imageUrl: ref
                            .read(storageUrlsProvider)
                            .categoryCover(category.coverPath!),
                        width: isSubcategory ? 36 : 44,
                        height: isSubcategory ? 36 : 44,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const _CategoryAvatar(),
                        errorWidget: (_, __, ___) => const _CategoryAvatar(),
                      ),
                    )
                  : const _CategoryAvatar(),
              title: Row(
                children: <Widget>[
                  if (isSubcategory) ...<Widget>[
                    const Icon(
                      Icons.subdirectory_arrow_right_rounded,
                      size: 16,
                      color: BrandColors.gold,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      category.nameFor(locale),
                      style: BrandTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
                    tooltip: category.isVisible
                        ? l10n.adminHide
                        : l10n.adminShow,
                    onPressed: () => ref
                        .read(categoryRepositoryProvider)
                        .setVisibility(
                          category.id,
                          isVisible: !category.isVisible,
                        ),
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
          ),
          if (onAddSubcategory case final VoidCallback addSubcategory)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: addSubcategory,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.adminCategoryAddSubcategory),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    // `on delete restrict` refuses a category that still has children or
    // products. Explain that in the owner's language, and offer the way out —
    // move the rows under another root, then delete — instead of a Delete
    // button that can only fail with a raw Postgres error.
    final bool blocked = subcategories.isNotEmpty || products.isNotEmpty;

    String? target;
    if (blocked) {
      target = await _askMove(context, ref, l10n);
      if (target == null || !context.mounted) return;
    } else {
      final bool confirmed =
          await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) => AlertDialog(
              title: Text(l10n.adminConfirmDeleteCategory),
              content: Text(l10n.adminConfirmDeleteMessage),
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
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      if (target != null) {
        await _moveRows(ref, target);
      }
      await ref.read(categoryRepositoryProvider).delete(category.id);
      invalidateCatalogue(ref.invalidate, includeCategories: true);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminCategoryDeleted)),
      );
    } on Object catch (error) {
      final AppFailure failure = ErrorMapper.map(error);
      // Another device may have filed a product here between the tap and the
      // write; the restrict violation then still names the real blocker.
      final String message =
          failure is ValidationFailure &&
              failure.messageKey == 'errorForeignKey'
          ? l10n.adminCategoryHasProducts(products.length.clamp(1, 999))
          : localizeFailure(l10n, failure);
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Asks which root should receive this category's children/products.
  ///
  /// Returns the chosen id, or `null` when the owner cancelled. With no other
  /// root to move to, the dialog merely explains the block.
  Future<String?> _askMove(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final String message = subcategories.isNotEmpty
        ? l10n.adminCategoryHasSubcategories
        : l10n.adminCategoryHasProducts(products.length);

    if (moveTargets.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: Text(l10n.adminConfirmDeleteCategory),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionClose),
            ),
          ],
        ),
      );
      return null;
    }

    final String locale = Localizations.localeOf(context).languageCode;
    String selected = moveTargets.first.id;

    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => AlertDialog(
          title: Text(l10n.adminConfirmDeleteCategory),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(message),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selected,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.adminCategoryParent,
                ),
                items: <DropdownMenuItem<String>>[
                  for (final Category target in moveTargets)
                    DropdownMenuItem<String>(
                      value: target.id,
                      child: Text(
                        target.nameFor(locale),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (String? value) {
                  if (value != null) setState(() => selected = value);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(selected),
              child: Text(l10n.adminCategoryMove),
            ),
          ],
        ),
      ),
    );
  }

  /// Re-files every child and product under [targetId] before the delete.
  ///
  /// One row at a time: a partial move is visible and retryable, while a
  /// half-applied bulk write would hide which rows still block the delete.
  Future<void> _moveRows(WidgetRef ref, String targetId) async {
    final CategoryRepository categories = ref.read(categoryRepositoryProvider);
    final ProductRepository productsRepo = ref.read(productRepositoryProvider);

    for (final Category child in subcategories) {
      await categories.update(
        child.id,
        CategoryDraft(
          name: child.name,
          slug: child.slug,
          nameAm: child.nameAm,
          nameAr: child.nameAr,
          nameOm: child.nameOm,
          coverPath: child.coverPath,
          parentId: targetId,
          sortOrder: child.sortOrder,
          isVisible: child.isVisible,
        ),
      );
    }

    for (final Product product in products) {
      await productsRepo.update(
        product.id,
        ProductDraft(
          categoryId: targetId,
          title: product.title,
          titleAm: product.titleAm,
          titleAr: product.titleAr,
          titleOm: product.titleOm,
          description: product.description,
          descriptionAm: product.descriptionAm,
          descriptionAr: product.descriptionAr,
          descriptionOm: product.descriptionOm,
          price: product.price,
          compareAtPrice: product.compareAtPrice,
          currencyCode: product.currencyCode,
          isAvailable: product.isAvailable,
          isFeatured: product.isFeatured,
          isPublished: product.isPublished,
          sortOrder: product.sortOrder,
        ),
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
