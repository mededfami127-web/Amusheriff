import '../entities/inquiry.dart';

/// The anonymous lead log.
abstract interface class InquiryRepository {
  /// Newest-first lead log for the admin gateway (RLS enforces the role).
  Future<List<Inquiry>> fetchAll({int limit = 500});

  /// Live lead log, so the gateway updates as customers tap.
  Stream<List<Inquiry>> watchAll();

  Future<void> remove(String id);

  /// Records an anonymous contact tap through the rate-limited Edge Function.
  ///
  /// Callers must not await this on a critical path — it is deliberately
  /// fire-and-forget so it can never block the redirect the customer asked for.
  Future<void> log({
    String? productId,
    required String channel,
    String? deviceId,
  });
}
