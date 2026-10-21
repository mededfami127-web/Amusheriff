import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/gold_divider.dart';
import '../../../../core/widgets/inline_failure_banner.dart';
import '../../../../core/widgets/live_editable_text.dart';
import '../../../../core/widgets/shimmer_card.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../contacts/presentation/providers/contact_providers.dart';
import '../../../settings/domain/entities/site_settings.dart';
import '../../../settings/presentation/providers/site_settings_providers.dart';
import '../../../settings/presentation/providers/site_content_providers.dart';
import '../providers/storefront_providers.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';

/// Public home. Everything on this page is driven by live Supabase streams, so
/// an admin edit appears here without a refresh.
///
/// The "All products" grid can be narrowed to one category from the chip row
/// under its heading. That selection lives in widget state rather than a
/// provider: it is view state for this screen only, and keeping it out of the
/// provider graph means a language switch (which rebuilds the subtree) changes
/// every label without re-fetching a single row.
class StorefrontHomePage extends ConsumerStatefulWidget {
  const StorefrontHomePage({super.key});

  @override
  ConsumerState<StorefrontHomePage> createState() => _StorefrontHomePageState();
}

class _StorefrontHomePageState extends ConsumerState<StorefrontHomePage> {
  /// Category the grid is filtered to; `null` means the mixed "All" list.
  String? _selectedCategoryId;

  void _select(String? id) {
    if (_selectedCategoryId == id) return;
    setState(() => _selectedCategoryId = id);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SiteSettings settings = ref.watch(siteSettingsValueProvider);
    final String language = Localizations.localeOf(context).languageCode;

    final Map<String, String> siteContent = ref.watch(
      siteContentValueProvider(language),
    );

    String sectionTitle(String key, String fallback) =>
        siteContent['sectionTitle:$key'] ?? fallback;

    final AsyncValue<List<Category>> categories = ref.watch(
      visibleCategoriesProvider,
    );
    final AsyncValue<List<Product>> featured = ref.watch(
      storefrontProductsProvider(featured: true),
    );
    final AsyncValue<List<Product>> all = ref.watch(
      storefrontProductsProvider(),
    );

    // Everything the chip row under "All products" needs, plus the category
    // label each card of the mixed grid carries. Derived from the same stream
    // the rail above already watches — no extra request, and a language switch
    // re-derives the strings from the entities without touching the backend.
    final List<Category> categoryList = categories.value ?? const <Category>[];
    final List<Category> roots = categoryList
        .where((Category c) => c.parentId == null)
        .toList(growable: false);
    final Category? selected = _categoryById(categoryList, _selectedCategoryId);
    final List<Category> subcategories = selected == null
        ? const <Category>[]
        : categoryList
              .where((Category c) => c.parentId == selected.id)
              .toList(growable: false);
    final Map<String, String> categoryLabels = <String, String>{
      for (final Category c in categoryList) c.id: c.nameFor(language),
    };
    // A root chip shows its own products *and* those of its subcategories;
    // a subcategory chip narrows to that subcategory alone.
    final Set<String> filterIds = <String>{};
    if (selected != null) {
      filterIds.add(selected.id);
      for (final Category c in categoryList) {
        if (c.parentId == selected.id) filterIds.add(c.id);
      }
    }
    final AsyncValue<List<Product>> gridProducts = _selectedCategoryId == null
        ? all
        : all.whenData(
            (List<Product> items) => items
                .where((Product p) => filterIds.contains(p.categoryId))
                .toList(growable: false),
          );

    // One page of 20 at a time. The streams stay live; this only limits how
    // much of the already-cached list is built and painted in one pass.
    final int categoryLimit = ref.watch(
      visibleCountProvider('home-categories'),
    );
    final int productLimit = ref.watch(visibleCountProvider('home-products'));

    return AppScaffold(
      actions: <Widget>[
        IconButton(
          onPressed: () => context.push(Routes.search),
          icon: const Icon(Icons.search_rounded),
          tooltip: l10n.actionSearch,
        ),
        IconButton(
          onPressed: () => context.push(Routes.favourites),
          icon: const Icon(Icons.favorite_border_rounded),
          tooltip: l10n.navFavourites,
        ),
        IconButton(
          onPressed: () => context.push(Routes.settings),
          icon: const Icon(Icons.tune_rounded),
          tooltip: l10n.navSettings,
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(visibleCategoriesProvider);
          ref.invalidate(storefrontProductsProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: _Hero(settings: settings, language: language),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: sectionTitle(
                  'browseCategories',
                  l10n.sectionBrowseCategories,
                ),
                textKey: 'sectionBrowseCategories',
                onSeeAll: null,
              ),
            ),
            SliverToBoxAdapter(
              child: categories.when(
                loading: () => const ShimmerRail(height: 150, itemCount: 3),
                error: (Object error, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InlineFailureBanner(
                    failure: error is AppFailure
                        ? error
                        : UnknownFailure(cause: error),
                    onRetry: () => ref.invalidate(visibleCategoriesProvider),
                  ),
                ),
                data: (List<Category> items) {
                  // Top-level categories only: a subcategory belongs to its
                  // mother, and is reached from that category's own page.
                  final List<Category> roots = items
                      .where((Category c) => c.parentId == null)
                      .toList(growable: false);
                  return roots.isEmpty
                      ? EmptyState(
                          title: l10n.stateEmptyTitle,
                          message: l10n.stateEmptyMessage,
                          compact: true,
                        )
                      : _CategoryRail(
                          categories: roots
                              .take(categoryLimit)
                              .toList(growable: false),
                          hasMore: roots.length > categoryLimit,
                          onMore: () => ref
                              .read(
                                visibleCountProvider('home-categories')
                                    .notifier,
                              )
                              .more(),
                        );
                },
              ),
            ),
            if (featured.value?.isNotEmpty ?? false) ...<Widget>[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: sectionTitle('featured', l10n.sectionFeatured),
                  textKey: 'sectionFeatured',
                ),
              ),
              SliverToBoxAdapter(
                child: featured.when(
                  loading: () => const ShimmerRail(),
                  error: (Object error, _) => const SizedBox.shrink(),
                  data: (List<Product> items) => _ProductRail(products: items),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: selected == null
                  ? _SectionHeader(
                      title: sectionTitle(
                        'allProducts',
                        l10n.sectionAllProducts,
                      ),
                      textKey: 'sectionAllProducts',
                    )
                  : _SectionHeader(title: selected.nameFor(language)),
            ),
            SliverToBoxAdapter(
              child: _CategoryFilterRow(
                categories: roots,
                selected: selected,
                language: language,
                onSelect: _select,
              ),
            ),
            if (subcategories.isNotEmpty)
              SliverToBoxAdapter(
                child: _CategoryFilterRow(
                  categories: subcategories,
                  selected: selected,
                  language: language,
                  onSelect: _select,
                  indented: true,
                ),
              ),
            _ProductGrid(
              asyncProducts: gridProducts,
              limit: productLimit,
              categoryLabels: categoryLabels,
              onMore: () => ref
                  .read(visibleCountProvider('home-products').notifier)
                  .more(),
            ),
            // The mixed list is the default; the per-category sections below
            // are the browsable alternative, each with its own "See all" into
            // the category page. Filtering hides them, so the screen never
            // shows the same product twice.
            if (selected == null)
              ..._groupedSections(
                language: language,
                roots: roots,
                products: all.value ?? const <Product>[],
              ),
            const SliverToBoxAdapter(child: _FooterContact()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  /// One section per top-level category that has products: its name, its rail,
  /// and a "See all" into its page. Rendered only while the grid shows the
  /// mixed "All" list, so nothing is ever listed twice on screen.
  List<Widget> _groupedSections({
    required String language,
    required List<Category> roots,
    required List<Product> products,
  }) {
    if (products.isEmpty) return const <Widget>[];

    final List<Widget> slivers = <Widget>[];
    for (final Category root in roots) {
      final List<Product> items = products
          .where((Product p) => p.categoryId == root.id)
          .take(6)
          .toList(growable: false);
      if (items.isEmpty) continue;
      slivers.add(
        SliverToBoxAdapter(
          child: _GroupedSectionHeader(
            title: root.nameFor(language),
            onSeeAll: () => context.push(Routes.category(root.slug)),
          ),
        ),
      );
      slivers.add(SliverToBoxAdapter(child: _ProductRail(products: items)));
    }
    return slivers;
  }
}

/// The category a chip row is filtering to, or `null` for "All".
Category? _categoryById(List<Category> categories, String? id) {
  if (id == null) return null;
  for (final Category candidate in categories) {
    if (candidate.id == id) return candidate;
  }
  return null;
}

class _Hero extends ConsumerWidget {
  const _Hero({required this.settings, required this.language});

  final SiteSettings settings;
  final String language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Map<String, String> siteContent = ref.watch(
      siteContentValueProvider(language),
    );

    String heroTitle(String fallback) => siteContent['heroTitle'] ?? fallback;
    String heroTagline(String fallback) =>
        siteContent['heroTagline'] ?? fallback;
    String heroButtonLabel(String fallback) =>
        siteContent['heroButtonLabel'] ?? fallback;

    return Padding(
      key: const ValueKey<String>('home-hero'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        decoration: BoxDecoration(
          gradient: BrandGradients.brandVertical,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: BrandColors.royalViolet.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/brand/logo_transparent.png',
              height: 24,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const _HeroFallbackLogo(),
            ),
            const SizedBox(height: 4),
            // The brand is a full shop name now, so it wraps onto two or
            // three lines instead of being cut off with an ellipsis.
            Text(
              heroTitle(settings.storeNameFor(language)),
              softWrap: true,
              style: BrandTypography.titleLarge.copyWith(
                color: BrandColors.ivory,
                fontSize: 18,
                height: 1.15,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            LiveEditableText(
              textKey: 'tagline',
              text: settings.hasTagline
                  ? heroTagline(settings.tagline!)
                  : heroTagline(l10n.tagline),
              dark: true,
              dense: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BrandTypography.bodySmall.copyWith(
                color: BrandColors.ivory.withValues(alpha: 0.88),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _HeroAction(
                    icon: Icons.grid_view_rounded,
                    label: heroButtonLabel(l10n.sectionBrowseCategories),
                    textKey: 'sectionBrowseCategories',
                    onTap: () => context.push(Routes.search),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeroAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: heroButtonLabel(l10n.actionContactOwner),
                    textKey: 'actionContactOwner',
                    onTap: () => context.push(Routes.about),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.06, end: 0);
  }
}

/// Shown when the packaged logo asset cannot be decoded, so the hero still
/// carries the shop's mark instead of a broken-image box.
class _HeroFallbackLogo extends StatelessWidget {
  const _HeroFallbackLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: BrandColors.goldLight),
      ),
      child: Text(
        AppLocalizations.of(context).brandMonogram,
        style: BrandTypography.labelSmall.copyWith(
          color: BrandColors.goldLight,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({
    required this.icon,
    required this.label,
    required this.textKey,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String textKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 14, color: BrandColors.goldLight),
              const SizedBox(height: 3),
              LiveEditableText(
                textKey: textKey,
                text: label,
                dark: true,
                dense: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: BrandTypography.labelLarge.copyWith(
                  color: BrandColors.ivory,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.textKey, this.onSeeAll});

  final String title;

  /// Site-content key of the title. `null` for a heading that comes from data
  /// (a category name): the wording editor must never overwrite it.
  final String? textKey;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final TextStyle style = BrandTypography.displayForLocale(
      Localizations.localeOf(context),
      base: BrandTypography.displaySmall,
    ).copyWith(color: dark ? BrandColors.goldLight : BrandColors.charcoal);

    final Widget heading = textKey == null
        ? Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: style,
          )
        : LiveEditableText(
            textKey: textKey!,
            text: title,
            dense: true,
            style: style,
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          heading,
          const SizedBox(height: 8),
          const SizedBox(width: 64, child: GoldDivider()),
        ],
      ),
    );
  }
}

/// "All" + every category, right under the "All products" heading.
///
/// Horizontally scrolling so a long list never wraps into the grid, RTL-safe
/// because the scroll direction follows the ambient directionality, and its
/// height grows with the accessibility text scale so a 2.0 chip is never
/// clipped by the rail.
class _CategoryFilterRow extends StatelessWidget {
  const _CategoryFilterRow({
    required this.categories,
    required this.selected,
    required this.language,
    required this.onSelect,
    this.indented = false,
  });

  final List<Category> categories;
  final Category? selected;
  final String language;
  final ValueChanged<String?> onSelect;

  /// True for the subcategory row: its chips are drawn with the parent's
  /// indent so the hierarchy reads at a glance.
  final bool indented;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double scale = MediaQuery.textScalerOf(context).scale(1);

    return SizedBox(
      height: 36 + 14 * scale,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          if (!indented)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: _FilterChip(
                label: l10n.labelAll,
                icon: Icons.grid_view_rounded,
                isSelected: selected == null,
                onTap: () => onSelect(null),
              ),
            ),
          for (int i = 0; i < categories.length; i++) ...<Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: _FilterChip(
                label: categories[i].nameFor(language),
                icon: indented
                    ? Icons.subdirectory_arrow_right_rounded
                    : Icons.category_outlined,
                // A selected subcategory also lights up its mother chip.
                isSelected:
                    selected != null &&
                    (selected!.id == categories[i].id ||
                        selected!.parentId == categories[i].id),
                onTap: () => onSelect(categories[i].id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? BrandColors.gold
                : (dark ? BrandColors.plumSurface : BrandColors.ivory),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? BrandColors.gold : BrandColors.goldHairline,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: isSelected ? BrandColors.charcoal : BrandColors.gold,
              ),
              const SizedBox(width: 6),
              // No fixed width: a chip grows with its (translated) label and
              // the rail simply scrolls, so nothing truncates at 320 dp.
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BrandTypography.labelLarge.copyWith(
                  color: isSelected
                      ? BrandColors.charcoal
                      : (dark ? BrandColors.goldLight : BrandColors.charcoal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category heading of a grouped section, with its "See all" into the page
/// that shows the whole category.
class _GroupedSectionHeader extends StatelessWidget {
  const _GroupedSectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 26, 8, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      BrandTypography.displayForLocale(
                        Localizations.localeOf(context),
                        base: BrandTypography.displaySmall,
                      ).copyWith(
                        color: dark
                            ? BrandColors.goldLight
                            : BrandColors.charcoal,
                      ),
                ),
              ),
              TextButton(onPressed: onSeeAll, child: Text(l10n.actionSeeAll)),
            ],
          ),
          const SizedBox(width: 64, child: GoldDivider()),
        ],
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({
    required this.categories,
    this.hasMore = false,
    this.onMore,
  });

  final List<Category> categories;
  final bool hasMore;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    // The tile's text block grows with the accessibility scale; the rail has
    // to grow with it, or the two-line name overflows the card.
    final double scale = MediaQuery.textScalerOf(context).scale(1);
    return SizedBox(
      height: 148 + (scale - 1).clamp(0.0, 1.0) * 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          if (index == categories.length) {
            return SizedBox(
              width: 138,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onMore,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: BrandColors.goldHairline),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.expand_more_rounded,
                        color: BrandColors.gold,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context).actionLoadMore,
                        textAlign: TextAlign.center,
                        style: BrandTypography.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          final Category category = categories[index];
          return CategoryCard(
            category: category,
            width: 138,
            onTap: () => context.push(Routes.category(category.slug)),
          );
        },
      ),
    );
  }
}

/// Horizontal rail of product cards — used by the featured row and by every
/// per-category "See all" section.
class _ProductRail extends StatelessWidget {
  const _ProductRail({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.textScalerOf(context).scale(1);
    return SizedBox(
      height: 296 + (scale - 1).clamp(0.0, 1.0) * 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, int index) =>
            ProductCard(product: products[index], width: 208),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.asyncProducts,
    required this.limit,
    required this.onMore,
    this.categoryLabels,
  });

  final AsyncValue<List<Product>> asyncProducts;
  final int limit;
  final VoidCallback onMore;

  /// categoryId → category name in the current language, printed on each card
  /// while the grid shows the mixed "All" list.
  final Map<String, String>? categoryLabels;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return switch (asyncProducts) {
      AsyncLoading() => const SliverToBoxAdapter(child: ShimmerGrid()),
      AsyncError(:final Object error) => SliverToBoxAdapter(
        child: ErrorStateView(
          failure: error is AppFailure ? error : UnknownFailure(cause: error),
          compact: true,
        ),
      ),
      AsyncValue<List<Product>>(:final List<Product>? value) => _gridSliver(
        context,
        l10n,
        value ?? const <Product>[],
      ),
    };
  }

  /// Grid of the first page, or the branded empty state.
  Widget _gridSliver(
    BuildContext context,
    AppLocalizations l10n,
    List<Product> items,
  ) {
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
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
          sliver: SliverGrid(
            gridDelegate: productGridDelegate(context),
            delegate: SliverChildBuilderDelegate(
              (_, int index) => RepaintBoundary(
                child: ProductCard(
                  key: ValueKey<String>(page[index].id),
                  product: page[index],
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
              padding: const EdgeInsetsDirectional.fromSTEB(16, 18, 16, 0),
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

class _FooterContact extends ConsumerWidget {
  const _FooterContact();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int count = ref.watch(visibleContactLinksProvider).value?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: Column(
        children: <Widget>[
          const GoldDivider(withOrnament: true),
          const SizedBox(height: 16),
          Text(
            count == 0 ? l10n.stateEmptyMessage : l10n.actionContactOwner,
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
