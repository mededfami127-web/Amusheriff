// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reactive online/offline flag.
///
/// Note this only reports whether a transport exists — not whether Supabase is
/// reachable. Repositories still have to handle [NetworkFailure] gracefully.

@ProviderFor(isOnline)
final isOnlineProvider = IsOnlineProvider._();

/// Reactive online/offline flag.
///
/// Note this only reports whether a transport exists — not whether Supabase is
/// reachable. Repositories still have to handle [NetworkFailure] gracefully.

final class IsOnlineProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Reactive online/offline flag.
  ///
  /// Note this only reports whether a transport exists — not whether Supabase is
  /// reachable. Repositories still have to handle [NetworkFailure] gracefully.
  IsOnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isOnline(ref);
  }
}

String _$isOnlineHash() => r'b3dabe1b9500fcc61c5f26526cb37a6677299404';
