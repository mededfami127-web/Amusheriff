import '../entities/contact_settings.dart';

/// The owner's single row of contact channels.
///
/// Reads are public (the product page shows the published channels to every
/// visitor); writes are restricted to the admin by RLS.
abstract interface class ContactSettingsRepository {
  /// Live singleton row. Emits [ContactSettings.empty] before the row exists.
  Stream<ContactSettings> watch();

  /// One-shot read, used by tests and by a cold sheet.
  Future<ContactSettings> fetch();

  /// Creates or replaces the singleton row.
  Future<void> save(ContactSettings settings);
}
