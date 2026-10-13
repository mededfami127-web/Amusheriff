import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw Supabase access for `public.contact_links`.
class ContactsRemoteDataSource {
  ContactsRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String table = 'contact_links';

  Stream<List<Map<String, dynamic>>> watch({required bool onlyVisible}) {
    final SupabaseStreamFilterBuilder base =
        _client.from(table).stream(primaryKey: const <String>['id']);
    final SupabaseStreamBuilder filtered =
        onlyVisible ? base.eq('is_visible', true) : base;
    return filtered.order('sort_order', ascending: true);
  }

  Future<List<Map<String, dynamic>>> fetch({required bool onlyVisible}) async {
    PostgrestFilterBuilder<PostgrestList> query = _client.from(table).select();
    if (onlyVisible) query = query.eq('is_visible', true);
    // Primary first, then the owner's manual ordering.
    final List<Map<String, dynamic>> rows = await query
        .order('is_primary', ascending: false)
        .order('sort_order', ascending: true);
    return rows;
  }

  Future<Map<String, dynamic>?> byId(String id) =>
      _client.from(table).select().eq('id', id).maybeSingle();

  Future<Map<String, dynamic>> insert(Map<String, dynamic> row) async {
    final Map<String, dynamic> created =
        await _client.from(table).insert(row).select().single();
    return created;
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> row) async {
    final Map<String, dynamic> updated = await _client
        .from(table)
        .update(row)
        .eq('id', id)
        .select()
        .single();
    return updated;
  }

  Future<void> patch(String id, Map<String, dynamic> patch) =>
      _client.from(table).update(patch).eq('id', id);

  Future<void> delete(String id) => _client.from(table).delete().eq('id', id);

  Future<void> reorder(List<String> orderedIds) => _client.rpc<void>(
        'reorder_rows',
        params: <String, dynamic>{'p_table': table, 'p_ids': orderedIds},
      );
}
