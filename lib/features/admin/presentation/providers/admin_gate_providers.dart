import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/admin_gate_store.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

part 'admin_gate_providers.g.dart';

/// Overridden in `bootstrap()` with the already-loaded store, so the router can
/// read the gate synchronously on the very first frame.
@Riverpod(keepAlive: true)
AdminGateStore adminGateStore(Ref ref) =>
    AdminGateStore(const FlutterSecureStorage());

/// Whether the owner has opened the gateway on this device.
///
/// The router guard watches this: unlocking lets `/admin/**` through without a
/// Supabase session, which is what makes the five-tap entry usable on a device
/// that has never signed in.
@riverpod
bool adminGateUnlocked(Ref ref) => ref.watch(adminGateProvider).unlocked;

/// Session state of the owner gateway.
@immutable
class AdminGateState {
  const AdminGateState({
    this.unlocked = false,
    this.busy = false,
    this.failure,
    this.wrongPassword = false,
  });

  final bool unlocked;
  final bool busy;
  final AppFailure? failure;

  /// Set when the credentials were simply wrong, so the UI can say so without
  /// treating it as a system error.
  final bool wrongPassword;

  AdminGateState copyWith({
    bool? unlocked,
    bool? busy,
    bool? wrongPassword,
    AppFailure? failure,
    bool clearFailure = false,
  }) => AdminGateState(
    unlocked: unlocked ?? this.unlocked,
    busy: busy ?? this.busy,
    wrongPassword: wrongPassword ?? this.wrongPassword,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

/// Drives the five-tap panel and the gateway-password screen.
@Riverpod(keepAlive: true)
class AdminGate extends _$AdminGate {
  @override
  AdminGateState build() =>
      AdminGateState(unlocked: ref.watch(adminGateStoreProvider).unlocked);

  AdminGateStore get _store => ref.read(adminGateStoreProvider);

  /// `true` when the credentials were accepted **and** a session is open.
  ///
  /// The panel is a device lock; on its own it grants nothing in Postgres.
  /// Every admin write travels with the caller's JWT, so with no session
  /// `auth.uid()` is NULL, `public.is_admin()` is false and every policy answers
  /// 42501 — the generic "You do not have permission to do that." the owner saw
  /// on every save. So the unlock signs the owner account in when there is no
  /// session, and force-refreshes the token when there is.
  Future<bool> unlock({
    required String username,
    required String password,
    String? email,
    String? databasePassword,
  }) async {
    state = state.copyWith(
      busy: true,
      clearFailure: true,
      wrongPassword: false,
    );
    try {
      final bool ok = await _store.unlock(
        username: username,
        password: password,
      );
      if (!ok) {
        state = const AdminGateState(wrongPassword: true);
        return false;
      }

      final AppFailure? failure = await _openSession(
        email: email,
        password: databasePassword,
      );
      if (failure != null) {
        // Nothing behind the gate can save without a session, so do not open it
        // and then let every Save fail with a message about permissions.
        await _store.lock();
        state = AdminGateState(failure: failure);
        return false;
      }

      state = const AdminGateState(unlocked: true);
      return true;
    } on Object catch (error, stack) {
      await _store.lock();
      state = AdminGateState(
        failure: ErrorMapper.map(error, stackTrace: stack),
      );
      return false;
    }
  }

  /// Opens, or revalidates, the Supabase session the panel needs.
  ///
  /// Returns `null` on success, or the failure to show in the panel. The account
  /// must be flagged in Postgres — the gate cannot promote it, and `is_admin()`
  /// reads that row on every policy check.
  Future<AppFailure?> _openSession({String? email, String? password}) async {
    final SupabaseClient client = ref.read(supabaseClientProvider);
    final AuthRepository auth = ref.read(authRepositoryProvider);
    final String mail = (email ?? _store.ownerEmail).trim();
    final String secret = (password ?? '').trim();

    Future<void> signIn() async {
      await auth.signInWithPassword(email: mail, password: secret);
      await _store.saveOwnerEmail(mail);
    }

    try {
      if (client.auth.currentSession == null) {
        if (mail.isEmpty || secret.isEmpty) {
          return const PermissionFailure(
            messageKey: 'errorNotSignedIn',
            debugMessage: 'gate opened locally, but no owner account is linked',
          );
        }
        await signIn();
      } else {
        try {
          // A cached JWT may be minutes from expiry, and from Postgres an
          // expired one is indistinguishable from a forbidden one.
          await client.auth.refreshSession();
        } on AuthException {
          if (mail.isEmpty || secret.isEmpty) rethrow;
          await signIn();
        }
      }
    } on AppFailure catch (failure) {
      return failure;
    } on AuthException catch (error) {
      return ErrorMapper.map(error);
    }

    try {
      if (!await auth.isAdmin()) {
        return const PermissionFailure(
          messageKey: 'errorNotAdmin',
          debugMessage: 'signed in, but public.profiles.is_admin is not true for this uid',
        );
      }
    } on AppFailure catch (failure) {
      return failure;
    }

    return null;
  }

  Future<void> lock() async {
    state = state.copyWith(busy: true, clearFailure: true);
    try {
      await _store.lock();
      state = const AdminGateState();
    } on Object catch (error, stack) {
      state = AdminGateState(
        failure: ErrorMapper.map(error, stackTrace: stack),
        unlocked: state.unlocked,
      );
    }
  }

  /// `true` when the current password matched and the new one was stored.
  Future<bool> changePassword({
    required String current,
    required String next,
  }) async {
    state = state.copyWith(
      busy: true,
      clearFailure: true,
      wrongPassword: false,
    );
    try {
      final bool ok = await _store.changePassword(current: current, next: next);
      state = AdminGateState(unlocked: state.unlocked, wrongPassword: !ok);
      return ok;
    } on Object catch (error, stack) {
      state = AdminGateState(
        failure: ErrorMapper.map(error, stackTrace: stack),
        unlocked: state.unlocked,
      );
      return false;
    }
  }

  void acknowledge() => state = AdminGateState(unlocked: state.unlocked);
}
