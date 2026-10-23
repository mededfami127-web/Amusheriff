import 'dart:async';
import 'dart:io' show HttpException, SocketException;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/app_logger.dart';

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

  /// Runs one write, logging the real PostgREST error before rethrowing it.
  ///
  /// A denied save reaches the owner as the localised `PermissionFailure`,
  /// which deliberately names no table. This is the other half of that
  /// message: operation, table, SQLSTATE, error text, the columns actually
  /// sent, and whether a JWT was attached. `42501` is a policy denial,
  /// `PGRST301` a missing/expired token, `23505`/`23514` a constraint — three
  /// different fixes that otherwise all read "You do not have permission to do
  /// that." on screen.
  Future<T> _write<T>({
    required String operation,
    required String table,
    required Future<T> Function() body,
    Map<String, dynamic>? row,
    String? id,
  }) async {
    final Session? session = _client.auth.currentSession;
    if (session == null) {
      // With no session there is no `Authorization: Bearer`, so Postgres sees
      // `auth.uid()` as NULL, `public.is_admin()` as false, and answers 42501
      // for every admin write. Naming that here saves a round trip and the
      // three hours of guessing a generic banner causes.
      AppLog.error(
        'WRITE BLOCKED op=$operation table=public.$table: no Supabase session '
        '(auth.uid() will be NULL, is_admin() false, policies answer 42501)',
      );
      throw PermissionFailure(
        messageKey: 'errorNotSignedIn',
        debugMessage:
            'no session for $operation on public.$table '
            '(columns: ${(row?.keys ?? const <String>[]).join(', ')})',
      );
    }

    try {
      return await body();
    } on PostgrestException catch (error) {
      AppLog.error(
        'WRITE FAILED op=$operation table=public.$table id=${id ?? '-'} '
        'sqlstate=${error.code ?? '-'} message="${error.message}" '
        'details=${error.details ?? '-'} hint=${error.hint ?? '-'} '
        'uid=${session.user.id} columns=[${(row?.keys ?? const <String>[]).join(',')}]',
        error,
      );
      rethrow;
    }
  }

  /// One-shot reads get a deadline and a short backoff.
  ///
  /// A Realtime stream reconnects on its own; a `Future` does not. Without
  /// this a dropped packet left a detail page spinning until the OS gave up,
  /// and a `select` that failed once showed an error the customer could only
  /// clear by reopening the screen. Three attempts, 300 ms then 900 ms, only
  /// for transport errors — a policy denial must never be retried.
  static const Duration readTimeout = Duration(seconds: 15);

  Future<T> _read<T>(Future<T> Function() body) async {
    const List<Duration> backoff = <Duration>[
      Duration.zero,
      Duration(milliseconds: 300),
      Duration(milliseconds: 900),
    ];
    Object? lastError;
    StackTrace? lastStack;
    for (int attempt = 0; attempt < backoff.length; attempt++) {
      if (backoff[attempt] > Duration.zero) {
        await Future<void>.delayed(backoff[attempt]);
      }
      try {
        return await body().timeout(readTimeout);
      } on Object catch (error, stack) {
        lastError = error;
        lastStack = stack;
        if (error is! SocketException &&
            error is! TimeoutException &&
            error is! HttpException) {
          rethrow;
        }
      }
    }
    Error.throwWithStackTrace(lastError!, lastStack!);
  }

  /// Columns shared by every product read, so the entity always decodes.
  static const String productColumns =
      'id, category_id, title, title_am, title_ar, title_om, description, '
      'description_am, description_ar, description_om, price, compare_at_price, '
      'currency_code, is_available, is_featured, is_published, sort_order, '
      'created_at, updated_at';

  /// Every column [Category.fromJson] reads, and nothing else.
  static const String categoryColumns =
      'id, name, name_am, name_ar, name_om, slug, cover_path, parent_id, '
      'sort_order, is_visible, created_at, updated_at';

  /// Every column [ProductMedia.fromJson] reads.
  static const String mediaColumns =
      'id, product_id, kind, storage_path, thumbnail_path, duration_seconds, '
      'is_cover, sort_order, created_at';

  // ── Categories ────────────────────────────────────────────────────────────

  /// Live categories.
  ///
  /// [rootsOnly] keeps the top-level rows (`parent_id is null`), [parentId]
  /// keeps one mother's children. Both filters run in the query — over
  /// Realtime, so the answer stays live — instead of every widget sifting a
  /// full list it should never have been handed.
  Stream<List<Map<String, dynamic>>> watchCategories({
    required bool onlyVisible,
    bool rootsOnly = false,
    String? parentId,
  }) {
    SupabaseStreamFilterBuilder filtered = _client
        .from(categoriesTable)
        .stream(primaryKey: const <String>['id']);
    if (onlyVisible) {
      filtered = filtered.eq('is_visible', true);
    }
    if (rootsOnly) {
      filtered = filtered.isFilter('parent_id', null);
    } else if (parentId != null) {
      filtered = filtered.eq('parent_id', parentId);
    }
    // `order` defaults to descending; the catalogue is always ascending.
    return filtered.order('sort_order', ascending: true);
  }

  Future<List<Map<String, dynamic>>> fetchCategories({
    required bool onlyVisible,
    bool rootsOnly = false,
    String? parentId,
  }) => _read(() async {
    PostgrestFilterBuilder<PostgrestList> query = _client
        .from(categoriesTable)
        .select(categoryColumns);
    if (onlyVisible) query = query.eq('is_visible', true);
    if (rootsOnly) {
      query = query.isFilter('parent_id', null);
    } else if (parentId != null) {
      query = query.eq('parent_id', parentId);
    }
    final List<Map<String, dynamic>> rows = await query
        .order('sort_order', ascending: true)
        .order('name', ascending: true);
    return rows;
  });

  Future<Map<String, dynamic>?> categoryById(String id) => _read(
    () => _client
        .from(categoriesTable)
        .select(categoryColumns)
        .eq('id', id)
        .maybeSingle(),
  );

  Future<Map<String, dynamic>?> categoryBySlug(String slug) => _read(
    () => _client
        .from(categoriesTable)
        .select(categoryColumns)
        .eq('slug', slug)
        .maybeSingle(),
  );

  Future<Map<String, dynamic>> insertCategory(Map<String, dynamic> row) =>
      _write<Map<String, dynamic>>(
        operation: 'insert',
        table: categoriesTable,
        row: row,
        body: () => _client
            .from(categoriesTable)
            .insert(row)
            .select()
            .single()
            .timeout(writeTimeout),
      );

  Future<Map<String, dynamic>> updateCategory(
    String id,
    Map<String, dynamic> row,
  ) => _write<Map<String, dynamic>>(
    operation: 'update',
    table: categoriesTable,
    row: row,
    id: id,
    body: () => _client
        .from(categoriesTable)
        .update(row)
        .eq('id', id)
        .select()
        .single()
        .timeout(writeTimeout),
  );

  Future<void> deleteCategory(String id) => _write<void>(
    operation: 'delete',
    table: categoriesTable,
    id: id,
    body: () async {
      await _client
          .from(categoriesTable)
          .delete()
          .eq('id', id)
          .timeout(writeTimeout);
    },
  );

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
  }) => _read(() async {
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
  });

  /// Single product with its media embedded via the FK relationship.
  Future<Map<String, dynamic>?> productById(String id) => _read(
    () => _client
        .from(productsTable)
        .select('$productColumns, product_media($mediaColumns)')
        .eq('id', id)
        .maybeSingle(),
  );

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
  }) => _read(() async {
    final dynamic result = await _client.rpc<dynamic>(
      'search_products',
      params: <String, dynamic>{'q': query, 'p_limit': limit},
    );
    return (result as List<dynamic>).cast<Map<String, dynamic>>().toList(
      growable: false,
    );
  });

  Future<Map<String, dynamic>> insertProduct(Map<String, dynamic> row) =>
      _write<Map<String, dynamic>>(
        operation: 'insert',
        table: productsTable,
        row: row,
        body: () => _client
            .from(productsTable)
            .insert(row)
            .select()
            .single()
            .timeout(writeTimeout),
      );

  Future<Map<String, dynamic>> updateProduct(
    String id,
    Map<String, dynamic> row,
  ) => _write<Map<String, dynamic>>(
    operation: 'update',
    table: productsTable,
    row: row,
    id: id,
    body: () => _client
        .from(productsTable)
        .update(row)
        .eq('id', id)
        .select()
        .single()
        .timeout(writeTimeout),
  );

  /// Partial update used by the toggles (publish / feature / availability).
  Future<void> patchProduct(String id, Map<String, dynamic> patch) =>
      _write<void>(
        operation: 'patch',
        table: productsTable,
        row: patch,
        id: id,
        body: () async {
          await _client
              .from(productsTable)
              .update(patch)
              .eq('id', id)
              .timeout(writeTimeout);
        },
      );

  Future<void> deleteProduct(String id) => _write<void>(
    operation: 'delete',
    table: productsTable,
    id: id,
    body: () async {
      await _client
          .from(productsTable)
          .delete()
          .eq('id', id)
          .timeout(writeTimeout);
    },
  );

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

  Future<List<Map<String, dynamic>>> fetchMediaForProduct(String productId) =>
      _read(
        () => _client
            .from(mediaTable)
            .select(mediaColumns)
            .eq('product_id', productId)
            .order('sort_order', ascending: true),
      );

  Future<Map<String, dynamic>> insertMedia(Map<String, dynamic> row) =>
      _write<Map<String, dynamic>>(
        operation: 'insert',
        table: mediaTable,
        row: row,
        body: () => _client
            .from(mediaTable)
            .insert(row)
            .select()
            .single()
            .timeout(writeTimeout),
      );

  Future<Map<String, dynamic>> updateMedia(
    String id,
    Map<String, dynamic> row,
  ) => _write<Map<String, dynamic>>(
    operation: 'update',
    table: mediaTable,
    row: row,
    id: id,
    body: () => _client
        .from(mediaTable)
        .update(row)
        .eq('id', id)
        .select()
        .single()
        .timeout(writeTimeout),
  );

  Future<void> deleteMedia(String id) => _write<void>(
    operation: 'delete',
    table: mediaTable,
    id: id,
    body: () async {
      await _client
          .from(mediaTable)
          .delete()
          .eq('id', id)
          .timeout(writeTimeout);
    },
  );

  /// Clears the cover flag for a product. Required before setting a new cover,
  /// because `one_cover_per_product` is a *unique* partial index.
  Future<void> clearCover(String productId) => _write<void>(
    operation: 'update',
    table: mediaTable,
    row: const <String, dynamic>{'is_cover': false},
    id: productId,
    body: () async {
      await _client
          .from(mediaTable)
          .update(<String, dynamic>{'is_cover': false})
          .eq('product_id', productId)
          .timeout(writeTimeout);
    },
  );

  Future<void> setCover(String mediaId) => _write<void>(
    operation: 'update',
    table: mediaTable,
    row: const <String, dynamic>{'is_cover': true},
    id: mediaId,
    body: () async {
      await _client
          .from(mediaTable)
          .update(<String, dynamic>{'is_cover': true})
          .eq('id', mediaId)
          .timeout(writeTimeout);
    },
  );

  // ── Ordering ──────────────────────────────────────────────────────────────

  /// Persists a whole ordering in one transaction through the
  /// `reorder_rows` RPC (admin-only, whitelisted tables).
  Future<void> reorderRows(String table, List<String> orderedIds) =>
      _write<void>(
        operation: 'rpc.reorder_rows',
        table: table,
        row: <String, dynamic>{'p_ids': orderedIds},
        body: () async {
          await _client
              .rpc<void>(
                'reorder_rows',
                params: <String, dynamic>{
                  'p_table': table,
                  'p_ids': orderedIds,
                },
              )
              .timeout(writeTimeout);
        },
      );
}
