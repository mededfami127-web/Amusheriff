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

/// One short technical line for a failure, or `null` when there is nothing
/// worth showing.
///
/// "The service is temporarily unavailable" is the right sentence for a
/// shopper and the wrong one for the owner whose Save was refused: it hides
/// the SQLSTATE that names the fix (a missing column, a policy denial, a
/// unique conflict). This turns the original Supabase exception back into
/// `code: message` plus its hint, which is exactly what a Supabase error
/// response carries, so the admin banner can print it under the friendly text.
///
/// Returns `null` for failures with no backend exception attached, and never
/// echoes a session token or any other credential — Postgres error text and
/// hints contain schema names and constraint names only.
String? technicalDetailFor(AppFailure failure) {
  final Object? cause = failure.cause;

  if (cause is PostgrestException) {
    final String code = (cause.code ?? '').trim();
    final String message = cause.message.trim();
    final String hint = (cause.hint ?? '').trim();
    final String head = <String>[
      if (code.isNotEmpty) code,
      if (message.isNotEmpty) message,
    ].join(': ');
    if (head.isEmpty) return null;
    return _shorten(hint.isEmpty ? head : '$head (hint: $hint)');
  }

  if (cause is StorageException) {
    final String status = (cause.statusCode ?? '').trim();
    final String message = cause.message.trim();
    // Storage has no `hint`; `error` is the gateway's own code
    // ("invalid_mime_type", "bucket not found", …) and is equally useful.
    final String detail = (cause.error ?? '').trim();
    final String head = <String>[
      if (status.isNotEmpty) 'HTTP $status',
      if (message.isNotEmpty) message,
    ].join(': ');
    if (head.isEmpty) return null;
    return _shorten(detail.isEmpty ? head : '$head (error: $detail)');
  }

  // No Supabase exception: the debug message is still the most precise thing
  // we have, but only if it says more than the localised sentence does.
  final String debug = (failure.debugMessage ?? '').trim();
  if (debug.isEmpty || debug == failure.messageKey) return null;
  return _shorten(debug);
}

/// Keeps the banner line readable on a 320 dp screen: a Postgres message can
/// quote a whole row, which nobody needs under a form.
String _shorten(String value) {
  const int max = 220;
  if (value.length <= max) return value;
  return '${value.substring(0, max - 1).trimRight()}…';
}
