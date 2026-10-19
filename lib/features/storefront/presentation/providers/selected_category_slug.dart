import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';

/// The category slug the customer is currently looking at, taken from the URL.
///
/// Used by the category page so the subcategory chips can show which one is
/// selected, and by any widget that needs to reflect the current category
/// without another round trip.
@riverpod
String? selectedCategorySlug(Ref ref) {
  final GoRouterState state = ref.watch(goRouterProvider).state;
  final String? fromPath = state.pathParameters['category'];
  if (fromPath != null) return fromPath;
  if (state.uri.pathSegments.length > 1) return state.uri.pathSegments[1];
  return null;
}

/// Companion reader used where only the current slug matters and a provider
/// rebuild is undesirable.
String? currentCategorySlugFromGoRouter(GoRouterState state) {
  final String? fromPath = state.pathParameters['category'];
  if (fromPath != null) return fromPath;
  if (state.uri.pathSegments.length > 1) return state.uri.pathSegments[1];
  return null;
}
