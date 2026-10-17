import 'dart:async';
import 'dart:io' show SocketException, HttpException;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_logger.dart';
import 'app_failure.dart';
import 'backend_asset_status.dart';

/// Translates the exceptions thrown by Supabase, `dart:io` and the platform
/// into the sealed [AppFailure] hierarchy. Repository implementations call
/// [ErrorMapper.guard] so that no raw exception ever escapes the data layer.
abstract final class ErrorMapper {
  const ErrorMapper._();

  static AppFailure map(Object error, {StackTrace? stackTrace}) {
    if (error is AppFailure) return error;

    if (error is AuthException) {
      return AuthFailure(
        debugMessage: error.message,
        cause: error,
        statusCode: _intOrNull(error.statusCode),
        messageKey: _authKey(error.message),
      );
    }

    if (error is PostgrestException) {
      final String code = (error.code ?? '').trim();
      // The relation does not exist on this project at all — the migrations
      // were never applied to the backend this build points at. Naming that
      // fix is far more useful than "service unavailable".
      if (classifyBackendFailure(error) == SystemAssetStatus.missing) {
        return ServerFailure(
          messageKey: 'errorBackendNotSetUp',
          debugMessage: error.message,
          cause: error,
        );
      }
      // 42501 = insufficient_privilege → a row-level-security policy denied us.
      if (code == '42501') {
        return PermissionFailure(debugMessage: error.message, cause: error);
      }
      if (code == 'PGRST116') {
        return NotFoundFailure(debugMessage: error.message, cause: error);
      }
      // 23xxx = integrity constraint violations (unique, check, FK).
      if (code.startsWith('23')) {
        return ValidationFailure(
          fieldErrors: const <String, String>{
            '_row': 'errorConstraintViolation',
          },
          messageKey: _constraintKey(code),
          debugMessage: error.message,
          cause: error,
        );
      }
      if (code == 'PGRST301' || code == 'PGRST302') {
        return AuthFailure(
          debugMessage: error.message,
          cause: error,
          messageKey: 'errorSessionExpired',
        );
      }
      return ServerFailure(
        debugMessage: error.message,
        cause: error,
        operation: error.details?.toString(),
      );
    }

    if (error is StorageException) {
      final int? status = _intOrNull(error.statusCode);
      // A bucket the storage migration never created is the same story as a
      // missing table: the backend is not set up yet.
      if (classifyBackendFailure(error) == SystemAssetStatus.missing) {
        return StorageFailure(
          messageKey: 'errorBackendNotSetUp',
          debugMessage: error.message,
          cause: error,
          statusCode: status,
        );
      }
      if (status == 403) {
        return PermissionFailure(
          debugMessage: error.message,
          cause: error,
          statusCode: status,
        );
      }
      return StorageFailure(
        debugMessage: error.message,
        cause: error,
        statusCode: status,
      );
    }

    if (error is FunctionException) {
      // A 404 from the gateway means the function was never deployed.
      if (classifyBackendFailure(error) == SystemAssetStatus.missing) {
        return ServerFailure(
          messageKey: 'errorBackendNotSetUp',
          debugMessage: error.details?.toString(),
          cause: error,
        );
      }
      if (error is FunctionsFetchException) {
        return NetworkFailure(
          debugMessage: error.details?.toString(),
          cause: error,
        );
      }
      return ServerFailure(
        debugMessage: error.details?.toString(),
        cause: error,
        statusCode: error.status,
      );
    }

    if (error is SocketException) {
      return NetworkFailure(debugMessage: error.message, cause: error);
    }

    if (error is TimeoutException) {
      return TimeoutFailure(debugMessage: error.message, cause: error);
    }

    if (error is HttpException) {
      return NetworkFailure(debugMessage: error.message, cause: error);
    }

    if (error is FormatException) {
      return ValidationFailure(
        fieldErrors: const <String, String>{'_format': 'errorInvalidFormat'},
        debugMessage: error.message,
        cause: error,
      );
    }

    return UnknownFailure(debugMessage: error.toString(), cause: error);
  }

  /// Called for every failure that passes through [guard], before it is
  /// rethrown.
  ///
  /// bootstrap() installs the reporting sink here (Sentry, when a DSN is
  /// configured). No repository ever passed the per-call [guard] hook, so
  /// before this existed the handled failures — a save denied by RLS, a wrong
  /// password, a rejected upload — reached neither the device log nor Sentry.
  static void Function(AppFailure failure, StackTrace stack)? onFailure;

  /// Runs [body], converting any thrown error into an [AppFailure].
  ///
  /// The failure is logged, handed to [onFailure] (installed by bootstrap for
  /// Sentry reporting), then to [onError] if the caller passed one, and finally
  /// rethrown so the UI can still render its localized message.
  static Future<T> guard<T>(
    Future<T> Function() body, {
    void Function(AppFailure failure, StackTrace stack)? onError,
  }) async {
    try {
      return await body();
    } catch (error, stack) {
      final AppFailure failure = map(error, stackTrace: stack);
      AppLog.error('${failure.runtimeType}: ${failure.debugMessage}', error);
      onFailure?.call(failure, stack);
      onError?.call(failure, stack);
      throw failure;
    }
  }

  static String _authKey(String message) {
    final String m = message.toLowerCase();
    if (m.contains('invalid login')) return 'errorInvalidCredentials';
    if (m.contains('email not confirmed')) return 'errorEmailNotConfirmed';
    if (m.contains('rate limit') || m.contains('too many')) {
      return 'errorTooManyAttempts';
    }
    if (m.contains('network') || m.contains('socket')) return 'errorNetwork';
    if (m.contains('session') || m.contains('expired') || m.contains('jwt')) {
      return 'errorSessionExpired';
    }
    return 'errorAuth';
  }

  static String _constraintKey(String code) => switch (code) {
    '23505' => 'errorDuplicate',
    '23514' => 'errorCheckViolation',
    '23503' => 'errorForeignKey',
    _ => 'errorConstraintViolation',
  };

  static int? _intOrNull(String? raw) =>
      raw == null ? null : int.tryParse(raw.trim());
}
