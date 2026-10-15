import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase access for `public.text_overrides`.
///
/// The pair `(text_key, locale)` is the table's primary key, which is also what
/// `.stream()` needs to push row updates to the editor and to every open
/// storefront.
class TextOverridesRemoteDataSource {
  TextOverridesRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String table = 'text_overrides';
  static const List<String> primaryKey = <String>['text_key', 'locale'];

  /// `key → value` for [locale], live.
  Stream<Map<String, String>> watch(String locale) => _client
      .from(table)
      .stream(primaryKey: primaryKey)
      .eq('locale', locale)
      .map(_toMap);

  Future<Map<String, String>> fetch(String locale) async {
    final List<Map<String, dynamic>> rows = await _client
        .from(table)
        .select('text_key, value')
        .eq('locale', locale);
    return _toMap(rows);
  }

  Future<List<Map<String, dynamic>>> fetchAll() =>
      _client.from(table).select('text_key, locale, value').order('text_key');

  Future<void> upsert(Map<String, dynamic> row) =>
      _client.from(table).upsert(row);

  Future<void> delete(String textKey, String locale) => _client
      .from(table)
      .delete()
      .eq('text_key', textKey)
      .eq('locale', locale);

  static Map<String, String> _toMap(List<Map<String, dynamic>> rows) =>
      <String, String>{
        for (final Map<String, dynamic> row in rows)
          if (row['text_key'] is String && row['value'] is String)
            row['text_key'] as String: row['value'] as String,
      };
}
