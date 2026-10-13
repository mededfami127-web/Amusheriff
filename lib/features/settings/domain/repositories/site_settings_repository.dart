import '../drafts/site_settings_draft.dart';
import '../entities/site_settings.dart';

/// Store name, tagline, about text, logo and default currency.
///
/// Publicly readable (so the storefront can render branding before sign-in)
/// and admin-writable.
abstract interface class SiteSettingsRepository {
  /// Live settings row. Emits [SiteSettings.fallback] when the row is missing.
  Stream<SiteSettings> watch();

  Future<SiteSettings?> fetch();

  Future<SiteSettings> save(SiteSettingsDraft draft);
}
