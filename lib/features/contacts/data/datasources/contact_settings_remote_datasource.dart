import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase access for the single-row `public.admin_contact_settings`.
class ContactSettingsRemoteDataSource {
  ContactSettingsRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String table = 'admin_contact_settings';
  static const int singletonId = 1;

  /// Live singleton row; an empty table emits nothing, which the repository
  /// maps to [ContactSettings.empty].
  Stream<Map<String, dynamic>> watch() => _client
      .from(table)
      .stream(primaryKey: const <String>['id'])
      .eq('id', singletonId)
      .map(
        (List<Map<String, dynamic>> rows) => rows.isEmpty ? _blank : rows.first,
      );

  Future<Map<String, dynamic>?> fetch() =>
      _client.from(table).select().eq('id', singletonId).maybeSingle();

  Future<void> upsert(Map<String, dynamic> row) =>
      _client.from(table).upsert(row);

  static const Map<String, dynamic> _blank = <String, dynamic>{'id': 1};
}
