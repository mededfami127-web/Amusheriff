import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/repositories/site_settings_repository_impl.dart';
import '../../domain/entities/site_settings.dart';
import '../../domain/repositories/site_settings_repository.dart';

part 'site_settings_providers.g.dart';

// ── Remote site settings ────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
SiteSettingsRepository siteSettingsRepository(Ref ref) =>
    SiteSettingsRepositoryImpl(ref.watch(supabaseClientProvider));

/// Live branding. Falls back to compile-time defaults until the row arrives.
@riverpod
Stream<SiteSettings> siteSettings(Ref ref) =>
    ref.watch(siteSettingsRepositoryProvider).watch();

/// Convenience synchronous accessor for widgets that only need the name.
@riverpod
SiteSettings siteSettingsValue(Ref ref) =>
    ref.watch(siteSettingsProvider).value ?? SiteSettings.fallback;

// ── Local preferences (language + theme) ────────────────────────────────────

/// Immutable snapshot of the user's local choices.
@immutable
class AppPreferencesState {
  const AppPreferencesState({required this.language, required this.themeMode});

  final AppLanguage language;
  final ThemeMode themeMode;

  /// The locale handed to `MaterialApp`, which also drives RTL.
  Locale get locale => Locale(language.code);

  AppPreferencesState copyWith({AppLanguage? language, ThemeMode? themeMode}) =>
      AppPreferencesState(
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
      );

  @override
  bool operator ==(Object other) =>
      other is AppPreferencesState &&
      other.language == language &&
      other.themeMode == themeMode;

  @override
  int get hashCode => Object.hash(language, themeMode);
}

/// Persists the language and theme choice on-device.
///
/// `flutter_secure_storage` is used rather than a plain preferences file so the
/// same store also holds the owner's session material — one encrypted store,
/// no extra dependency. Reads are cached so [AppPreferences.build] can be
/// synchronous and the first frame already has the right theme and locale.
class PreferencesStore {
  PreferencesStore(this._storage);

  final FlutterSecureStorage _storage;

  static const String _languageKey = 'asm.pref.language';
  static const String _themeKey = 'asm.pref.themeMode';

  AppPreferencesState _cached = const AppPreferencesState(
    language: AppLanguage.en,
    themeMode: ThemeMode.system,
  );

  /// Last loaded value. Safe to read synchronously from a provider.
  AppPreferencesState get current => _cached;

  /// Called once from `bootstrap()`. Never throws: an unreadable store simply
  /// falls back to device defaults.
  Future<AppPreferencesState> load(String deviceLanguageCode) async {
    try {
      final String? language = await _storage.read(key: _languageKey);
      final String? theme = await _storage.read(key: _themeKey);
      _cached = AppPreferencesState(
        language: language == null
            ? AppLanguage.fromDeviceLocale(deviceLanguageCode)
            : AppLanguage.fromCode(language),
        themeMode: _themeFromName(theme),
      );
    } catch (_) {
      _cached = AppPreferencesState(
        language: AppLanguage.fromDeviceLocale(deviceLanguageCode),
        themeMode: ThemeMode.system,
      );
    }
    return _cached;
  }

  Future<void> saveLanguage(AppLanguage language) async {
    _cached = _cached.copyWith(language: language);
    try {
      await _storage.write(key: _languageKey, value: language.code);
    } catch (_) {
      // Persisting is best-effort; the in-memory value still applies.
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    _cached = _cached.copyWith(themeMode: mode);
    try {
      await _storage.write(key: _themeKey, value: mode.name);
    } catch (_) {
      // Same as above.
    }
  }

  static ThemeMode _themeFromName(String? name) => switch (name) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

@Riverpod(keepAlive: true)
PreferencesStore preferencesStore(Ref ref) =>
    PreferencesStore(const FlutterSecureStorage());

/// Language + theme, driven by the local store loaded during bootstrap.
@Riverpod(keepAlive: true)
class AppPreferences extends _$AppPreferences {
  @override
  AppPreferencesState build() => ref.watch(preferencesStoreProvider).current;

  Future<void> setLanguage(AppLanguage language) async {
    final PreferencesStore store = ref.read(preferencesStoreProvider);
    await store.saveLanguage(language);
    state = store.current;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final PreferencesStore store = ref.read(preferencesStoreProvider);
    await store.saveThemeMode(mode);
    state = store.current;
  }

  /// Cycles system → light → dark → system, used by the settings sheet.
  Future<void> cycleThemeMode() => setThemeMode(switch (state.themeMode) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  });
}
