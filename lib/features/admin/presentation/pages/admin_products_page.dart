import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/storage_urls.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/repositories/catalog_repositories.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_scaffold.dart';

/// The catalogue: search, category/status filters, and the row actions the
/// owner needs most (publish, feature, availability, delete).
class AdminProductsPage extends ConsumerStatefulWidget {
  const AdminProductsPage({super.key});

  @override
  ConsumerState<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends ConsumerState<AdminProductsPage> {
  final TextEditingController _search = TextEditingController();

  String _query = '';
  String? _categoryId;
  bool _onlyDrafts = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Product>> async = ref.watch(
      adminProductsProvider(categoryId: _categoryId),
    );
    final List<Category> categories =
        ref.watch(allCategoriesProvider).value ?? const <Category>[];

    return AdminScaffold(
      title: l10n.adminProducts,
      selectedRoute: Routes.adminProducts,
      floatingActionButton: FloatingActionButton(
        backgroundColor: BrandColors.royalViolet,
        foregroundColor: BrandColors.ivory,
        tooltip: l10n.adminAddProduct,
        onPressed: () => _openEditor(context, null),
        child: const Icon(Icons.add, size: 28),
      ),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorStateView(
          failure: ErrorMapper.map(error),
          onRetry: () => ref.invalidate(adminProductsProvider()),
        ),
        data: (List<Product> products) {
          final List<Product> rows = _applyFilters(products);
          if (products.isEmpty) {
            return EmptyState(
              title: l10n.adminProducts,
              message: l10n.adminNoProducts,
              icon: Icons.chair_outlined,
              action: FilledButton.icon(
                onPressed: () => _openEditor(context, null),
                icon: const Icon(Icons.add),
                label: Text(l10n.adminAddProduct),
              ),
            );
          }
          if (rows.isEmpty) {
            return EmptyState(
              title: l10n.adminProducts,
              message: l10n.adminNoProductsMatch,
              icon: Icons.search_off_rounded,
            );
          }
          // A builder list, not a Column of every row: the catalogue keeps
          // growing and only the visible tiles should be built.
          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _filters(l10n, categories),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 96),
                sliver: SliverList.builder(
                  itemCount: rows.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _ProductTile(
                        key: ValueKey<String>(rows[index].id),
                        product: rows[index],
                        onEdit: () => _openEditor(context, rows[index]),
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Product> _applyFilters(List<Product> products) {
    final String query = _query.trim().toLowerCase();
    return products
        .where((Product product) {
          if (_onlyDrafts && product.isPublished) return false;
          if (query.isEmpty) return true;
          // Every language is searched, so the owner can find a row by the
          // wording they typed on the form — whichever language that was.
          return product.title.toLowerCase().contains(query) ||
              (product.titleAm ?? '').toLowerCase().contains(query) ||
              (product.titleAr ?? '').toLowerCase().contains(query) ||
              (product.titleOm ?? '').toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  Widget _filters(AppLocalizations l10n, List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _search,
          onChanged: (String value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: l10n.adminSearchProducts,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          initialValue: _categoryId,
          // A long category name must ellipsize inside the field, not overflow
          // the dropdown's internal Row on a 320dp phone.
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.adminCategories),
          items: <DropdownMenuItem<String?>>[
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                l10n.adminFilterAllCategories,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            for (final Category category in categories)
              DropdownMenuItem<String?>(
                value: category.id,
                child: Text(
                  category.nameFor(
                    Localizations.localeOf(context).languageCode,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (String? value) => setState(() => _categoryId = value),
        ),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
          segments: <ButtonSegment<bool>>[
            ButtonSegment<bool>(
              value: false,
              label: Text(l10n.adminFilterAllStatus),
            ),
            ButtonSegment<bool>(
              value: true,
              label: Text(l10n.adminFilterDraft),
            ),
          ],
          selected: <bool>{_onlyDrafts},
          showSelectedIcon: false,
          onSelectionChanged: (Set<bool> selection) =>
              setState(() => _onlyDrafts = selection.first),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _openEditor(BuildContext context, Product? product) {
    ref.read(productEditorControllerProvider.notifier).load(product);
    context.go(
      product == null
          ? Routes.adminProductNew
          : Routes.adminProductEditor(product.id),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({super.key, required this.product, required this.onEdit});

  final Product product;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).languageCode;
    final String? cover = product.coverPath;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 52,
            height: 52,
            child: cover == null
                ? const ColoredBox(
                    color: BrandColors.deepPlum,
                    child: Icon(Icons.chair_outlined, color: BrandColors.gold),
                  )
                : CachedNetworkImage(
                    imageUrl: ref
                        .read(storageUrlsProvider)
                        .productMediaThumb(cover),
                    memCacheWidth: 104,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ColoredBox(color: BrandColors.deepPlum),
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: BrandColors.deepPlum,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: BrandColors.gold,
                      ),
                    ),
                  ),
          ),
        ),
        title: Text(
          product.titleFor(locale),
          style: BrandTypography.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                Formatters.money(
                  product.price,
                  currency: product.currencyCode,
                  locale: locale,
                ),
                style: BrandTypography.bodyMedium,
              ),
              if (!product.isPublished) _Badge(label: l10n.adminFilterDraft),
              if (product.isFeatured) _Badge(label: l10n.adminFeatured),
              if (!product.isAvailable) _Badge(label: l10n.labelUnavailable),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String action) => _run(context, ref, l10n, action),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(value: 'edit', child: Text(l10n.actionEdit)),
            PopupMenuItem<String>(
              value: 'publish',
              child: Text(
                product.isPublished ? l10n.adminUnpublish : l10n.adminPublish,
              ),
            ),
            PopupMenuItem<String>(
              value: 'feature',
              child: Text(l10n.adminFeatured),
            ),
            PopupMenuItem<String>(
              value: 'availability',
              child: Text(
                product.isAvailable
                    ? l10n.labelUnavailable
                    : l10n.labelAvailable,
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Text(l10n.actionDelete),
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String action,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ProductRepository repo = ref.read(productRepositoryProvider);

    try {
      switch (action) {
        case 'edit':
          onEdit();
          return;
        case 'publish':
          await repo.setPublished(
            product.id,
            isPublished: !product.isPublished,
          );
        case 'feature':
          await repo.setFeatured(product.id, isFeatured: !product.isFeatured);
        case 'availability':
          await repo.setAvailability(
            product.id,
            isAvailable: !product.isAvailable,
          );
        case 'delete':
          final bool confirmed = await _confirmDelete(context, l10n) ?? false;
          if (!confirmed) return;
          await repo.delete(product.id);
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.adminProductDeleted)),
          );
      }
      // Publish/feature/availability/delete all change what the storefront
      // grid and the per-category counts read, so refresh them here rather
      // than waiting for a restart.
      invalidateCatalogue(ref.invalidate, includeCategories: true);
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizeFailure(l10n, ErrorMapper.map(error)))),
      );
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.adminConfirmDeleteProduct),
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
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: BrandColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: BrandTypography.labelSmall),
    );
  }
}
