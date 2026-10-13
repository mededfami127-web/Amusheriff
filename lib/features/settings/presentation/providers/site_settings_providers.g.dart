// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(siteSettingsRepository)
final siteSettingsRepositoryProvider = SiteSettingsRepositoryProvider._();

final class SiteSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SiteSettingsRepository,
          SiteSettingsRepository,
          SiteSettingsRepository
        >
    with $Provider<SiteSettingsRepository> {
  SiteSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siteSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siteSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SiteSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SiteSettingsRepository create(Ref ref) {
    return siteSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SiteSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SiteSettingsRepository>(value),
    );
  }
}

String _$siteSettingsRepositoryHash() =>
    r'32b9497435b94a857c7a85374e70f6007f62f435';

/// Live branding. Falls back to compile-time defaults until the row arrives.

@ProviderFor(siteSettings)
final siteSettingsProvider = SiteSettingsProvider._();

/// Live branding. Falls back to compile-time defaults until the row arrives.

final class SiteSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SiteSettings>,
          SiteSettings,
          Stream<SiteSettings>
        >
    with $FutureModifier<SiteSettings>, $StreamProvider<SiteSettings> {
  /// Live branding. Falls back to compile-time defaults until the row arrives.
  SiteSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siteSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siteSettingsHash();

  @$internal
  @override
  $StreamProviderElement<SiteSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SiteSettings> create(Ref ref) {
    return siteSettings(ref);
  }
}

String _$siteSettingsHash() => r'c0bc7e34b1357f9ca42689857c1c6436f11dd259';

/// Convenience synchronous accessor for widgets that only need the name.

@ProviderFor(siteSettingsValue)
final siteSettingsValueProvider = SiteSettingsValueProvider._();

/// Convenience synchronous accessor for widgets that only need the name.

final class SiteSettingsValueProvider
    extends $FunctionalProvider<SiteSettings, SiteSettings, SiteSettings>
    with $Provider<SiteSettings> {
  /// Convenience synchronous accessor for widgets that only need the name.
  SiteSettingsValueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siteSettingsValueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siteSettingsValueHash();

  @$internal
  @override
  $ProviderElement<SiteSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SiteSettings create(Ref ref) {
    return siteSettingsValue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SiteSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SiteSettings>(value),
    );
  }
}

String _$siteSettingsValueHash() => r'b7cfda5c8705b7751438970e214a5e74270d256d';

@ProviderFor(preferencesStore)
final preferencesStoreProvider = PreferencesStoreProvider._();

final class PreferencesStoreProvider
    extends
        $FunctionalProvider<
          PreferencesStore,
          PreferencesStore,
          PreferencesStore
        >
    with $Provider<PreferencesStore> {
  PreferencesStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesStoreHash();

  @$internal
  @override
  $ProviderElement<PreferencesStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PreferencesStore create(Ref ref) {
    return preferencesStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferencesStore>(value),
    );
  }
}

String _$preferencesStoreHash() => r'ecee2f0b6f9c472d183e1725fa33022d5ccba80e';

/// Language + theme, driven by the local store loaded during bootstrap.

@ProviderFor(AppPreferences)
final appPreferencesProvider = AppPreferencesProvider._();

/// Language + theme, driven by the local store loaded during bootstrap.
final class AppPreferencesProvider
    extends $NotifierProvider<AppPreferences, AppPreferencesState> {
  /// Language + theme, driven by the local store loaded during bootstrap.
  AppPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appPreferencesHash();

  @$internal
  @override
  AppPreferences create() => AppPreferences();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppPreferencesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppPreferencesState>(value),
    );
  }
}

String _$appPreferencesHash() => r'9641dd7c81f91d59ecd5fb17c26009cdb2b63370';

/// Language + theme, driven by the local store loaded during bootstrap.

abstract class _$AppPreferences extends $Notifier<AppPreferencesState> {
  AppPreferencesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppPreferencesState, AppPreferencesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppPreferencesState, AppPreferencesState>,
              AppPreferencesState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
