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

    final AsyncValue<List<Category>> categories = ref.watch(
      visibleCategoriesProvider,
    );
    final AsyncValue<List<Product>> featured = ref.watch(
      storefrontProductsProvider(featured: true),
    );
    final AsyncValue<List<Product>> all = ref.watch(
      storefrontProductsProvider(),
    );

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
                title: l10n.sectionBrowseCategories,
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
                data: (List<Category> items) => items.isEmpty
                    ? EmptyState(
                        title: l10n.stateEmptyTitle,
                        message: l10n.stateEmptyMessage,
                        compact: true,
                      )
                    : _CategoryRail(categories: items),
              ),
            ),
            if (featured.value?.isNotEmpty ?? false) ...<Widget>[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: l10n.sectionFeatured,
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
                title: l10n.sectionAllProducts,
                textKey: 'sectionAllProducts',
              ),
            ),
            _ProductGrid(asyncProducts: all),
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
    final String? primary = ref.watch(primaryContactLinkProvider)?.displayValue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
        decoration: BoxDecoration(
          gradient: BrandGradients.brandVertical,
          borderRadius: BorderRadius.circular(26),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: BrandColors.royalViolet.withValues(alpha: 0.30),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: BrandColors.goldLight.withValues(alpha: 0.75),
                ),
              ),
              child: Text(
                l10n.brandMonogram,
                style: BrandTypography.labelSmall.copyWith(
                  color: BrandColors.goldLight,
                  letterSpacing: 3,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Image.asset(
              'assets/brand/logo_transparent.png',
              height: 62,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 14),
            Text(
              settings.storeNameFor(language).toUpperCase(),
              style: BrandTypography.brandTitle.copyWith(
                color: BrandColors.ivory,
              ),
            ),
            const SizedBox(height: 10),
            LiveEditableText(
              textKey: 'tagline',
              text: settings.hasTagline ? settings.tagline! : l10n.tagline,
              dark: true,
              style: BrandTypography.bodyMedium.copyWith(
                color: BrandColors.ivory.withValues(alpha: 0.88),
              ),
            ),
            const SizedBox(height: 20),
            const GoldDivider(withOrnament: true),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: _HeroAction(
                    icon: Icons.grid_view_rounded,
                    label: l10n.sectionBrowseCategories,
                    textKey: 'sectionBrowseCategories',
                    onTap: () => context.push(Routes.search),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeroAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: l10n.actionContactOwner,
                    textKey: 'actionContactOwner',
                    subtitle: primary,
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

class _HeroAction extends StatelessWidget {
  const _HeroAction({
    required this.icon,
    required this.label,
    required this.textKey,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String textKey;
  final String? subtitle;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 20, color: BrandColors.goldLight),
              const SizedBox(height: 8),
              LiveEditableText(
                textKey: textKey,
                text: label,
                dark: true,
                dense: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: BrandTypography.labelLarge.copyWith(
                  color: BrandColors.ivory,
                  fontSize: 13,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BrandTypography.bodySmall.copyWith(
                    color: BrandColors.ivory.withValues(alpha: 0.72),
                  ),
                ),
              ],
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
  const _CategoryRail({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String language = Localizations.localeOf(context).languageCode;

    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final Category category = categories[index];
          return Semantics(
            button: true,
            label: l10n.a11yOpenCategory(category.nameFor(language)),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => context.push(Routes.category(category.slug)),
              child: Container(
                width: 138,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: BrandColors.goldHairline),
                  gradient: LinearGradient(
                    colors: dark
                        ? <Color>[BrandColors.plumSurface, BrandColors.deepPlum]
                        : <Color>[Colors.white, BrandColors.ivory],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: BrandGradients.brand,
                      ),
                      child: const Icon(
                        Icons.weekend_outlined,
                        size: 20,
                        color: BrandColors.ivory,
                      ),
                    ),
                    Text(
                      category.nameFor(language),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BrandTypography.titleMedium.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
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
    return SizedBox(
      height: 296,
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
  const _ProductGrid({required this.asyncProducts});

  final AsyncValue<List<Product>> asyncProducts;

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
        l10n,
        value ?? const <Product>[],
      ),
    };
  }

  /// Grid of all published products, or the branded empty state.
  Widget _gridSliver(AppLocalizations l10n, List<Product> items) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyState(
          title: l10n.stateEmptyTitle,
          message: l10n.stateEmptyMessage,
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
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
