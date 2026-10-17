// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_check_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The state of the backend this build points at, asset by asset.
///
/// Deliberately auto-disposed: every visit to the system check screen re-runs
/// the probes, so a migration the owner applies while the app is open is
/// picked up on the next visit (and by the "run again" action).

@ProviderFor(systemChecks)
final systemChecksProvider = SystemChecksProvider._();

/// The state of the backend this build points at, asset by asset.
///
/// Deliberately auto-disposed: every visit to the system check screen re-runs
/// the probes, so a migration the owner applies while the app is open is
/// picked up on the next visit (and by the "run again" action).

final class SystemChecksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SystemAssetCheck>>,
          List<SystemAssetCheck>,
          FutureOr<List<SystemAssetCheck>>
        >
    with
        $FutureModifier<List<SystemAssetCheck>>,
        $FutureProvider<List<SystemAssetCheck>> {
  /// The state of the backend this build points at, asset by asset.
  ///
  /// Deliberately auto-disposed: every visit to the system check screen re-runs
  /// the probes, so a migration the owner applies while the app is open is
  /// picked up on the next visit (and by the "run again" action).
  SystemChecksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemChecksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemChecksHash();

  @$internal
  @override
  $FutureProviderElement<List<SystemAssetCheck>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SystemAssetCheck>> create(Ref ref) {
    return systemChecks(ref);
  }
}

String _$systemChecksHash() => r'fc399c6ec1153eaef2b75c195a5ae8ee9f640f6f';
