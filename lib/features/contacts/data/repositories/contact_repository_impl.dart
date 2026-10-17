import '../../../../core/errors/error_mapper.dart';
import '../../domain/drafts/contact_link_draft.dart';
import '../../domain/entities/contact_link.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contacts_remote_datasource.dart';

/// Supabase-backed [ContactRepository].
class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl(this._remote);

  final ContactsRemoteDataSource _remote;

  @override
  Stream<List<ContactLink>> watchVisible() =>
      _remote.watch(onlyVisible: true).map(_decodeList);

  @override
  Stream<List<ContactLink>> watchAll() =>
      _remote.watch(onlyVisible: false).map(_decodeList);

  @override
  Future<List<ContactLink>> fetchVisible() => ErrorMapper.guard(() async {
    final List<Map<String, dynamic>> rows = await _remote.fetch(
      onlyVisible: true,
    );
    return _decodeList(rows);
  });

  @override
  Future<ContactLink?> findById(String id) => ErrorMapper.guard(() async {
    final Map<String, dynamic>? row = await _remote.byId(id);
    return row == null ? null : ContactLink.fromJson(row);
  });

  @override
  Future<ContactLink> create(ContactLinkDraft draft) =>
      ErrorMapper.guard(() async {
        final Map<String, dynamic> row = await _remote.insert(draft.toInsert());
        return ContactLink.fromJson(row);
      });

  @override
  Future<ContactLink> update(String id, ContactLinkDraft draft) =>
      ErrorMapper.guard(() async {
        final Map<String, dynamic> row = await _remote.update(
          id,
          draft.toUpdate(),
        );
        return ContactLink.fromJson(row);
      });

  @override
  Future<void> delete(String id) => ErrorMapper.guard(() => _remote.delete(id));

  @override
  Future<void> setVisibility(String id, {required bool isVisible}) =>
      ErrorMapper.guard(
        () => _remote.patch(id, <String, dynamic>{'is_visible': isVisible}),
      );

  @override
  Future<void> setPrimary(String id, {required bool isPrimary}) =>
      ErrorMapper.guard(
        () => _remote.patch(id, <String, dynamic>{'is_primary': isPrimary}),
      );

  @override
  Future<void> reorder(List<String> orderedIds) =>
      ErrorMapper.guard(() => _remote.reorder(orderedIds));

  List<ContactLink> _decodeList(List<Map<String, dynamic>> rows) =>
      rows.map(ContactLink.fromJson).toList(growable: false);
}
