import 'dart:async';
import 'dart:io' show SocketException, HttpException;

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_failure.dart';

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
          fieldErrors: const <String, String>{'_row': 'errorConstraintViolation'},
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

  /// Runs [body], converting any thrown error into an [AppFailure] and
  /// reporting the original to [onError] (the Sentry hook wired in bootstrap).
  static Future<T> guard<T>(
    Future<T> Function() body, {
    void Function(AppFailure failure, StackTrace stack)? onError,
  }) async {
    try {
      return await body();
    } catch (error, stack) {
      final AppFailure failure = map(error, stackTrace: stack);
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
