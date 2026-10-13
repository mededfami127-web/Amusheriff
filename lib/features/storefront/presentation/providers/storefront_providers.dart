import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storefront_providers.g.dart';

/// The live search box value.
///
/// Held in a provider rather than `setState` so the results provider can
/// `watch` it and the debounce lives in one place.
@Riverpod(keepAlive: true)
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String value) => state = value;

  void clear() => state = '';
}

/// Which gallery item the product page is showing.
@Riverpod(keepAlive: true)
class GalleryIndex extends _$GalleryIndex {
  @override
  int build() => 0;

  void select(int index) => state = index;

  void reset() => state = 0;
}
