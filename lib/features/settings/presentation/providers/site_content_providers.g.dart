// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_content_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(siteContentRepository)
final siteContentRepositoryProvider = SiteContentRepositoryProvider._();

final class SiteContentRepositoryProvider
    extends
        $FunctionalProvider<
          SiteContentRepository,
          SiteContentRepository,
          SiteContentRepository
        >
    with $Provider<SiteContentRepository> {
  SiteContentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siteContentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siteContentRepositoryHash();

  @$internal
  @override
  $ProviderElement<SiteContentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SiteContentRepository create(Ref ref) {
    return siteContentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SiteContentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SiteContentRepository>(value),
    );
  }
}

String _$siteContentRepositoryHash() =>
    r'd47c147f03b8faf54cc7492fd63ec193be57f6c1';

/// Live home copy for one locale: `key → value`.

@ProviderFor(siteContent)
final siteContentProvider = SiteContentFamily._();

/// Live home copy for one locale: `key → value`.

final class SiteContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          Stream<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $StreamProvider<Map<String, String>> {
  /// Live home copy for one locale: `key → value`.
  SiteContentProvider._({
    required SiteContentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siteContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteContentHash();

  @override
  String toString() {
    return r'siteContentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, String>> create(Ref ref) {
    final argument = this.argument as String;
    return siteContent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SiteContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteContentHash() => r'330e68854c0421c740c9d709909bc73866261965';

/// Live home copy for one locale: `key → value`.

final class SiteContentFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, String>>, String> {
  SiteContentFamily._()
    : super(
        retry: null,
        name: r'siteContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live home copy for one locale: `key → value`.

  SiteContentProvider call(String locale) =>
      SiteContentProvider._(argument: locale, from: this);

  @override
  String toString() => r'siteContentProvider';
}

/// Synchronous view of [siteContent], for widgets that want one value with
/// ARB fallback instead of a stream.

@ProviderFor(siteContentValue)
final siteContentValueProvider = SiteContentValueFamily._();

/// Synchronous view of [siteContent], for widgets that want one value with
/// ARB fallback instead of a stream.

final class SiteContentValueProvider
    extends
        $FunctionalProvider<
          Map<String, String>,
          Map<String, String>,
          Map<String, String>
        >
    with $Provider<Map<String, String>> {
  /// Synchronous view of [siteContent], for widgets that want one value with
  /// ARB fallback instead of a stream.
  SiteContentValueProvider._({
    required SiteContentValueFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siteContentValueProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteContentValueHash();

  @override
  String toString() {
    return r'siteContentValueProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, String> create(Ref ref) {
    final argument = this.argument as String;
    return siteContentValue(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SiteContentValueProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteContentValueHash() => r'4d55099c35ba0c6508ea216c790cf3d87f248564';

/// Synchronous view of [siteContent], for widgets that want one value with
/// ARB fallback instead of a stream.

final class SiteContentValueFamily extends $Family
    with $FunctionalFamilyOverride<Map<String, String>, String> {
  SiteContentValueFamily._()
    : super(
        retry: null,
        name: r'siteContentValueProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Synchronous view of [siteContent], for widgets that want one value with
  /// ARB fallback instead of a stream.

  SiteContentValueProvider call(String locale) =>
      SiteContentValueProvider._(argument: locale, from: this);

  @override
  String toString() => r'siteContentValueProvider';
}

/// The keys the owner has rewritten in [locale].

@ProviderFor(siteContentKeys)
final siteContentKeysProvider = SiteContentKeysFamily._();

/// The keys the owner has rewritten in [locale].

final class SiteContentKeysProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  /// The keys the owner has rewritten in [locale].
  SiteContentKeysProvider._({
    required SiteContentKeysFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'siteContentKeysProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteContentKeysHash();

  @override
  String toString() {
    return r'siteContentKeysProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Set<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<String> create(Ref ref) {
    final argument = this.argument as String;
    return siteContentKeys(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SiteContentKeysProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteContentKeysHash() => r'6f03b66bf58d9fb989fe5e4da13879785b8b38f1';

/// The keys the owner has rewritten in [locale].

final class SiteContentKeysFamily extends $Family
    with $FunctionalFamilyOverride<Set<String>, String> {
  SiteContentKeysFamily._()
    : super(
        retry: null,
        name: r'siteContentKeysProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The keys the owner has rewritten in [locale].

  SiteContentKeysProvider call(String locale) =>
      SiteContentKeysProvider._(argument: locale, from: this);

  @override
  String toString() => r'siteContentKeysProvider';
}
