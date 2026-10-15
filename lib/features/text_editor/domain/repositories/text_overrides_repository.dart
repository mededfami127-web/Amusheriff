import '../entities/text_override.dart';

/// Owner-authored wording for the app's built-in strings.
///
/// Reads are public (the storefront is anonymous and must render the owner's
/// wording to everyone); writes are restricted to the owner by RLS.
abstract interface class TextOverridesRepository {
  /// Live map of `key → wording` for one locale. Emits an empty map when the
  /// owner has not rewritten anything yet.
  Stream<Map<String, String>> watch(String locale);

  /// One-shot read, used by the editor to seed a form and by tests.
  Future<Map<String, String>> fetch(String locale);

  /// Every override, all locales — the editor's "what has been changed" view.
  Future<List<TextOverride>> fetchAll();

  /// Creates or replaces the wording for one key.
  Future<void> save({
    required String textKey,
    required String locale,
    required String value,
  });

  /// Restores the shipped wording for one key by deleting the row.
  Future<void> remove({required String textKey, required String locale});
}
