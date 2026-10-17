import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/admin_gate_store.dart';

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

  /// `true` when the credentials were accepted.
  Future<bool> unlock({
    required String username,
    required String password,
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
      state = AdminGateState(unlocked: ok, wrongPassword: !ok);
      return ok;
    } on Object catch (error, stack) {
      state = AdminGateState(
        failure: ErrorMapper.map(error, stackTrace: stack),
      );
      return false;
    }
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
