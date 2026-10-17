import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/text_override.dart';
import '../../domain/repositories/text_overrides_repository.dart';
import '../datasources/text_overrides_remote_datasource.dart';

/// Supabase-backed [TextOverridesRepository].
///
/// Every failure funnels through [ErrorMapper.guard], so a denied write (a
/// signed-out owner, say) surfaces as a localised [AppFailure] instead of an
/// unhandled `PostgrestException`.
class TextOverridesRepositoryImpl implements TextOverridesRepository {
  TextOverridesRepositoryImpl(this._client)
    : _remote = TextOverridesRemoteDataSource(_client);

  final SupabaseClient _client;
  final TextOverridesRemoteDataSource _remote;

  @override
  Stream<Map<String, String>> watch(String locale) => _remote.watch(locale);

  @override
  Future<Map<String, String>> fetch(String locale) =>
      ErrorMapper.guard(() => _remote.fetch(locale));

  @override
  Future<List<TextOverride>> fetchAll() => ErrorMapper.guard(() async {
    final List<Map<String, dynamic>> rows = await _remote.fetchAll();
    return rows.map(TextOverride.fromJson).toList(growable: false);
  });

  @override
  Future<void> save({
    required String textKey,
    required String locale,
    required String value,
  }) => ErrorMapper.guard(() async {
    final TextOverride override = TextOverride(
      textKey: textKey,
      locale: locale,
      value: value,
    );
    // `updated_by` is an audit column; RLS never reads it, so a missing
    // session is not an error here.
    await _remote.upsert(override.toRow(_client.auth.currentUser?.id));
  });

  @override
  Future<void> remove({required String textKey, required String locale}) =>
      ErrorMapper.guard(() => _remote.delete(textKey, locale));
}
