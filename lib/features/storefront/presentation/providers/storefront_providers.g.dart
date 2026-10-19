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

/// The same query, but only after the typist has paused.
///
/// 350 ms is the difference between a trigram query per keystroke and one per
/// word. Switching the query also disposes the previous `searchProducts`
/// future, so a slow answer for "so" can never overwrite the answer for
/// "sofa" — that is the stale-response race, closed at the provider level.

@ProviderFor(DebouncedSearchQuery)
final debouncedSearchQueryProvider = DebouncedSearchQueryProvider._();

/// The same query, but only after the typist has paused.
///
/// 350 ms is the difference between a trigram query per keystroke and one per
/// word. Switching the query also disposes the previous `searchProducts`
/// future, so a slow answer for "so" can never overwrite the answer for
/// "sofa" — that is the stale-response race, closed at the provider level.
final class DebouncedSearchQueryProvider
    extends $NotifierProvider<DebouncedSearchQuery, String> {
  /// The same query, but only after the typist has paused.
  ///
  /// 350 ms is the difference between a trigram query per keystroke and one per
  /// word. Switching the query also disposes the previous `searchProducts`
  /// future, so a slow answer for "so" can never overwrite the answer for
  /// "sofa" — that is the stale-response race, closed at the provider level.
  DebouncedSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debouncedSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debouncedSearchQueryHash();

  @$internal
  @override
  DebouncedSearchQuery create() => DebouncedSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$debouncedSearchQueryHash() =>
    r'99cf39aa2c175da7aa0438f8268e68f0b66a49c6';

/// The same query, but only after the typist has paused.
///
/// 350 ms is the difference between a trigram query per keystroke and one per
/// word. Switching the query also disposes the previous `searchProducts`
/// future, so a slow answer for "so" can never overwrite the answer for
/// "sofa" — that is the stale-response race, closed at the provider level.

abstract class _$DebouncedSearchQuery extends $Notifier<String> {
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

/// How many list items one page shows. `more()` is the "load more" action;
/// a screen keeps its own counter by passing a scope key (home, a category
/// slug), so opening a category does not disturb the home page's page.

@ProviderFor(VisibleCount)
final visibleCountProvider = VisibleCountFamily._();

/// How many list items one page shows. `more()` is the "load more" action;
/// a screen keeps its own counter by passing a scope key (home, a category
/// slug), so opening a category does not disturb the home page's page.
final class VisibleCountProvider extends $NotifierProvider<VisibleCount, int> {
  /// How many list items one page shows. `more()` is the "load more" action;
  /// a screen keeps its own counter by passing a scope key (home, a category
  /// slug), so opening a category does not disturb the home page's page.
  VisibleCountProvider._({
    required VisibleCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'visibleCountProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$visibleCountHash();

  @override
  String toString() {
    return r'visibleCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VisibleCount create() => VisibleCount();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VisibleCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$visibleCountHash() => r'c335a456a09ea855ea67c54eddb60b089d5001e5';

/// How many list items one page shows. `more()` is the "load more" action;
/// a screen keeps its own counter by passing a scope key (home, a category
/// slug), so opening a category does not disturb the home page's page.

final class VisibleCountFamily extends $Family
    with $ClassFamilyOverride<VisibleCount, int, int, int, String> {
  VisibleCountFamily._()
    : super(
        retry: null,
        name: r'visibleCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// How many list items one page shows. `more()` is the "load more" action;
  /// a screen keeps its own counter by passing a scope key (home, a category
  /// slug), so opening a category does not disturb the home page's page.

  VisibleCountProvider call(String scope) =>
      VisibleCountProvider._(argument: scope, from: this);

  @override
  String toString() => r'visibleCountProvider';
}

/// How many list items one page shows. `more()` is the "load more" action;
/// a screen keeps its own counter by passing a scope key (home, a category
/// slug), so opening a category does not disturb the home page's page.

abstract class _$VisibleCount extends $Notifier<int> {
  late final _$args = ref.$arg as String;
  String get scope => _$args;

  int build(String scope);
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
    return element.handleCreate(ref, () => build(_$args));
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
