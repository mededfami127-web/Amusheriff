import '../entities/site_content_entry.dart';

/// Live-editable home copy: one row per (key, locale).
///
/// Reads are public (the storefront is anonymous and must render the owner's
/// wording to everyone); writes are restricted to the owner by RLS.
abstract interface class SiteContentRepository {
  /// Live map of `key → value` for one locale. Emits an empty map when the
  /// owner has not rewritten a key yet.
  Stream<Map<String, String>> watch(String locale);

  /// One-shot read, used by the editor to seed a form and by tests.
  Future<Map<String, String>> fetch(String locale);

  /// Every stored key across locales, for the editor's "what has been changed"
  /// view.
  Future<Map<String, String>> fetchAll();

  /// Creates or replaces the wording for one key in one locale.
  Future<void> save({
    required String key,
    required String locale,
    required String value,
  });

  /// Restores the shipped wording for one key by deleting the row.
  Future<void> remove({required String key, required String locale});
}
