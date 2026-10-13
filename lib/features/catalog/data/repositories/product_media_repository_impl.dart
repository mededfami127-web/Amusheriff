import '../../../../core/errors/error_mapper.dart';
import '../../domain/drafts/catalog_drafts.dart';
import '../../domain/entities/product_media.dart';
import '../../domain/repositories/catalog_repositories.dart';
import '../datasources/catalog_remote_datasource.dart';

/// Supabase-backed [ProductMediaRepository].
class ProductMediaRepositoryImpl implements ProductMediaRepository {
  ProductMediaRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Stream<List<ProductMedia>> watchAll() =>
      _remote.watchAllMedia().map(_decodeList);

  @override
  Stream<List<ProductMedia>> watchForProduct(String productId) =>
      _remote.watchMediaForProduct(productId).map(_decodeList);

  @override
  Future<List<ProductMedia>> fetchForProduct(String productId) =>
      ErrorMapper.guard(() async {
        final List<Map<String, dynamic>> rows =
            await _remote.fetchMediaForProduct(productId);
        return _decodeList(rows);
      });

  @override
  Future<ProductMedia> add(ProductMediaDraft draft) =>
      ErrorMapper.guard(() async {
        final Map<String, dynamic> row =
            await _remote.insertMedia(draft.toInsert());
        return ProductMedia.fromJson(row);
      });

  @override
  Future<ProductMedia> update(String id, ProductMediaDraft draft) =>
      ErrorMapper.guard(() async {
        final Map<String, dynamic> row =
            await _remote.updateMedia(id, draft.toUpdate());
        return ProductMedia.fromJson(row);
      });

  @override
  Future<void> delete(String id) =>
      ErrorMapper.guard(() => _remote.deleteMedia(id));

  /// `one_cover_per_product` is a unique partial index, so the old cover must
  /// be cleared before the new one is set. Both writes happen inside one guard
  /// so a failure surfaces as a single [AppFailure].
  @override
  Future<void> setCover(String productId, String mediaId) =>
      ErrorMapper.guard(() async {
        await _remote.clearCover(productId);
        await _remote.setCover(mediaId);
      });

  @override
  Future<void> reorder(List<String> orderedIds) => ErrorMapper.guard(
        () => _remote.reorderRows(
          CatalogRemoteDataSource.mediaTable,
          orderedIds,
        ),
      );

  List<ProductMedia> _decodeList(List<Map<String, dynamic>> rows) =>
      rows.map(ProductMedia.fromJson).toList(growable: false);
}
