import '../../../../core/errors/error_mapper.dart';
import '../../domain/drafts/catalog_drafts.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/catalog_repositories.dart';
import '../datasources/catalog_remote_datasource.dart';

/// Supabase-backed [CategoryRepository].
///
/// Every method funnels through [ErrorMapper.guard] so callers only ever see
/// the sealed `AppFailure` hierarchy.
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Stream<List<Category>> watchVisible() =>
      _remote.watchCategories(onlyVisible: true).map(_decodeList);

  @override
  Stream<List<Category>> watchAll() =>
      _remote.watchCategories(onlyVisible: false).map(_decodeList);

  @override
  Stream<List<Category>> watchVisibleRoots() => _remote
      .watchCategories(onlyVisible: true, rootsOnly: true)
      .map(_decodeList);

  @override
  Stream<List<Category>> watchVisibleChildren(String parentId) => _remote
      .watchCategories(onlyVisible: true, parentId: parentId)
      .map(_decodeList);

  @override
  Future<List<Category>> fetchVisible() => ErrorMapper.guard(() async {
    final List<Map<String, dynamic>> rows = await _remote.fetchCategories(
      onlyVisible: true,
    );
    return _decodeList(rows);
  });

  @override
  Future<Category?> findById(String id) => ErrorMapper.guard(() async {
    final Map<String, dynamic>? row = await _remote.categoryById(id);
    return row == null ? null : Category.fromJson(row);
  });

  @override
  Future<Category?> findBySlug(String slug) => ErrorMapper.guard(() async {
    final Map<String, dynamic>? row = await _remote.categoryBySlug(slug);
    return row == null ? null : Category.fromJson(row);
  });

  @override
  Future<Category> create(CategoryDraft draft) => ErrorMapper.guard(() async {
    final Map<String, dynamic> row = await _remote.insertCategory(
      draft.toInsert(),
    );
    return Category.fromJson(row);
  });

  @override
  Future<Category> update(String id, CategoryDraft draft) =>
      ErrorMapper.guard(() async {
        final Map<String, dynamic> row = await _remote.updateCategory(
          id,
          draft.toUpdate(),
        );
        return Category.fromJson(row);
      });

  @override
  Future<void> delete(String id) =>
      ErrorMapper.guard(() => _remote.deleteCategory(id));

  @override
  Future<void> setVisibility(String id, {required bool isVisible}) =>
      ErrorMapper.guard(
        () => _remote.updateCategory(id, <String, dynamic>{
          'is_visible': isVisible,
        }),
      );

  @override
  Future<void> reorder(List<String> orderedIds) => ErrorMapper.guard(
    () => _remote.reorderRows(
      CatalogRemoteDataSource.categoriesTable,
      orderedIds,
    ),
  );

  List<Category> _decodeList(List<Map<String, dynamic>> rows) =>
      rows.map(Category.fromJson).toList(growable: false);
}
