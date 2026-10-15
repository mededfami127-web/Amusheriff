import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../data/favourites_store.dart';

part 'favourites_providers.g.dart';

/// Overridden in `bootstrap()` with the already-loaded store.
@Riverpod(keepAlive: true)
FavouritesStore favouritesStore(Ref ref) =>
    FavouritesStore(const FlutterSecureStorage());

/// The set of favourited product ids.
@Riverpod(keepAlive: true)
class Favourites extends _$Favourites {
  @override
  Set<String> build() => ref.watch(favouritesStoreProvider).ids;

  FavouritesStore get _store => ref.read(favouritesStoreProvider);

  /// Returns `true` when the product ended up favourited.
  Future<bool> toggle(String productId) async {
    final bool added = await _store.toggle(productId);
    state = _store.ids;
    return added;
  }

  Future<void> clear() async {
    await _store.clear();
    state = _store.ids;
  }
}

/// `true` when the product is in the customer's list.
@riverpod
bool isFavourite(Ref ref, String productId) =>
    ref.watch(favouritesProvider).contains(productId);

/// The favourited pieces, resolved live from the catalogue stream.
///
/// Any admin edit — a new photo, a price change, an item going out of stock —
/// shows up on the favourites screen with no extra query.
@riverpod
List<Product> favouriteProducts(Ref ref) {
  final Set<String> ids = ref.watch(favouritesProvider);
  if (ids.isEmpty) return const <Product>[];

  final List<Product> products =
      ref.watch(storefrontProductsProvider()).value ?? const <Product>[];
  return products
      .where((Product product) => ids.contains(product.id))
      .toList(growable: false);
}
