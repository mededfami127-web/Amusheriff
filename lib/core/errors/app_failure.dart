import 'package:flutter/foundation.dart';

/// Sealed hierarchy of every failure the app can surface.
///
/// UI code switches exhaustively on [AppFailure], so a new case becomes a
/// compile error everywhere it must be handled. Each failure carries a
/// localisation key ([messageKey]) rather than a baked-in English string, plus
/// a [debugMessage] that is only ever surfaced in debug builds / Sentry.
///
/// Subclasses override the default [messageKey] by passing `messageKey:` to
/// `super`, which keeps every constructor `const`.
@immutable
sealed class AppFailure implements Exception {
  const AppFailure({
    required this.messageKey,
    this.debugMessage,
    this.cause,
    this.statusCode,
  });

  /// ARB lookup key, e.g. `errorNetwork`.
  final String messageKey;

  /// Developer-facing detail. Never shown to end users.
  final String? debugMessage;

  /// Original error/exception, retained for Sentry.
  final Object? cause;

  /// HTTP status code when the failure came from an HTTP layer.
  final int? statusCode;

  /// Whether retrying the same operation could plausibly succeed.
  bool get isRetryable;

  @override
  String toString() =>
      '$runtimeType($messageKey'
      '${statusCode != null ? ', status: $statusCode' : ''}'
      '${debugMessage != null ? ', debug: $debugMessage' : ''})';
}

/// No connectivity, or the request could not reach the backend.
final class NetworkFailure extends AppFailure {
  const NetworkFailure({super.debugMessage, super.cause, super.statusCode})
    : super(messageKey: 'errorNetwork');

  @override
  bool get isRetryable => true;
}

/// The request timed out.
final class TimeoutFailure extends AppFailure {
  const TimeoutFailure({super.debugMessage, super.cause})
    : super(messageKey: 'errorTimeout');

  @override
  bool get isRetryable => true;
}

/// Backend returned an unexpected / server-side error.
final class ServerFailure extends AppFailure {
  const ServerFailure({
    super.debugMessage,
    super.cause,
    super.statusCode,
    super.messageKey = 'errorServer',
    this.operation,
  });

  final String? operation;

  @override
  bool get isRetryable => true;
}

/// Authentication failed, or the session expired.
final class AuthFailure extends AppFailure {
  const AuthFailure({
    super.debugMessage,
    super.cause,
    super.statusCode,
    super.messageKey = 'errorAuth',
  });

  @override
  bool get isRetryable => false;
}

/// Signed in, but not allowed to perform the operation (RLS denied the write).
final class PermissionFailure extends AppFailure {
  const PermissionFailure({super.debugMessage, super.cause, super.statusCode})
    : super(messageKey: 'errorPermission');

  @override
  bool get isRetryable => false;
}

/// The requested row does not exist, or is not visible to this user.
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({super.debugMessage, super.cause, this.entity})
    : super(messageKey: 'errorNotFound', statusCode: 404);

  final String? entity;

  @override
  bool get isRetryable => false;
}

/// Input failed validation before or during the request.
final class ValidationFailure extends AppFailure {
  const ValidationFailure({
    this.fieldErrors = const <String, String>{},
    super.debugMessage,
    super.cause,
    super.messageKey = 'errorValidation',
  });

  /// Field name → message key, rendered inline by form widgets.
  final Map<String, String> fieldErrors;

  @override
  bool get isRetryable => false;
}

/// A media upload/processing step failed (compression, mime, size, duration).
final class MediaFailure extends AppFailure {
  const MediaFailure({
    super.debugMessage,
    super.cause,
    super.messageKey = 'errorMedia',
  });

  @override
  bool get isRetryable => true;
}

/// Storage (bucket) access failed.
final class StorageFailure extends AppFailure {
  const StorageFailure({super.debugMessage, super.cause, super.statusCode})
    : super(messageKey: 'errorStorage');

  @override
  bool get isRetryable => true;
}

/// Anything we could not classify. Always logged together with its cause.
final class UnknownFailure extends AppFailure {
  const UnknownFailure({super.debugMessage, super.cause, super.statusCode})
    : super(messageKey: 'errorUnknown');

  @override
  bool get isRetryable => true;
}
