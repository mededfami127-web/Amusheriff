import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/utils/stream_utils.dart';
import '../../data/datasources/catalog_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/product_media_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_media.dart';
import '../../domain/repositories/catalog_repositories.dart';

part 'catalog_providers.g.dart';

// ── Repositories ────────────────────────────────────────────────────────────
// Overridden with fakes in tests, so no widget ever touches the network.

@Riverpod(keepAlive: true)
CatalogRemoteDataSource catalogRemoteDataSource(Ref ref) =>
    CatalogRemoteDataSource(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) =>
    CategoryRepositoryImpl(ref.watch(catalogRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) =>
    ProductRepositoryImpl(ref.watch(catalogRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
ProductMediaRepository productMediaRepository(Ref ref) =>
    ProductMediaRepositoryImpl(ref.watch(catalogRemoteDataSourceProvider));

// ── Storefront reads ────────────────────────────────────────────────────────

/// Visible categories, live. Anonymous visitors get exactly what RLS allows.
@riverpod
Stream<List<Category>> visibleCategories(Ref ref) =>
    ref.watch(categoryRepositoryProvider).watchVisible();

/// Every category, including hidden ones. Admin surface only.
@riverpod
Stream<List<Category>> allCategories(Ref ref) =>
    ref.watch(categoryRepositoryProvider).watchAll();

@riverpod
Future<Category?> categoryById(Ref ref, String id) =>
    ref.watch(categoryRepositoryProvider).findById(id);

@riverpod
Future<Category?> categoryBySlug(Ref ref, String slug) =>
    ref.watch(categoryRepositoryProvider).findBySlug(slug);

/// Number of visible products per category, for the "Browse by category" grid.
///
/// Counted client-side from the same Realtime stream the storefront already
/// subscribes to, so no extra view or round trip is needed.
@riverpod
Stream<Map<String, int>> categoryProductCounts(Ref ref) => ref
    .watch(productRepositoryProvider)
    .watch(onlyPublished: true)
    .map((List<Product> products) {
      final Map<String, int> counts = <String, int>{};
      for (final Product product in products) {
        counts[product.categoryId] = (counts[product.categoryId] ?? 0) + 1;
      }
      return counts;
    });

/// Storefront product list with media joined in memory.
///
/// Combines the `products` and `product_media` Realtime streams so a newly
/// uploaded photo appears immediately — without re-querying the product row.
@riverpod
Stream<List<Product>> storefrontProducts(
  Ref ref, {
  String? categoryId,
  bool featured = false,
}) {
  final ProductRepository products = ref.watch(productRepositoryProvider);
  final ProductMediaRepository media = ref.watch(
    productMediaRepositoryProvider,
  );

  return combineLatest(
    products.watch(
      categoryId: categoryId,
      onlyPublished: true,
      onlyFeatured: featured,
    ),
    media.watchAll(),
    _attachMedia,
  );
}

/// First product image per category, for category tiles without a cover.
///
/// Derived from the single [storefrontProducts] stream (products + media
/// joined in memory), so the rail never issues one query per category.
@riverpod
Map<String, String> categoryThumbnailPaths(Ref ref) {
  final List<Product> products =
      ref.watch(storefrontProductsProvider()).value ?? const <Product>[];
  final Map<String, String> paths = <String, String>{};
  for (final Product product in products) {
    if (paths.containsKey(product.categoryId)) continue;
    ProductMedia? chosen;
    for (final ProductMedia item in product.media) {
      if (!item.isImage) continue;
      if (item.isCover) {
        chosen = item;
        break;
      }
      chosen ??= item;
    }
    if (chosen != null) paths[product.categoryId] = chosen.storagePath;
  }
  return paths;
}

/// Admin product list, including unpublished rows.
@riverpod
Stream<List<Product>> adminProducts(Ref ref, {String? categoryId}) {
  final ProductRepository products = ref.watch(productRepositoryProvider);
  final ProductMediaRepository media = ref.watch(
    productMediaRepositoryProvider,
  );

  return combineLatest(
    products.watch(categoryId: categoryId, onlyPublished: false),
    media.watchAll(),
    _attachMedia,
  );
}

/// Product detail with its own media stream, so the gallery updates live.
@riverpod
Stream<Product?> productDetail(Ref ref, String id) {
  final ProductRepository products = ref.watch(productRepositoryProvider);
  final ProductMediaRepository media = ref.watch(
    productMediaRepositoryProvider,
  );

  return combineLatest(products.watchOne(id), media.watchForProduct(id), (
    Product? product,
    List<ProductMedia> items,
  ) {
    if (product == null) return null;
    return product.copyWith(media: _sortMedia(items));
  });
}

@riverpod
Future<List<Product>> searchProducts(Ref ref, String query) =>
    ref.watch(productRepositoryProvider).search(query);

/// Builds a `productId -> List<ProductMedia>` index and attaches it.
List<Product> _attachMedia(List<Product> products, List<ProductMedia> media) {
  final Map<String, List<ProductMedia>> byProduct = groupBy(
    media,
    (ProductMedia m) => m.productId,
  );

  return products
      .map(
        (Product p) => p.copyWith(
          media: _sortMedia(byProduct[p.id] ?? const <ProductMedia>[]),
        ),
      )
      .toList(growable: false);
}

List<ProductMedia> _sortMedia(List<ProductMedia> items) {
  final List<ProductMedia> sorted = <ProductMedia>[...items]
    ..sort((ProductMedia a, ProductMedia b) {
      if (a.isCover != b.isCover) return a.isCover ? -1 : 1;
      return a.sortOrder.compareTo(b.sortOrder);
    });
  return sorted;
}
