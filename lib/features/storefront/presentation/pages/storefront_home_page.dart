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
class StorefrontHomePage extends ConsumerWidget {
  const StorefrontHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  data: (List<Product> items) => _FeaturedRail(products: items),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: sectionTitle('allProducts', l10n.sectionAllProducts),
                textKey: 'sectionAllProducts',
              ),
            ),
            _ProductGrid(
              asyncProducts: all,
              limit: productLimit,
              onMore: () => ref
                  .read(visibleCountProvider('home-products').notifier)
                  .more(),
            ),
            const SliverToBoxAdapter(child: _FooterContact()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
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
            Text(
              heroTitle(settings.storeNameFor(language).toUpperCase()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BrandTypography.titleLarge.copyWith(
                color: BrandColors.ivory,
                fontSize: 18,
                letterSpacing: 1.2,
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
  const _SectionHeader({
    required this.title,
    required this.textKey,
    this.onSeeAll,
  });

  final String title;
  final String textKey;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LiveEditableText(
            textKey: textKey,
            text: title,
            dense: true,
            style:
                BrandTypography.displayForLocale(
                  Localizations.localeOf(context),
                  base: BrandTypography.displaySmall,
                ).copyWith(
                  color: dark ? BrandColors.goldLight : BrandColors.charcoal,
                ),
          ),
          const SizedBox(height: 8),
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

class _FeaturedRail extends StatelessWidget {
  const _FeaturedRail({required this.products});

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
  });

  final AsyncValue<List<Product>> asyncProducts;
  final int limit;
  final VoidCallback onMore;

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
