// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourites_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `bootstrap()` with the already-loaded store.

@ProviderFor(favouritesStore)
final favouritesStoreProvider = FavouritesStoreProvider._();

/// Overridden in `bootstrap()` with the already-loaded store.

final class FavouritesStoreProvider
    extends
        $FunctionalProvider<FavouritesStore, FavouritesStore, FavouritesStore>
    with $Provider<FavouritesStore> {
  /// Overridden in `bootstrap()` with the already-loaded store.
  FavouritesStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favouritesStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favouritesStoreHash();

  @$internal
  @override
  $ProviderElement<FavouritesStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FavouritesStore create(Ref ref) {
    return favouritesStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavouritesStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavouritesStore>(value),
    );
  }
}

String _$favouritesStoreHash() => r'2198fcc53b8aceb00eb2823eb88e6ec936efde77';

/// The set of favourited product ids.

@ProviderFor(Favourites)
final favouritesProvider = FavouritesProvider._();

/// The set of favourited product ids.
final class FavouritesProvider
    extends $NotifierProvider<Favourites, Set<String>> {
  /// The set of favourited product ids.
  FavouritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favouritesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favouritesHash();

  @$internal
  @override
  Favourites create() => Favourites();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$favouritesHash() => r'3ca2f34a00507ea011de5c1cbc4340c02a494afe';

/// The set of favourited product ids.

abstract class _$Favourites extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// `true` when the product is in the customer's list.

@ProviderFor(isFavourite)
final isFavouriteProvider = IsFavouriteFamily._();

/// `true` when the product is in the customer's list.

final class IsFavouriteProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// `true` when the product is in the customer's list.
  IsFavouriteProvider._({
    required IsFavouriteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isFavouriteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFavouriteHash();

  @override
  String toString() {
    return r'isFavouriteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isFavourite(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsFavouriteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFavouriteHash() => r'221fd5223f2ee9343fd018d3526d7e4ae1e399d6';

/// `true` when the product is in the customer's list.

final class IsFavouriteFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsFavouriteFamily._()
    : super(
        retry: null,
        name: r'isFavouriteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// `true` when the product is in the customer's list.

  IsFavouriteProvider call(String productId) =>
      IsFavouriteProvider._(argument: productId, from: this);

  @override
  String toString() => r'isFavouriteProvider';
}

/// The favourited pieces, resolved live from the catalogue stream.
///
/// Any admin edit — a new photo, a price change, an item going out of stock —
/// shows up on the favourites screen with no extra query.

@ProviderFor(favouriteProducts)
final favouriteProductsProvider = FavouriteProductsProvider._();

/// The favourited pieces, resolved live from the catalogue stream.
///
/// Any admin edit — a new photo, a price change, an item going out of stock —
/// shows up on the favourites screen with no extra query.

final class FavouriteProductsProvider
    extends $FunctionalProvider<List<Product>, List<Product>, List<Product>>
    with $Provider<List<Product>> {
  /// The favourited pieces, resolved live from the catalogue stream.
  ///
  /// Any admin edit — a new photo, a price change, an item going out of stock —
  /// shows up on the favourites screen with no extra query.
  FavouriteProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favouriteProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favouriteProductsHash();

  @$internal
  @override
  $ProviderElement<List<Product>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Product> create(Ref ref) {
    return favouriteProducts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Product> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Product>>(value),
    );
  }
}

String _$favouriteProductsHash() => r'1fce91c02bd03ba653e5c817c864b0064b0d5655';
