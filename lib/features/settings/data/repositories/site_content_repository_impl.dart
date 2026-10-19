import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/site_content_entry.dart';
import '../../domain/repositories/site_content_repository.dart';
import '../datasources/site_content_datasource.dart';

/// Supabase-backed [SiteContentRepository].
///
/// Reads are public (the storefront is anonymous); writes are admin-only by
/// RLS, never by this class.
class SiteContentRepositoryImpl implements SiteContentRepository {
  SiteContentRepositoryImpl(this._client)
    : _remote = SiteContentDataSource(_client);

  final SupabaseClient _client;
  final SiteContentDataSource _remote;

  @override
  Stream<Map<String, String>> watch(String locale) => _remote.watch(locale);

  @override
  Future<Map<String, String>> fetch(String locale) =>
      ErrorMapper.guard(() => _remote.fetch(locale));

  @override
  Future<Map<String, String>> fetchAll() =>
      ErrorMapper.guard(() => _remote.fetchAll());

  @override
  Future<void> save({
    required String key,
    required String locale,
    required String value,
  }) => ErrorMapper.guard(() async {
    final SiteContentEntry entry = SiteContentEntry(
      key: key,
      locale: locale,
      value: value,
    );
    await _remote.upsert(entry.toRow(_client.auth.currentUser?.id));
  });

  @override
  Future<void> remove({required String key, required String locale}) =>
      ErrorMapper.guard(() => _remote.delete(key, locale));
}
