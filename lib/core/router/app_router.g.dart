// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single router for both surfaces.
///
/// One decision point — [resolveAdminRedirect] — decides whether a path lands
/// on the public storefront or the guarded admin gateway, so the two
/// experiences can never disagree about who is allowed where.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The single router for both surfaces.
///
/// One decision point — [resolveAdminRedirect] — decides whether a path lands
/// on the public storefront or the guarded admin gateway, so the two
/// experiences can never disagree about who is allowed where.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The single router for both surfaces.
  ///
  /// One decision point — [resolveAdminRedirect] — decides whether a path lands
  /// on the public storefront or the guarded admin gateway, so the two
  /// experiences can never disagree about who is allowed where.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'663253714ec65e995e30229140f3b9e5d3430706';
