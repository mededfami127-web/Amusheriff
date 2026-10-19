import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase access for `public.site_content`.
///
/// The pair `(key, locale)` is the table's primary key, which is also what
/// `.stream()` needs to push edits to the home screen and every open device.
class SiteContentDataSource {
  SiteContentDataSource(this._client);

  final SupabaseClient _client;

  static const String table = 'site_content';
  static const List<String> primaryKey = <String>['key', 'locale'];

  /// `key → value` for [locale], live.
  Stream<Map<String, String>> watch(String locale) => _client
      .from(table)
      .stream(primaryKey: primaryKey)
      .eq('locale', locale)
      .map(_toMap);

  Future<Map<String, String>> fetch(String locale) async {
    final List<Map<String, dynamic>> rows = await _client
        .from(table)
        .select('key, value')
        .eq('locale', locale);
    return _toMap(rows);
  }

  Future<Map<String, String>> fetchAll() async {
    final List<Map<String, dynamic>> rows = await _client
        .from(table)
        .select('key, locale, value')
        .order('locale');
    return _toMapAll(rows);
  }

  Future<void> upsert(Map<String, dynamic> row) =>
      _client.from(table).upsert(row);

  Future<void> delete(String key, String locale) =>
      _client.from(table).delete().eq('key', key).eq('locale', locale);

  static Map<String, String> _toMap(List<Map<String, dynamic>> rows) =>
      <String, String>{
        for (final Map<String, dynamic> row in rows)
          if (row['key'] is String && row['value'] is String)
            row['key'] as String: row['value'] as String,
      };

  static Map<String, String> _toMapAll(List<Map<String, dynamic>> rows) {
    final Map<String, String> map = <String, String>{};
    for (final Map<String, dynamic> row in rows) {
      final String? key = row['key'] as String?;
      final String? value = row['value'] as String?;
      if (key != null && value != null) {
        final String locale = row['locale'] as String? ?? '';
        map['$key|$locale'] = value;
      }
    }
    return map;
  }
}
