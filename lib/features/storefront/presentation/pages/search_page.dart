import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_card.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/storefront_providers.dart';
import '../widgets/product_card.dart';

/// Searches `public.products` through the `search_products` RPC, which uses the
/// `pg_trgm` index built in the migration.
class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String query = ref.watch(searchQueryProvider);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    final AsyncValue<List<Product>> results = query.trim().length < 2
        ? const AsyncValue<List<Product>>.data(<Product>[])
        : ref.watch(searchProductsProvider(query));

    return AppScaffold(
      showLockup: false,
      title: l10n.actionSearch,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (String value) =>
                  ref.read(searchQueryProvider.notifier).update(value),
              style: BrandTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () =>
                            ref.read(searchQueryProvider.notifier).clear(),
                      ),
              ),
            ),
          ),
          Expanded(
            child: switch (results) {
              AsyncLoading() => const ShimmerGrid(itemCount: 4),
              AsyncError(:final Object error) => ErrorStateView(
                failure: error is AppFailure
                    ? error
                    : UnknownFailure(cause: error),
                onRetry: () => ref.invalidate(searchProductsProvider(query)),
              ),
              AsyncValue<List<Product>>(:final List<Product>? value) =>
                (value ?? const <Product>[]).isEmpty
                    ? EmptyState(
                        title: query.trim().length < 2
                            ? l10n.actionSearch
                            : l10n.searchNoResults(query),
                        message: l10n.searchHint,
                        icon: Icons.search_rounded,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                            child: Text(
                              l10n.searchResultsCount(value!.length),
                              style: BrandTypography.bodySmall.copyWith(
                                color: dark
                                    ? BrandColors.goldLight
                                    : BrandColors.charcoal,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              itemCount: value.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.62,
                                  ),
                              itemBuilder: (_, int index) =>
                                  ProductCard(product: value[index]),
                            ),
                          ),
                        ],
                      ),
            },
          ),
        ],
      ),
    );
  }
}
