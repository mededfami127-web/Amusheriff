// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storefront_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The live search box value.
///
/// Held in a provider rather than `setState` so the results provider can
/// `watch` it and the debounce lives in one place.

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

/// The live search box value.
///
/// Held in a provider rather than `setState` so the results provider can
/// `watch` it and the debounce lives in one place.
final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  /// The live search box value.
  ///
  /// Held in a provider rather than `setState` so the results provider can
  /// `watch` it and the debounce lives in one place.
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'c2b6cc4348c8cc0bb62cb1c2312aee262de6eda9';

/// The live search box value.
///
/// Held in a provider rather than `setState` so the results provider can
/// `watch` it and the debounce lives in one place.

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Which gallery item the product page is showing.

@ProviderFor(GalleryIndex)
final galleryIndexProvider = GalleryIndexProvider._();

/// Which gallery item the product page is showing.
final class GalleryIndexProvider extends $NotifierProvider<GalleryIndex, int> {
  /// Which gallery item the product page is showing.
  GalleryIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'galleryIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryIndexHash();

  @$internal
  @override
  GalleryIndex create() => GalleryIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$galleryIndexHash() => r'5b56219e7c46468730e427b43983496e3862e68e';

/// Which gallery item the product page is showing.

abstract class _$GalleryIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
