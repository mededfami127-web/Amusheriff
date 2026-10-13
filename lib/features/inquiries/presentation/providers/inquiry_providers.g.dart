// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inquiriesRemoteDataSource)
final inquiriesRemoteDataSourceProvider = InquiriesRemoteDataSourceProvider._();

final class InquiriesRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          InquiriesRemoteDataSource,
          InquiriesRemoteDataSource,
          InquiriesRemoteDataSource
        >
    with $Provider<InquiriesRemoteDataSource> {
  InquiriesRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inquiriesRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inquiriesRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<InquiriesRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InquiriesRemoteDataSource create(Ref ref) {
    return inquiriesRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InquiriesRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InquiriesRemoteDataSource>(value),
    );
  }
}

String _$inquiriesRemoteDataSourceHash() =>
    r'ee9aa7647b7cd9e64a32997ba1262a759c77c451';

/// Overridden with a fake in tests.

@ProviderFor(inquiryRepository)
final inquiryRepositoryProvider = InquiryRepositoryProvider._();

/// Overridden with a fake in tests.

final class InquiryRepositoryProvider
    extends
        $FunctionalProvider<
          InquiryRepository,
          InquiryRepository,
          InquiryRepository
        >
    with $Provider<InquiryRepository> {
  /// Overridden with a fake in tests.
  InquiryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inquiryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inquiryRepositoryHash();

  @$internal
  @override
  $ProviderElement<InquiryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InquiryRepository create(Ref ref) {
    return inquiryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InquiryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InquiryRepository>(value),
    );
  }
}

String _$inquiryRepositoryHash() => r'4c67a5401612b99660e81bd56cc1dadb5f17ab36';

/// Live lead log. Reads only what RLS permits, which for anon is nothing.

@ProviderFor(adminInquiries)
final adminInquiriesProvider = AdminInquiriesProvider._();

/// Live lead log. Reads only what RLS permits, which for anon is nothing.

final class AdminInquiriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Inquiry>>,
          List<Inquiry>,
          Stream<List<Inquiry>>
        >
    with $FutureModifier<List<Inquiry>>, $StreamProvider<List<Inquiry>> {
  /// Live lead log. Reads only what RLS permits, which for anon is nothing.
  AdminInquiriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminInquiriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminInquiriesHash();

  @$internal
  @override
  $StreamProviderElement<List<Inquiry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Inquiry>> create(Ref ref) {
    return adminInquiries(ref);
  }
}

String _$adminInquiriesHash() => r'd138467453684e640798619f844b05caadf7afc6';

/// Leads recorded in the last seven days.

@ProviderFor(inquiriesThisWeek)
final inquiriesThisWeekProvider = InquiriesThisWeekProvider._();

/// Leads recorded in the last seven days.

final class InquiriesThisWeekProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Leads recorded in the last seven days.
  InquiriesThisWeekProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inquiriesThisWeekProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inquiriesThisWeekHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return inquiriesThisWeek(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$inquiriesThisWeekHash() => r'a06b450fa3833832abe44b098974538ed39c8e16';

/// How many times each product was contacted this week, most-tapped first.
///
/// Derived from the same stream the gateway already subscribes to, so the
/// "most contacted" list costs no extra round trip.

@ProviderFor(mostContactedProducts)
final mostContactedProductsProvider = MostContactedProductsProvider._();

/// How many times each product was contacted this week, most-tapped first.
///
/// Derived from the same stream the gateway already subscribes to, so the
/// "most contacted" list costs no extra round trip.

final class MostContactedProductsProvider
    extends
        $FunctionalProvider<
          List<MapEntry<String, int>>,
          List<MapEntry<String, int>>,
          List<MapEntry<String, int>>
        >
    with $Provider<List<MapEntry<String, int>>> {
  /// How many times each product was contacted this week, most-tapped first.
  ///
  /// Derived from the same stream the gateway already subscribes to, so the
  /// "most contacted" list costs no extra round trip.
  MostContactedProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mostContactedProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mostContactedProductsHash();

  @$internal
  @override
  $ProviderElement<List<MapEntry<String, int>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<MapEntry<String, int>> create(Ref ref) {
    return mostContactedProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MapEntry<String, int>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MapEntry<String, int>>>(value),
    );
  }
}

String _$mostContactedProductsHash() =>
    r'267913196e29e9fd0104db097c91de16c4c76705';
