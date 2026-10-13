import '../drafts/catalog_drafts.dart';
import '../entities/category.dart';
import '../entities/product.dart';
import '../entities/product_media.dart';

/// Category reads and writes.
///
/// **Wiring note:** the storefront consumes [watchVisible] (RLS lets anon read
/// only `is_visible` rows). The admin gateway consumes [watchAll] and the write
/// methods. Both resolve to the same Supabase table, so an admin edit is
/// immediately visible to every storefront client through Realtime.
abstract interface class CategoryRepository {
  /// Live visible categories, ordered by `sort_order`.
  Stream<List<Category>> watchVisible();

  /// Live categories including hidden ones. Admin only (RLS enforces it).
  Stream<List<Category>> watchAll();

  Future<List<Category>> fetchVisible();

  Future<Category?> findById(String id);

  Future<Category?> findBySlug(String slug);

  Future<Category> create(CategoryDraft draft);

  Future<Category> update(String id, CategoryDraft draft);

  Future<void> delete(String id);

  Future<void> setVisibility(String id, {required bool isVisible});

  /// Persists a new ordering in one round trip.
  Future<void> reorder(List<String> orderedIds);
}

/// Product reads and writes.
abstract interface class ProductRepository {
  /// Live products. Filters are applied in the query so Realtime only pushes
  /// rows the caller may see.
  Stream<List<Product>> watch({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  });

  /// Live single product, or `null` once deleted/unpublished.
  Stream<Product?> watchOne(String id);

  Future<List<Product>> fetch({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  });

  /// Single product with its media embedded (`product_media(*)`).
  Future<Product?> findById(String id);

  /// Trigram search through the `search_products` RPC.
  Future<List<Product>> search(String query, {int limit = 40});

  Future<Product> create(ProductDraft draft);

  Future<Product> update(String id, ProductDraft draft);

  Future<void> delete(String id);

  Future<void> setPublished(String id, {required bool isPublished});

  Future<void> setFeatured(String id, {required bool isFeatured});

  Future<void> setAvailability(String id, {required bool isAvailable});

  Future<void> reorder(List<String> orderedIds);
}

/// Product media reads and writes.
abstract interface class ProductMediaRepository {
  /// Live media for every product — combined in memory with [Product] rows so
  /// a newly uploaded photo lands on the storefront without a refetch.
  Stream<List<ProductMedia>> watchAll();

  Stream<List<ProductMedia>> watchForProduct(String productId);

  Future<List<ProductMedia>> fetchForProduct(String productId);

  Future<ProductMedia> add(ProductMediaDraft draft);

  Future<ProductMedia> update(String id, ProductMediaDraft draft);

  Future<void> delete(String id);

  /// Moves the `is_cover` flag to [mediaId] (the unique partial index makes
  /// this a single atomic update).
  Future<void> setCover(String productId, String mediaId);

  Future<void> reorder(List<String> orderedIds);
}
