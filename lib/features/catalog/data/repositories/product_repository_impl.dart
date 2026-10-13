import '../../../../core/errors/error_mapper.dart';
import '../../domain/drafts/catalog_drafts.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_media.dart';
import '../../domain/repositories/catalog_repositories.dart';
import '../datasources/catalog_remote_datasource.dart';

/// Supabase-backed [ProductRepository].
///
/// Live reads use Realtime (`watch*`), so an admin edit lands on the storefront
/// without a restart. One-shot reads (`fetch*`) are used for pagination and
/// pull-to-refresh.
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Stream<List<Product>> watch({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  }) =>
      _remote
          .watchProducts(
            categoryId: categoryId,
            onlyPublished: onlyPublished,
            onlyFeatured: onlyFeatured,
          )
          .map(_decodeList);

  @override
  Stream<Product?> watchOne(String id) => _remote
      .watchProduct(id)
      .map((Map<String, dynamic>? row) =>
          row == null ? null : Product.fromJson(row));

  @override
  Future<List<Product>> fetch({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  }) =>
      ErrorMapper.guard(() async {
        final List<Map<String, dynamic>> rows = await _remote.fetchProducts(
          categoryId: categoryId,
          onlyPublished: onlyPublished,
          onlyFeatured: onlyFeatured,
        );
        return _decodeList(rows);
      });

  @override
  Future<Product?> findById(String id) => ErrorMapper.guard(() async {
        final Map<String, dynamic>? row = await _remote.productById(id);
        return row == null ? null : _decodeOne(row);
      });

  @override
  Future<List<Product>> search(String query, {int limit = 40}) =>
      ErrorMapper.guard(() async {
        final String trimmed = query.trim();
        if (trimmed.isEmpty) return const <Product>[];
        final List<Map<String, dynamic>> rows =
            await _remote.searchProducts(trimmed, limit: limit);
        return _decodeList(rows);
      });

  @override
  Future<Product> create(ProductDraft draft) => ErrorMapper.guard(() async {
        final Map<String, dynamic> row =
            await _remote.insertProduct(draft.toInsert());
        return Product.fromJson(row);
      });

  @override
  Future<Product> update(String id, ProductDraft draft) =>
      ErrorMapper.guard(() async {
        final Map<String, dynamic> row =
            await _remote.updateProduct(id, draft.toUpdate());
        return Product.fromJson(row);
      });

  @override
  Future<void> delete(String id) =>
      ErrorMapper.guard(() => _remote.deleteProduct(id));

  @override
  Future<void> setPublished(String id, {required bool isPublished}) =>
      ErrorMapper.guard(
        () => _remote.patchProduct(id, <String, dynamic>{
          'is_published': isPublished,
        }),
      );

  @override
  Future<void> setFeatured(String id, {required bool isFeatured}) =>
      ErrorMapper.guard(
        () => _remote.patchProduct(id, <String, dynamic>{
          'is_featured': isFeatured,
        }),
      );

  @override
  Future<void> setAvailability(String id, {required bool isAvailable}) =>
      ErrorMapper.guard(
        () => _remote.patchProduct(id, <String, dynamic>{
          'is_available': isAvailable,
        }),
      );

  @override
  Future<void> reorder(List<String> orderedIds) => ErrorMapper.guard(
        () => _remote.reorderRows(
          CatalogRemoteDataSource.productsTable,
          orderedIds,
        ),
      );

  List<Product> _decodeList(List<Map<String, dynamic>> rows) =>
      rows.map(Product.fromJson).toList(growable: false);

  Product _decodeOne(Map<String, dynamic> row) {
    final Product product = Product.fromJson(row);
    if (product.media.length < 2) return product;
    // PostgREST does not guarantee ordering of an embedded collection.
    final List<ProductMedia> sorted = <ProductMedia>[...product.media]
      ..sort((ProductMedia a, ProductMedia b) {
        if (a.isCover != b.isCover) return a.isCover ? -1 : 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    return product.copyWith(media: sorted);
  }
}
