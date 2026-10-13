// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launcher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in tests with a fake [LinkLauncher].

@ProviderFor(linkLauncher)
final linkLauncherProvider = LinkLauncherProvider._();

/// Overridden in tests with a fake [LinkLauncher].

final class LinkLauncherProvider
    extends $FunctionalProvider<LinkLauncher, LinkLauncher, LinkLauncher>
    with $Provider<LinkLauncher> {
  /// Overridden in tests with a fake [LinkLauncher].
  LinkLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkLauncherHash();

  @$internal
  @override
  $ProviderElement<LinkLauncher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LinkLauncher create(Ref ref) {
    return linkLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkLauncher>(value),
    );
  }
}

String _$linkLauncherHash() => r'a6b79e0f0295c39c686276b2104ea6d49d88f40b';
