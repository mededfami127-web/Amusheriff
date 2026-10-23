import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/gold_divider.dart';
import '../../../../core/widgets/shimmer_card.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/storefront_providers.dart';
import '../widgets/product_card.dart';

/// One category's products, keyed by slug so the URL is shareable.
///
/// A top-level category shows its children as small text chips right under the
/// heading — "All <mother>" first, then each subcategory's name. A subcategory
/// page shows the mother > child breadcrumb instead and only its own products.
class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String language = Localizations.localeOf(context).languageCode;

    final AsyncValue<Category?> category = ref.watch(
      categoryBySlugProvider(slug),
    );
    final int limit = ref.watch(visibleCountProvider('category-$slug'));

    final Category? value = category.value;
    final String? categoryId = value?.id;
    final String? motherId = value?.parentId;

    // Kicked off in the page so the chip row is a plain watch: the family is
    // only asked for a mother that actually exists.
    final AsyncValue<Category?> mother = motherId == null
        ? const AsyncValue<Category?>.data(null)
        : ref.watch(categoryByIdProvider(motherId));

    // A root's children, straight from their own query. A subcategory has no
    // children (the tree is one level deep), so the row is simply absent.
    final AsyncValue<List<Category>> children = categoryId == null
        ? const AsyncValue<List<Category>>.data(<Category>[])
        : motherId != null
        ? const AsyncValue<List<Category>>.data(<Category>[])
        : ref.watch(childCategoriesProvider(categoryId));

    final List<Category> subcategories = children.value ?? const <Category>[];

    // "All <mother>" takes the mother's own products plus every child's; a
    // subcategory page narrows to itself. One live list, filtered in memory,
    // so a newly published product appears without leaving the page.
    final AsyncValue<List<Product>> products = categoryId == null
        ? const AsyncValue<List<Product>>.loading()
        : ref
              .watch(storefrontProductsProvider())
              .whenData(
                (List<Product> items) => items
                    .where(
                      (Product p) =>
                          p.categoryId == categoryId ||
                          subcategories.any(
                            (Category child) => child.id == p.categoryId,
                          ),
                    )
                    .toList(growable: false),
              );

    return AppScaffold(
      showLockup: false,
      title: value?.nameFor(language) ?? l10n.stateLoading,
      body: switch (category) {
        AsyncLoading() => const ShimmerGrid(),
        AsyncError(:final Object error) => ErrorStateView(
          failure: error is AppFailure ? error : UnknownFailure(cause: error),
          onRetry: () => ref.invalidate(categoryBySlugProvider(slug)),
        ),
        AsyncValue<Category?>(:final Category? value) =>
          value == null
              ? EmptyState(
                  title: l10n.stateNotFoundTitle,
                  message: l10n.stateNotFoundMessage,
                  icon: Icons.category_outlined,
                )
              : CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          18,
                          16,
                          4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (mother.value case final Category parent)
                              _Breadcrumb(
                                parent: parent,
                                child: value,
                                language: language,
                              ),
                            Text(
                              value.nameFor(language),
                              style:
                                  BrandTypography.displayForLocale(
                                    Localizations.localeOf(context),
                                    base: BrandTypography.displayMedium,
                                  ).copyWith(
                                    color: dark
                                        ? BrandColors.goldLight
                                        : BrandColors.charcoal,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(width: 72, child: GoldDivider()),
                          ],
                        ),
                      ),
                    ),
                    if (subcategories.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _CategoryNameRow(
                          mother: value,
                          categories: subcategories,
                          language: language,
                          selectedSlug: slug,
                        ),
                      ),
                    switch (products) {
                      AsyncLoading() => const SliverShimmerGrid(),
                      AsyncError(:final Object error) => SliverToBoxAdapter(
                        child: ErrorStateView(
                          failure: error is AppFailure
                              ? error
                              : UnknownFailure(cause: error),
                          compact: true,
                        ),
                      ),
                      AsyncValue<List<Product>>(:final List<Product>? value) =>
                        _gridSliver(
                          context,
                          value ?? const <Product>[],
                          limit: limit,
                          categoryLabels: subcategories.isEmpty
                              ? null
                              : <String, String>{
                                  for (final Category child in subcategories)
                                    child.id: child.nameFor(language),
                                },
                          onMore: () => ref
                              .read(
                                visibleCountProvider('category-$slug').notifier,
                              )
                              .more(),
                        ),
                    },
                  ],
                ),
      },
    );
  }

  /// Grid of results, or an empty state — always returned as a sliver so it can
  /// sit inside the `CustomScrollView` alongside the header.
  Widget _gridSliver(
    BuildContext context,
    List<Product> items, {
    required int limit,
    required VoidCallback onMore,
    Map<String, String>? categoryLabels,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyState(
          title: l10n.stateEmptyTitle,
          message: l10n.stateEmptyMessage,
        ),
      );
    }
    final List<Product> page = items.take(limit).toList(growable: false);
    final bool hasMore = items.length > page.length;

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 28),
          sliver: SliverGrid(
            gridDelegate: productGridDelegate(context),
            delegate: SliverChildBuilderDelegate(
              (_, int index) => RepaintBoundary(
                child: ProductCard(
                  key: ValueKey<String>(page[index].id),
                  product: page[index],
                  // On a mother's page a product filed under a child says so,
                  // in a small gold line above the title.
                  categoryLabel: categoryLabels?[page[index].categoryId],
                ),
              ),
              childCount: page.length,
            ),
          ),
        ),
        if (hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 28),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: onMore,
                  icon: const Icon(Icons.expand_more_rounded, size: 18),
                  label: Text(l10n.actionLoadMore),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "Mother › Child" above the subcategory's own heading.
class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({
    required this.parent,
    required this.child,
    required this.language,
  });

  final Category parent;
  final Category child;
  final String language;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = BrandTypography.labelLarge.copyWith(
      color: BrandColors.gold,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 6),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () => context.go(Routes.category(parent.slug)),
            child: Text(parent.nameFor(language), style: style),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '›',
              style: style.copyWith(color: BrandColors.goldHairline),
            ),
          ),
          Text(child.nameFor(language), style: style),
        ],
      ),
    );
  }
}

/// "All <mother>" plus every subcategory name, as small text chips.
///
/// Only shown on a top-level category's page, so a visitor can narrow the grid
/// to one child without losing the mother's heading. Text only, RTL-safe and
/// tall enough for a 2.0 accessibility scale.
class _CategoryNameRow extends StatelessWidget {
  const _CategoryNameRow({
    required this.mother,
    required this.categories,
    required this.language,
    required this.selectedSlug,
  });

  final Category mother;
  final List<Category> categories;
  final String language;

  /// Slug of the page being shown; `mother.slug` means "All <mother>".
  final String selectedSlug;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double scale = MediaQuery.textScalerOf(context).scale(1);

    return SizedBox(
      height: 34 + 16 * scale,
      child: ListView(
        key: const ValueKey<String>('category-name-chips'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: _NameChip(
              label: l10n.labelAllInCategory(mother.nameFor(language)),
              isSelected: selectedSlug == mother.slug,
              onTap: selectedSlug == mother.slug
                  ? null
                  : () => context.go(Routes.category(mother.slug)),
            ),
          ),
          for (final Category category in categories)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: _NameChip(
                label: category.nameFor(language),
                isSelected: selectedSlug == category.slug,
                onTap: () => context.go(Routes.category(category.slug)),
              ),
            ),
        ],
      ),
    );
  }
}

class _NameChip extends StatelessWidget {
  const _NameChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: isSelected,
      label: isSelected ? '$label (selected)' : label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? BrandColors.gold
                : (dark ? BrandColors.plumSurface : BrandColors.ivory),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? BrandColors.gold : BrandColors.goldHairline,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BrandTypography.labelLarge.copyWith(
              color: isSelected
                  ? BrandColors.charcoal
                  : (dark ? BrandColors.goldLight : BrandColors.charcoal),
            ),
          ),
        ),
      ),
    );
  }
}
