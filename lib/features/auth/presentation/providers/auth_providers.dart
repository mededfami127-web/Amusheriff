import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.watch(supabaseClientProvider));

/// Whether the signed-in user is an administrator.
///
/// Rebuilds whenever the session changes, so signing out immediately closes
/// the `/admin/**` routes. The router guard watches this provider.
@Riverpod(keepAlive: true)
class AdminStatus extends _$AdminStatus {
  @override
  Future<bool> build() async {
    final Session? session = ref.watch(currentSessionProvider);
    if (session == null) return false;
    return ref.watch(authRepositoryProvider).isAdmin();
  }

  /// Re-reads `profiles.is_admin` (used after sign-in).
  Future<void> refresh() async {
    state = const AsyncValue<bool>.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).isAdmin(),
    );
  }
}

/// Convenience: `true` only once the admin status is known and positive.
@riverpod
bool isConfirmedAdmin(Ref ref) => ref.watch(adminStatusProvider).value ?? false;

/// Drives the admin sign-in / sign-out / password screens.
///
/// Business logic never touches `setState`: the widget reads `state` and calls
/// these methods.
@riverpod
class AdminAuthController extends _$AdminAuthController {
  @override
  FutureOr<void> build() {}

  bool get isBusy => state.isLoading;

  /// Returns `true` on success. Failures are exposed through `state`.
  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncValue<void>.loading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithPassword(email: email, password: password);
      // The profile row (and therefore is_admin) changed identity.
      await ref.read(adminStatusProvider.notifier).refresh();
      state = const AsyncValue<void>.data(null);
      return true;
    } on AppFailure catch (error, stack) {
      state = AsyncValue<void>.error(error, stack);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue<void>.loading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      ref.invalidate(adminStatusProvider);
      state = const AsyncValue<void>.data(null);
    } on AppFailure catch (error, stack) {
      state = AsyncValue<void>.error(error, stack);
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncValue<void>.loading();
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      state = const AsyncValue<void>.data(null);
      return true;
    } on AppFailure catch (error, stack) {
      state = AsyncValue<void>.error(error, stack);
      return false;
    }
  }

  /// Verifies the current password, then sets the new one.
  Future<bool> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncValue<void>.loading();
    try {
      final AuthRepository repo = ref.read(authRepositoryProvider);
      final bool verified = await repo.verifyPassword(
        email: email,
        password: currentPassword,
      );
      if (!verified) {
        state = AsyncValue<void>.error(
          const AuthFailure(messageKey: 'errorInvalidCredentials'),
          StackTrace.current,
        );
        return false;
      }
      await repo.updatePassword(newPassword);
      state = const AsyncValue<void>.data(null);
      return true;
    } on AppFailure catch (error, stack) {
      state = AsyncValue<void>.error(error, stack);
      return false;
    }
  }

  /// Clears a previous error so the form can be retried cleanly.
  void reset() => state = const AsyncValue<void>.data(null);
}

/// Stream of `true` while an admin is signed in — used by the admin shell.
@riverpod
Stream<bool> signedInAsAdmin(Ref ref) => ref
    .watch(authRepositoryProvider)
    .authStateChanges
    .map((AuthState state) => state.session != null);
