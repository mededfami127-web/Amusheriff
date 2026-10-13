// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_client_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single, app-wide Supabase client.
///
/// Overridden in tests with a fake so repositories never touch the network.

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

/// The single, app-wide Supabase client.
///
/// Overridden in tests with a fake so repositories never touch the network.

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// The single, app-wide Supabase client.
  ///
  /// Overridden in tests with a fake so repositories never touch the network.
  SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'3db2a4c212c7f24cea9810e376225aa1a6cab012';

/// Fires on every auth event (sign-in, sign-out, token refresh, recovery).

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

/// Fires on every auth event (sign-in, sign-out, token refresh, recovery).

final class AuthStateChangesProvider
    extends
        $FunctionalProvider<AsyncValue<AuthState>, AuthState, Stream<AuthState>>
    with $FutureModifier<AuthState>, $StreamProvider<AuthState> {
  /// Fires on every auth event (sign-in, sign-out, token refresh, recovery).
  AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthState> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'310af7ac668b2f2faabbc6d8fc00b2b768260eed';

/// The current session, or `null` when signed out.

@ProviderFor(currentSession)
final currentSessionProvider = CurrentSessionProvider._();

/// The current session, or `null` when signed out.

final class CurrentSessionProvider
    extends $FunctionalProvider<Session?, Session?, Session?>
    with $Provider<Session?> {
  /// The current session, or `null` when signed out.
  CurrentSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSessionHash();

  @$internal
  @override
  $ProviderElement<Session?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Session? create(Ref ref) {
    return currentSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Session? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Session?>(value),
    );
  }
}

String _$currentSessionHash() => r'96111cc40b2dc6597cd6265b4c505136aa8652d5';

/// The current authenticated user, or `null` when signed out.

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// The current authenticated user, or `null` when signed out.

final class CurrentUserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  /// The current authenticated user, or `null` when signed out.
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$currentUserHash() => r'6f1994b508bd1eba840f0fb1241ae6624a4566fa';

/// Stream of the signed-in user id, used by the router guard.

@ProviderFor(currentUserId)
final currentUserIdProvider = CurrentUserIdProvider._();

/// Stream of the signed-in user id, used by the router guard.

final class CurrentUserIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// Stream of the signed-in user id, used by the router guard.
  CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return currentUserId(ref);
  }
}

String _$currentUserIdHash() => r'59fc17a74eb85ba57562ff0dce56fadf2f6b0c03';
