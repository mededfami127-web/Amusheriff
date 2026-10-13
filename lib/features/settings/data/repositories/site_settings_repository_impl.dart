import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/drafts/site_settings_draft.dart';
import '../../domain/entities/site_settings.dart';
import '../../domain/repositories/site_settings_repository.dart';

/// Supabase-backed [SiteSettingsRepository].
///
/// The table is constrained to a single row (`check (id = 1)`), so reads take
/// the first element and writes upsert on `id`.
class SiteSettingsRepositoryImpl implements SiteSettingsRepository {
  SiteSettingsRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const String table = 'site_settings';
  static const int singletonId = 1;

  @override
  Stream<SiteSettings> watch() => _client
      .from(table)
      .stream(primaryKey: const <String>['id'])
      .map(
        (List<Map<String, dynamic>> rows) => rows.isEmpty
            ? SiteSettings.fallback
            : SiteSettings.fromJson(rows.first),
      );

  @override
  Future<SiteSettings?> fetch() => ErrorMapper.guard(() async {
        final Map<String, dynamic>? row = await _client
            .from(table)
            .select()
            .eq('id', singletonId)
            .maybeSingle();
        return row == null ? null : SiteSettings.fromJson(row);
      });

  @override
  Future<SiteSettings> save(SiteSettingsDraft draft) =>
      ErrorMapper.guard(() async {
        final Map<String, dynamic> row = await _client
            .from(table)
            .upsert(<String, dynamic>{'id': singletonId, ...draft.toRow()})
            .select()
            .single();
        return SiteSettings.fromJson(row);
      });
}
