// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live "is there a network at all" flag.
///
/// This is the transport view, not a reachability probe: Supabase can still be
/// down while Wi-Fi is up. That is what the typed `NetworkFailure` screens are
/// for. This provider exists so a device with no radio shows a banner instead
/// of a blank screen while every request times out.

@ProviderFor(hasConnection)
final hasConnectionProvider = HasConnectionProvider._();

/// Live "is there a network at all" flag.
///
/// This is the transport view, not a reachability probe: Supabase can still be
/// down while Wi-Fi is up. That is what the typed `NetworkFailure` screens are
/// for. This provider exists so a device with no radio shows a banner instead
/// of a blank screen while every request times out.

final class HasConnectionProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Live "is there a network at all" flag.
  ///
  /// This is the transport view, not a reachability probe: Supabase can still be
  /// down while Wi-Fi is up. That is what the typed `NetworkFailure` screens are
  /// for. This provider exists so a device with no radio shows a banner instead
  /// of a blank screen while every request times out.
  HasConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasConnectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasConnectionHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return hasConnection(ref);
  }
}

String _$hasConnectionHash() => r'e19b64fedac7a1e08b778de1594b0370793cf335';
