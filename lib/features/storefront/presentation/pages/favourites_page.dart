import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/gold_divider.dart';
import '../../../catalog/domain/entities/product.dart';
import '../providers/favourites_providers.dart';
import '../widgets/product_card.dart';

/// Everything the customer hearted, rendered from the live catalogue.
///
/// Favourites are ids on the device, not copies of the products, so a piece the
/// owner repriced or unpublished is reflected here the moment it changes.
class FavouritesPage extends ConsumerWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Product> products = ref.watch(favouriteProductsProvider);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      showLockup: false,
      title: l10n.navFavourites,
      actions: <Widget>[
        if (products.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: l10n.actionClear,
            onPressed: () => ref.read(favouritesProvider.notifier).clear(),
          ),
      ],
      body: products.isEmpty
          ? EmptyState(
              title: l10n.favouritesEmptyTitle,
              message: l10n.favouritesEmptyMessage,
              icon: Icons.favorite_border_rounded,
            )
          // One CustomScrollView: a shrink-wrapped grid inside a ListView
          // nests two viewports and loses lazy building for every tile.
          : CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.navFavourites,
                          style: BrandTypography.displayMedium.copyWith(
                            color: dark
                                ? BrandColors.goldLight
                                : BrandColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(width: 72, child: GoldDivider()),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: productGridDelegate(context),
                    delegate: SliverChildBuilderDelegate(
                      (_, int index) => ProductCard(
                        key: ValueKey<String>(products[index].id),
                        product: products[index],
                      ),
                      childCount: products.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 40),
                    child: Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.storefront_outlined),
                        label: Text(l10n.adminViewStore),
                        onPressed: () => context.go(Routes.storefront),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
