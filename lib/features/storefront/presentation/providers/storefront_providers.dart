import 'dart:async';

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

/// The same query, but only after the typist has paused.
///
/// 350 ms is the difference between a trigram query per keystroke and one per
/// word. Switching the query also disposes the previous `searchProducts`
/// future, so a slow answer for "so" can never overwrite the answer for
/// "sofa" — that is the stale-response race, closed at the provider level.
@Riverpod(keepAlive: true)
class DebouncedSearchQuery extends _$DebouncedSearchQuery {
  Timer? _timer;

  @override
  String build() {
    ref.listen<String>(searchQueryProvider, (String? _, String next) {
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 350), () => state = next);
    });
    ref.onDispose(() => _timer?.cancel());
    return ref.read(searchQueryProvider);
  }
}

/// How many list items one page shows. `more()` is the "load more" action;
/// a screen keeps its own counter by passing a scope key (home, a category
/// slug), so opening a category does not disturb the home page's page.
@Riverpod(keepAlive: true)
class VisibleCount extends _$VisibleCount {
  static const int pageSize = 20;

  @override
  int build(String scope) => pageSize;

  void more() => state += pageSize;

  void reset() => state = pageSize;
}

/// Which gallery item the product page is showing.
@Riverpod(keepAlive: true)
class GalleryIndex extends _$GalleryIndex {
  @override
  int build() => 0;

  void select(int index) => state = index;

  void reset() => state = 0;
}
