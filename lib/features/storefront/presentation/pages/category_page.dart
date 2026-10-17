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
import '../widgets/product_card.dart';

/// One category's products, keyed by slug so the URL is shareable.
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

    final String? categoryId = category.value?.id;
    final AsyncValue<List<Product>> products = categoryId == null
        ? const AsyncValue<List<Product>>.loading()
        : ref.watch(storefrontProductsProvider(categoryId: categoryId));
    // Subcategories of this page's category. Read from the same visible
    // categories stream the home rail uses, so a hidden subcategory stays
    // hidden here too — RLS already decided what this visitor can see.
    final List<Category> subcategories =
        ref
            .watch(visibleCategoriesProvider)
            .value
            ?.where(
              (Category candidate) =>
                  candidate.parentId != null &&
                  candidate.parentId == categoryId,
            )
            .toList(growable: false) ??
        const <Category>[];

    return AppScaffold(
      showLockup: false,
      title: category.value?.nameFor(language) ?? l10n.stateLoading,
      body: switch (category) {
        AsyncLoading() => const ShimmerGrid(),
        AsyncError(:final Object error) => ErrorStateView(
          failure: error is AppFailure ? error : UnknownFailure(cause: error),
          onRetry: () => ref.invalidate(categoryBySlugProvider(slug)),
        ),
        AsyncValue<Category?>(:final Category? value) when value == null =>
          EmptyState(
            title: l10n.stateNotFoundTitle,
            message: l10n.stateNotFoundMessage,
            icon: Icons.category_outlined,
          ),
        _ => CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      category.value!.nameFor(language),
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
                    if (subcategories.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          for (final Category child in subcategories)
                            ActionChip(
                              avatar: const Icon(
                                Icons.subdirectory_arrow_right_rounded,
                                size: 16,
                                color: BrandColors.gold,
                              ),
                              backgroundColor: dark
                                  ? BrandColors.plumSurface
                                  : BrandColors.ivory,
                              side: const BorderSide(
                                color: BrandColors.goldHairline,
                              ),
                              label: Text(child.nameFor(language)),
                              labelStyle: BrandTypography.labelLarge,
                              onPressed: () =>
                                  context.go(Routes.category(child.slug)),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            switch (products) {
              AsyncLoading() => const SliverToBoxAdapter(child: ShimmerGrid()),
              AsyncError(:final Object error) => SliverToBoxAdapter(
                child: ErrorStateView(
                  failure: error is AppFailure
                      ? error
                      : UnknownFailure(cause: error),
                  compact: true,
                ),
              ),
              AsyncValue<List<Product>>(:final List<Product>? value) =>
                _gridSliver(context, value ?? const <Product>[]),
            },
          ],
        ),
      },
    );
  }

  /// Grid of results, or an empty state — always returned as a sliver so it can
  /// sit inside the `CustomScrollView` alongside the header.
  Widget _gridSliver(BuildContext context, List<Product> items) {
    if (items.isEmpty) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      return SliverToBoxAdapter(
        child: EmptyState(
          title: l10n.stateEmptyTitle,
          message: l10n.stateEmptyMessage,
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, int index) => ProductCard(product: items[index]),
          childCount: items.length,
        ),
      ),
    );
  }
}
