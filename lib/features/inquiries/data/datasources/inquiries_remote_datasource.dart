import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_logger.dart';

/// Raw access to the `inquiries` lead log.
///
/// Reads are admin-only (RLS). Writes happen two ways: the storefront posts to
/// the rate-limited Edge Function, and the admin clears rows from here.
class InquiriesRemoteDataSource {
  InquiriesRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String table = 'inquiries';

  /// Newest-first lead log with the product title resolved through the FK, so
  /// the admin list needs no second query.
  Future<List<Map<String, dynamic>>> fetch({int limit = 500}) async {
    final List<Map<String, dynamic>> rows = await _client
        .from(table)
        .select(
          'id, product_id, channel, device_id, created_at, products(title)',
        )
        .order('created_at', ascending: false)
        .limit(limit);
    return rows;
  }

  Stream<List<Map<String, dynamic>>> watch() => _client
      .from(table)
      .stream(primaryKey: const <String>['id'])
      .order('created_at', ascending: false);

  Future<void> remove(String id) => _client.from(table).delete().eq('id', id);

  /// Fire-and-forget lead logging.
  ///
  /// Never throws: the storefront must not surface a failure, and the redirect
  /// it is racing against must never be delayed. Rate limiting lives in the
  /// function (plus the `guard_inquiry_rate()` trigger as a second layer).
  Future<void> logInquiry({
    String? productId,
    required String channel,
    String? deviceId,
  }) async {
    try {
      await _client.functions.invoke(
        'inquiry',
        body: <String, dynamic>{
          if (productId != null) 'product_id': productId,
          'channel': channel,
          if (deviceId != null) 'device_id': deviceId,
        },
      );
    } on Object catch (error) {
      // Deliberately swallowed: an unlogged tap costs the owner nothing next
      // to a customer who saw an error instead of their WhatsApp opening. It is
      // still written to the log — without this line an undeployed or
      // misconfigured Edge Function looks exactly like a shop where nobody
      // taps a contact button, which is the one symptom the owner cannot
      // diagnose from the app.
      AppLog.warning('inquiry not logged (channel: $channel)', error);
    }
  }
}
