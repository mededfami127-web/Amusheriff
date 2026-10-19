// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_gate_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `bootstrap()` with the already-loaded store, so the router can
/// read the gate synchronously on the very first frame.

@ProviderFor(adminGateStore)
final adminGateStoreProvider = AdminGateStoreProvider._();

/// Overridden in `bootstrap()` with the already-loaded store, so the router can
/// read the gate synchronously on the very first frame.

final class AdminGateStoreProvider
    extends $FunctionalProvider<AdminGateStore, AdminGateStore, AdminGateStore>
    with $Provider<AdminGateStore> {
  /// Overridden in `bootstrap()` with the already-loaded store, so the router can
  /// read the gate synchronously on the very first frame.
  AdminGateStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminGateStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminGateStoreHash();

  @$internal
  @override
  $ProviderElement<AdminGateStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdminGateStore create(Ref ref) {
    return adminGateStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminGateStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminGateStore>(value),
    );
  }
}

String _$adminGateStoreHash() => r'6a77bd12c626f1ffab0db1f0db258a2d7dcd229c';

/// Whether the owner has opened the gateway on this device.
///
/// The router guard watches this: unlocking lets `/admin/**` through without a
/// Supabase session, which is what makes the five-tap entry usable on a device
/// that has never signed in.

@ProviderFor(adminGateUnlocked)
final adminGateUnlockedProvider = AdminGateUnlockedProvider._();

/// Whether the owner has opened the gateway on this device.
///
/// The router guard watches this: unlocking lets `/admin/**` through without a
/// Supabase session, which is what makes the five-tap entry usable on a device
/// that has never signed in.

final class AdminGateUnlockedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the owner has opened the gateway on this device.
  ///
  /// The router guard watches this: unlocking lets `/admin/**` through without a
  /// Supabase session, which is what makes the five-tap entry usable on a device
  /// that has never signed in.
  AdminGateUnlockedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminGateUnlockedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminGateUnlockedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return adminGateUnlocked(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$adminGateUnlockedHash() => r'cfd565b2b41e37c0ff31836a8e1d71d764adf1c0';

/// Drives the five-tap panel and the gateway-password screen.

@ProviderFor(AdminGate)
final adminGateProvider = AdminGateProvider._();

/// Drives the five-tap panel and the gateway-password screen.
final class AdminGateProvider
    extends $NotifierProvider<AdminGate, AdminGateState> {
  /// Drives the five-tap panel and the gateway-password screen.
  AdminGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminGateHash();

  @$internal
  @override
  AdminGate create() => AdminGate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminGateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminGateState>(value),
    );
  }
}

String _$adminGateHash() => r'2f9238135f3171a37defe7b99e71472e5e870e62';

/// Drives the five-tap panel and the gateway-password screen.

abstract class _$AdminGate extends $Notifier<AdminGateState> {
  AdminGateState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AdminGateState, AdminGateState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdminGateState, AdminGateState>,
              AdminGateState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
