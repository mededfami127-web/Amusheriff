// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contactSettingsRemoteDataSource)
final contactSettingsRemoteDataSourceProvider =
    ContactSettingsRemoteDataSourceProvider._();

final class ContactSettingsRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ContactSettingsRemoteDataSource,
          ContactSettingsRemoteDataSource,
          ContactSettingsRemoteDataSource
        >
    with $Provider<ContactSettingsRemoteDataSource> {
  ContactSettingsRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactSettingsRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactSettingsRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ContactSettingsRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContactSettingsRemoteDataSource create(Ref ref) {
    return contactSettingsRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactSettingsRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactSettingsRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$contactSettingsRemoteDataSourceHash() =>
    r'e97526d1c8fd4acf00d708ae9a5815cfc84d116c';

@ProviderFor(contactSettingsRepository)
final contactSettingsRepositoryProvider = ContactSettingsRepositoryProvider._();

final class ContactSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          ContactSettingsRepository,
          ContactSettingsRepository,
          ContactSettingsRepository
        >
    with $Provider<ContactSettingsRepository> {
  ContactSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ContactSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContactSettingsRepository create(Ref ref) {
    return contactSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactSettingsRepository>(value),
    );
  }
}

String _$contactSettingsRepositoryHash() =>
    r'44a411c193f79625d3cf408b56e12bf2bbf567fa';

/// Live owner contact channels, empty until the owner fills the row.

@ProviderFor(contactSettings)
final contactSettingsProvider = ContactSettingsProvider._();

/// Live owner contact channels, empty until the owner fills the row.

final class ContactSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContactSettings>,
          ContactSettings,
          Stream<ContactSettings>
        >
    with $FutureModifier<ContactSettings>, $StreamProvider<ContactSettings> {
  /// Live owner contact channels, empty until the owner fills the row.
  ContactSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactSettingsHash();

  @$internal
  @override
  $StreamProviderElement<ContactSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ContactSettings> create(Ref ref) {
    return contactSettings(ref);
  }
}

String _$contactSettingsHash() => r'1000764d3721ad9c484e00e2b0f01ddd4705020c';

/// Synchronous view for screens that only need "which channels exist".

@ProviderFor(contactSettingsValue)
final contactSettingsValueProvider = ContactSettingsValueProvider._();

/// Synchronous view for screens that only need "which channels exist".

final class ContactSettingsValueProvider
    extends
        $FunctionalProvider<ContactSettings, ContactSettings, ContactSettings>
    with $Provider<ContactSettings> {
  /// Synchronous view for screens that only need "which channels exist".
  ContactSettingsValueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactSettingsValueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactSettingsValueHash();

  @$internal
  @override
  $ProviderElement<ContactSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContactSettings create(Ref ref) {
    return contactSettingsValue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactSettings>(value),
    );
  }
}

String _$contactSettingsValueHash() =>
    r'90f079d5861d927e1d92a6169d80d0117c12cf12';
