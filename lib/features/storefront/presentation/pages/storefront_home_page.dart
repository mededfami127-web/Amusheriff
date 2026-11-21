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
import '../../../contacts/domain/contact_launcher.dart';
import '../../../contacts/domain/entities/contact_link.dart';
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
  /// Top-level category the screen is showing; `null` means the mixed "All"
  /// list. A subcategory is never held here — it is a second-level refinement
  /// of its mother, chosen from the text row under the heading.
  String? _selectedRootId;

  /// Subcategory narrowing the grid inside [_selectedRootId]; `null` means
  /// "All <mother>", which includes every subcategory's products.
  String? _selectedChildId;

  void _selectRoot(String? id) {
    if (_selectedRootId == id && _selectedChildId == null) return;
    setState(() {
      _selectedRootId = id;
      _selectedChildId = null;
    });
  }

  void _selectChild(String id) {
    if (_selectedChildId == id) return;
    setState(() => _selectedChildId = id);
  }

  void _clearChild() {
    if (_selectedChildId == null) return;
    setState(() => _selectedChildId = null);
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

    // Top-level list: the query hands back roots only, so a subcategory can
    // never turn into a card of its own further down.
    final AsyncValue<List<Category>> rootsAsync = ref.watch(
      rootCategoriesProvider,
    );
    final AsyncValue<List<Product>> featured = ref.watch(
      storefrontProductsProvider(featured: true),
    );
    final AsyncValue<List<Product>> all = ref.watch(
      storefrontProductsProvider(),
    );

    final List<Category> roots = rootsAsync.value ?? const <Category>[];
    final Category? selected = _categoryById(roots, _selectedRootId);
    // The children of the selected mother, straight from their own query. With
    // no mother selected this is empty, so the row disappears instead of
    // showing an empty strip of space.
    final List<Category> subcategories = selected == null
        ? const <Category>[]
        : ref.watch(childCategoriesProvider(selected.id)).value ??
              const <Category>[];
    final Category? selectedChild = _childById(subcategories, _selectedChildId);

    // Every category name, used only to label the cards. The lists above come
    // from their own root/child queries; this one map adds "Mother · Child"
    // under a product that is filed on a subcategory.
    final List<Category> categoryList =
        ref.watch(visibleCategoriesProvider).value ?? const <Category>[];
    final Map<String, Category> byId = <String, Category>{
      for (final Category c in categoryList) c.id: c,
    };
    final Map<String, String> categoryLabels = <String, String>{};
    for (final Category c in categoryList) {
      final Category? mother = c.parentId == null ? null : byId[c.parentId];
      categoryLabels[c.id] = mother == null
          ? c.nameFor(language)
          : '${mother.nameFor(language)} · ${c.nameFor(language)}';
    }

    // "All <mother>" shows the mother's own products plus every subcategory's;
    // a subcategory narrows to itself alone.
    final Set<String>? filterIds = selectedChild != null
        ? <String>{selectedChild.id}
        : selected != null
        ? <String>{selected.id, for (final Category c in subcategories) c.id}
        : null;
    final AsyncValue<List<Product>> gridProducts = filterIds == null
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
            // Two columns, scrolling with the page. A horizontal rail hid
            // most of the catalogue behind a swipe; a grid shows the shape of
            // the shop at a glance.
            _CategorySliverGrid(
              asyncCategories: rootsAsync,
              limit: categoryLimit,
              onMore: () => ref
                  .read(visibleCountProvider('home-categories').notifier)
                  .more(),
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
                  loading: () => const ShimmerGrid(
                    itemCount: 2,
                    aspectRatio: 0.56,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  error: (Object error, _) => const SizedBox.shrink(),
                  data: (List<Product> items) => GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: productGridDelegate(context),
                    itemBuilder: (_, int index) => ProductCard(
                      key: ValueKey<String>(items[index].id),
                      product: items[index],
                    ),
                  ),
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
              child: _RootFilterWrap(
                categories: roots,
                selected: selected,
                language: language,
                onSelect: _selectRoot,
              ),
            ),
            // Names only: a subcategory is a refinement of the mother above
            // it, so it reads as small text chips and never as a card. With
            // no children there is no row at all, not an empty strip.
            if (subcategories.isNotEmpty)
              SliverToBoxAdapter(
                child: _SubcategoryNameWrap(
                  motherName: selected!.nameFor(language),
                  categories: subcategories,
                  selectedId: selectedChild?.id,
                  language: language,
                  onAll: _clearChild,
                  onSelect: _selectChild,
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
                gridContext: context,
                language: language,
                roots: roots,
                categoryList: categoryList,
                products: all.value ?? const <Product>[],
              ),
            const SliverToBoxAdapter(child: _FooterContact()),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  /// One section per **root** category that has products: its name, its
  /// children's names as small chips, its rail, and a "See all" into its page.
  /// Rendered only while the grid shows the mixed "All" list, so nothing is
  /// ever listed twice on screen. A subcategory never gets a section of its
  /// own — its products appear in the mother's rail, where they belong.
  List<Widget> _groupedSections({
    required BuildContext gridContext,
    required String language,
    required List<Category> roots,
    required List<Category> categoryList,
    required List<Product> products,
  }) {
    if (products.isEmpty) return const <Widget>[];

    final List<Widget> slivers = <Widget>[];
    for (final Category root in roots) {
      final List<Category> children = categoryList
          .where((Category c) => c.parentId == root.id)
          .toList(growable: false);
      final Set<String> ids = <String>{
        root.id,
        for (final Category child in children) child.id,
      };
      final List<Product> items = products
          .where((Product p) => ids.contains(p.categoryId))
          .take(6)
          .toList(growable: false);
      if (items.isEmpty) continue;
      slivers.add(
        SliverToBoxAdapter(
          child: _GroupedSectionHeader(
            title: root.nameFor(language),
            subcategories: children,
            language: language,
            onSeeAll: () => context.push(Routes.category(root.slug)),
          ),
        ),
      );
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: productGridDelegate(gridContext),
            delegate: SliverChildBuilderDelegate(
              (_, int index) => ProductCard(
                key: ValueKey<String>(items[index].id),
                product: items[index],
              ),
              childCount: items.length,
            ),
          ),
        ),
      );
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

/// The subcategory a chip is narrowing to, or `null` for "All <mother>".
Category? _childById(List<Category> children, String? id) {
  if (id == null) return null;
  for (final Category candidate in children) {
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

    // An override still carrying the pre-rename spelling loses to the current
    // brand; any other owner-written title is kept word for word.
    String heroTitle(String fallback) {
      final String? override = siteContent['heroTitle'];
      if (override == null || SiteSettings.isOldBrandSpelling(override)) {
        return fallback;
      }
      return override;
    }

    // The stored shop name may still be the old wording, so the hero resolves
    // it the same way the app bar does: legacy or blank falls back to the
    // localised brand, and the full name wraps onto as many lines as it needs.
    final String brand = settings.displayName(
      language,
      brandFallback: l10n.appTitle,
    );
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
              heroTitle(brand),
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

/// "All" + every **root** category, right under the "All products" heading.
///
/// A [Wrap], never a horizontal rail: the chips flow onto as many rows as the
/// screen needs, so nothing is hidden behind a sideways swipe and the page
/// scrolls in one direction only. Subcategories are never chips in this row;
/// they appear as plain names under their mother, in [_SubcategoryNameWrap].
class _RootFilterWrap extends StatelessWidget {
  const _RootFilterWrap({
    required this.categories,
    required this.selected,
    required this.language,
    required this.onSelect,
  });

  final List<Category> categories;
  final Category? selected;
  final String language;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 6),
      child: Wrap(
        key: const ValueKey<String>('home-root-chips'),
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          _FilterChip(
            label: l10n.labelAll,
            icon: Icons.grid_view_rounded,
            isSelected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final Category category in categories)
            _FilterChip(
              label: category.nameFor(language),
              icon: Icons.category_outlined,
              isSelected: selected?.id == category.id,
              onTap: () => onSelect(category.id),
            ),
        ],
      ),
    );
  }
}

/// The names of one mother's subcategories, as small text chips.
///
/// "All <mother>" comes first and is pre-selected: it means the mother's own
/// products *and* everything filed under a child. No images, no cards, no
/// icons — a subcategory is a refinement, not a destination of its own.
///
/// A [Wrap] rather than a sideways strip: every subcategory is visible without
/// a swipe, and the row grows downwards as the text scale grows.
class _SubcategoryNameWrap extends StatelessWidget {
  const _SubcategoryNameWrap({
    required this.motherName,
    required this.categories,
    required this.selectedId,
    required this.language,
    required this.onAll,
    required this.onSelect,
  });

  final String motherName;
  final List<Category> categories;
  final String? selectedId;
  final String language;
  final VoidCallback onAll;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 6),
      child: Wrap(
        key: const ValueKey<String>('home-subcategory-chips'),
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          _NameChip(
            label: l10n.labelAllInCategory(motherName),
            isSelected: selectedId == null,
            onTap: onAll,
          ),
          for (final Category category in categories)
            _NameChip(
              label: category.nameFor(language),
              isSelected: selectedId == category.id,
              onTap: () => onSelect(category.id),
            ),
        ],
      ),
    );
  }
}

/// A borderless, text-only chip: the subcategory name and nothing else.
class _NameChip extends StatelessWidget {
  const _NameChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
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
              // A chip grows with its translated label but never past the
              // row: a long name ellipsizes instead of overflowing the Wrap.
              Flexible(
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
  const _GroupedSectionHeader({
    required this.title,
    required this.onSeeAll,
    this.subcategories = const <Category>[],
    this.language = 'en',
  });

  final String title;
  final VoidCallback onSeeAll;

  /// The root's children. Their names sit under the heading, small and
  /// text-only, so the home screen shows the tree without extra cards.
  final List<Category> subcategories;
  final String language;

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
                  maxLines: 2,
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
          if (subcategories.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8, bottom: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: <Widget>[
                  for (final Category child in subcategories)
                    _SubcategoryLabel(text: child.nameFor(language)),
                ],
              ),
            ),
          const SizedBox(width: 64, child: GoldDivider()),
        ],
      ),
    );
  }
}

/// A tiny, non-interactive name under a section heading.
class _SubcategoryLabel extends StatelessWidget {
  const _SubcategoryLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: BrandTypography.labelSmall.copyWith(
          color: dark ? BrandColors.goldLight : BrandColors.gold,
        ),
      ),
    );
  }
}

/// "Browse by category" as a vertical grid that scrolls with the page.
///
/// Two columns on a phone, three on a tablet; a "Load more" row replaces the
/// old end-of-rail card, so the whole catalogue stays reachable without a
/// sideways swipe.
class _CategorySliverGrid extends ConsumerWidget {
  const _CategorySliverGrid({
    required this.asyncCategories,
    required this.limit,
    required this.onMore,
  });

  final AsyncValue<List<Category>> asyncCategories;
  final int limit;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (asyncCategories) {
      AsyncLoading() => const SliverToBoxAdapter(
        child: ShimmerGrid(itemCount: 4, aspectRatio: 1.05),
      ),
      AsyncError(:final Object error) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InlineFailureBanner(
            failure: error is AppFailure ? error : UnknownFailure(cause: error),
            onRetry: () => ref.invalidate(rootCategoriesProvider),
          ),
        ),
      ),
      AsyncValue<List<Category>>(:final List<Category>? value) => _grid(
        context,
        l10n,
        value ?? const <Category>[],
      ),
    };
  }

  Widget _grid(
    BuildContext context,
    AppLocalizations l10n,
    List<Category> roots,
  ) {
    if (roots.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyState(
          title: l10n.stateEmptyTitle,
          message: l10n.stateEmptyMessage,
          compact: true,
        ),
      );
    }
    final List<Category> page = roots.take(limit).toList(growable: false);
    final bool hasMore = roots.length > page.length;

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: categoryGridDelegate(context),
            delegate: SliverChildBuilderDelegate(
              (_, int index) => RepaintBoundary(
                child: CategoryCard(
                  key: ValueKey<String>(page[index].id),
                  category: page[index],
                  onTap: () => context.push(Routes.category(page[index].slug)),
                ),
              ),
              childCount: page.length,
            ),
          ),
        ),
        if (hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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

/// "Contact the owner": every visible owner link, opened in the browser or the
/// matching app.
///
/// The whole block is absent when the owner has published no links, which is
/// what the empty `contact_links` table means — not an empty heading.
class _FooterContact extends ConsumerWidget {
  const _FooterContact();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<ContactLink> links =
        ref.watch(visibleContactLinksProvider).value ?? const <ContactLink>[];
    if (links.isEmpty) return const SizedBox.shrink();

    Future<void> open(ContactLink link) async {
      final ContactLauncher launcher = ref.read(contactLauncherProvider);
      final bool opened = await launcher.launch(link);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.contactLaunchFailed)));
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: Column(
        children: <Widget>[
          const GoldDivider(withOrnament: true),
          const SizedBox(height: 18),
          Text(
            l10n.actionContactOwner,
            textAlign: TextAlign.center,
            style: BrandTypography.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.contactOwnerHint,
            textAlign: TextAlign.center,
            style: BrandTypography.bodySmall.copyWith(
              color: BrandTypography.mutedOn(Theme.of(context).brightness),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (final ContactLink link in links)
                OutlinedButton.icon(
                  onPressed: () => open(link),
                  icon: Icon(link.kind.icon, size: 18),
                  label: Text(
                    link.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
