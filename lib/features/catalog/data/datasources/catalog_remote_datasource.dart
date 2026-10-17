import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin, entity-agnostic wrapper over the four catalogue tables.
///
/// It returns raw `Map<String, dynamic>` rows so that JSON decoding, error
/// translation and business rules all live in the repository implementations.
/// It also knows nothing about RLS: the anonymous storefront and the admin
/// gateway hit the exact same methods, and Postgres decides what each may see.
class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String categoriesTable = 'categories';
  static const String productsTable = 'products';
  static const String mediaTable = 'product_media';

  /// Deadline on every write this datasource issues.
  ///
  /// A write with no deadline can hang on a half-open connection, and the editor
  /// that awaits it stays in its `saving` state — a Save button that is disabled
  /// and spinning forever, which reads as "the button does nothing". A visible
  /// `errorTimeout` is the better failure.
  static const Duration writeTimeout = Duration(seconds: 20);

  /// Columns shared by every product read, so the entity always decodes.
  static const String productColumns =
      'id, category_id, title, title_am, title_ar, description, '
      'description_am, description_ar, price, compare_at_price, currency_code, '
      'is_available, is_featured, is_published, sort_order, created_at, updated_at';

  // ── Categories ────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> watchCategories({
    required bool onlyVisible,
  }) {
    final SupabaseStreamFilterBuilder base = _client
        .from(categoriesTable)
        .stream(primaryKey: const <String>['id']);
    final SupabaseStreamBuilder filtered = onlyVisible
        ? base.eq('is_visible', true)
        : base;
    // `order` defaults to descending; the catalogue is always ascending.
    return filtered.order('sort_order', ascending: true);
  }

  Future<List<Map<String, dynamic>>> fetchCategories({
    required bool onlyVisible,
  }) async {
    PostgrestFilterBuilder<PostgrestList> query = _client
        .from(categoriesTable)
        .select();
    if (onlyVisible) query = query.eq('is_visible', true);
    final List<Map<String, dynamic>> rows = await query
        .order('sort_order', ascending: true)
        .order('name', ascending: true);
    return rows;
  }

  Future<Map<String, dynamic>?> categoryById(String id) =>
      _client.from(categoriesTable).select().eq('id', id).maybeSingle();

  Future<Map<String, dynamic>?> categoryBySlug(String slug) =>
      _client.from(categoriesTable).select().eq('slug', slug).maybeSingle();

  Future<Map<String, dynamic>> insertCategory(Map<String, dynamic> row) async {
    final Map<String, dynamic> created = await _client
        .from(categoriesTable)
        .insert(row)
        .select()
        .single()
        .timeout(writeTimeout);
    return created;
  }

  Future<Map<String, dynamic>> updateCategory(
    String id,
    Map<String, dynamic> row,
  ) async {
    final Map<String, dynamic> updated = await _client
        .from(categoriesTable)
        .update(row)
        .eq('id', id)
        .select()
        .single()
        .timeout(writeTimeout);
    return updated;
  }

  Future<void> deleteCategory(String id) =>
      _client.from(categoriesTable).delete().eq('id', id).timeout(writeTimeout);

  // ── Products ──────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> watchProducts({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  }) {
    SupabaseStreamFilterBuilder stream = _client
        .from(productsTable)
        .stream(primaryKey: const <String>['id']);
    if (onlyPublished) stream = stream.eq('is_published', true);
    if (onlyFeatured) stream = stream.eq('is_featured', true);
    if (categoryId != null) stream = stream.eq('category_id', categoryId);
    return stream.order('sort_order', ascending: true);
  }

  Future<List<Map<String, dynamic>>> fetchProducts({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  }) async {
    PostgrestFilterBuilder<PostgrestList> query = _client
        .from(productsTable)
        .select(productColumns);
    if (onlyPublished) query = query.eq('is_published', true);
    if (onlyFeatured) query = query.eq('is_featured', true);
    if (categoryId != null) query = query.eq('category_id', categoryId);
    final List<Map<String, dynamic>> rows = await query
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false);
    return rows;
  }

  /// Single product with its media embedded via the FK relationship.
  Future<Map<String, dynamic>?> productById(String id) => _client
      .from(productsTable)
      .select('$productColumns, product_media(*)')
      .eq('id', id)
      .maybeSingle();

  Stream<Map<String, dynamic>?> watchProduct(String id) => _client
      .from(productsTable)
      .stream(primaryKey: const <String>['id'])
      .eq('id', id)
      .map(
        (List<Map<String, dynamic>> rows) => rows.isEmpty ? null : rows.first,
      );

  /// Trigram search via the `search_products` RPC (index-backed, anon-safe).
  Future<List<Map<String, dynamic>>> searchProducts(
    String query, {
    int limit = 40,
  }) async {
    final dynamic result = await _client.rpc<dynamic>(
      'search_products',
      params: <String, dynamic>{'q': query, 'p_limit': limit},
    );
    return (result as List<dynamic>).cast<Map<String, dynamic>>().toList(
      growable: false,
    );
  }

  Future<Map<String, dynamic>> insertProduct(Map<String, dynamic> row) async {
    final Map<String, dynamic> created = await _client
        .from(productsTable)
        .insert(row)
        .select()
        .single()
        .timeout(writeTimeout);
    return created;
  }

  Future<Map<String, dynamic>> updateProduct(
    String id,
    Map<String, dynamic> row,
  ) async {
    final Map<String, dynamic> updated = await _client
        .from(productsTable)
        .update(row)
        .eq('id', id)
        .select()
        .single()
        .timeout(writeTimeout);
    return updated;
  }

  /// Partial update used by the toggles (publish / feature / availability).
  Future<void> patchProduct(String id, Map<String, dynamic> patch) => _client
      .from(productsTable)
      .update(patch)
      .eq('id', id)
      .timeout(writeTimeout);

  Future<void> deleteProduct(String id) =>
      _client.from(productsTable).delete().eq('id', id).timeout(writeTimeout);

  // ── Product media ─────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> watchAllMedia() => _client
      .from(mediaTable)
      .stream(primaryKey: const <String>['id'])
      .order('sort_order', ascending: true);

  Stream<List<Map<String, dynamic>>> watchMediaForProduct(String productId) =>
      _client
          .from(mediaTable)
          .stream(primaryKey: const <String>['id'])
          .eq('product_id', productId)
          .order('sort_order', ascending: true);

  Future<List<Map<String, dynamic>>> fetchMediaForProduct(
    String productId,
  ) async {
    final List<Map<String, dynamic>> rows = await _client
        .from(mediaTable)
        .select()
        .eq('product_id', productId)
        .order('sort_order', ascending: true);
    return rows;
  }

  Future<Map<String, dynamic>> insertMedia(Map<String, dynamic> row) async {
    final Map<String, dynamic> created = await _client
        .from(mediaTable)
        .insert(row)
        .select()
        .single()
        .timeout(writeTimeout);
    return created;
  }

  Future<Map<String, dynamic>> updateMedia(
    String id,
    Map<String, dynamic> row,
  ) async {
    final Map<String, dynamic> updated = await _client
        .from(mediaTable)
        .update(row)
        .eq('id', id)
        .select()
        .single()
        .timeout(writeTimeout);
    return updated;
  }

  Future<void> deleteMedia(String id) =>
      _client.from(mediaTable).delete().eq('id', id).timeout(writeTimeout);

  /// Clears the cover flag for a product. Required before setting a new cover,
  /// because `one_cover_per_product` is a *unique* partial index.
  Future<void> clearCover(String productId) => _client
      .from(mediaTable)
      .update(<String, dynamic>{'is_cover': false})
      .eq('product_id', productId)
      .timeout(writeTimeout);

  Future<void> setCover(String mediaId) => _client
      .from(mediaTable)
      .update(<String, dynamic>{'is_cover': true})
      .eq('id', mediaId)
      .timeout(writeTimeout);

  // ── Ordering ──────────────────────────────────────────────────────────────

  /// Persists a whole ordering in one transaction through the
  /// `reorder_rows` RPC (admin-only, whitelisted tables).
  Future<void> reorderRows(String table, List<String> orderedIds) => _client
      .rpc<void>(
        'reorder_rows',
        params: <String, dynamic>{'p_table': table, 'p_ids': orderedIds},
      )
      .timeout(writeTimeout);
}
