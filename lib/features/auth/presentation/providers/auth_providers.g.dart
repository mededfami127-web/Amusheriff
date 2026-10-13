// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'6be0b761e0a1c3169e19d3fb4c9a3047ace9559a';

/// Whether the signed-in user is an administrator.
///
/// Rebuilds whenever the session changes, so signing out immediately closes
/// the `/admin/**` routes. The router guard watches this provider.

@ProviderFor(AdminStatus)
final adminStatusProvider = AdminStatusProvider._();

/// Whether the signed-in user is an administrator.
///
/// Rebuilds whenever the session changes, so signing out immediately closes
/// the `/admin/**` routes. The router guard watches this provider.
final class AdminStatusProvider
    extends $AsyncNotifierProvider<AdminStatus, bool> {
  /// Whether the signed-in user is an administrator.
  ///
  /// Rebuilds whenever the session changes, so signing out immediately closes
  /// the `/admin/**` routes. The router guard watches this provider.
  AdminStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminStatusHash();

  @$internal
  @override
  AdminStatus create() => AdminStatus();
}

String _$adminStatusHash() => r'c3536b1c76f5f20ac401e4beff2823e470e3db23';

/// Whether the signed-in user is an administrator.
///
/// Rebuilds whenever the session changes, so signing out immediately closes
/// the `/admin/**` routes. The router guard watches this provider.

abstract class _$AdminStatus extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Convenience: `true` only once the admin status is known and positive.

@ProviderFor(isConfirmedAdmin)
final isConfirmedAdminProvider = IsConfirmedAdminProvider._();

/// Convenience: `true` only once the admin status is known and positive.

final class IsConfirmedAdminProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Convenience: `true` only once the admin status is known and positive.
  IsConfirmedAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isConfirmedAdminProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isConfirmedAdminHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isConfirmedAdmin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isConfirmedAdminHash() => r'cde5e94afca8a285b30db786073c41c17ef00e49';

/// Drives the admin sign-in / sign-out / password screens.
///
/// Business logic never touches `setState`: the widget reads `state` and calls
/// these methods.

@ProviderFor(AdminAuthController)
final adminAuthControllerProvider = AdminAuthControllerProvider._();

/// Drives the admin sign-in / sign-out / password screens.
///
/// Business logic never touches `setState`: the widget reads `state` and calls
/// these methods.
final class AdminAuthControllerProvider
    extends $AsyncNotifierProvider<AdminAuthController, void> {
  /// Drives the admin sign-in / sign-out / password screens.
  ///
  /// Business logic never touches `setState`: the widget reads `state` and calls
  /// these methods.
  AdminAuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminAuthControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminAuthControllerHash();

  @$internal
  @override
  AdminAuthController create() => AdminAuthController();
}

String _$adminAuthControllerHash() =>
    r'6673100a0ceebdb4dc1783ffb230d9737e04bc0f';

/// Drives the admin sign-in / sign-out / password screens.
///
/// Business logic never touches `setState`: the widget reads `state` and calls
/// these methods.

abstract class _$AdminAuthController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Stream of `true` while an admin is signed in — used by the admin shell.

@ProviderFor(signedInAsAdmin)
final signedInAsAdminProvider = SignedInAsAdminProvider._();

/// Stream of `true` while an admin is signed in — used by the admin shell.

final class SignedInAsAdminProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Stream of `true` while an admin is signed in — used by the admin shell.
  SignedInAsAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signedInAsAdminProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signedInAsAdminHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return signedInAsAdmin(ref);
  }
}

String _$signedInAsAdminHash() => r'409a7d641790dde6cad6576785b8452f43893cbc';
