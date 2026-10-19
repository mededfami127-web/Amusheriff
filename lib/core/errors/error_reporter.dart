import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/env.dart';
import '../utils/app_logger.dart';

/// The one place uncaught errors are reported from.
///
/// `main()` installs three hooks — [runZonedGuarded], `FlutterError.onError`
/// and `PlatformDispatcher.onError` — and all three call [report]. That keeps a
/// failure from a background future, a widget build and a platform callback in
/// the same log line and the same Sentry event, instead of three code paths
/// that each decide for themselves whether to stay quiet.
abstract final class AppErrorReporter {
  const AppErrorReporter._();

  static void report(
    Object error,
    StackTrace stack, {
    String context = 'uncaught',
  }) {
    AppLog.error('$context: $error');
    if (Env.hasSentry) {
      Sentry.captureException(error, stackTrace: stack);
    }
  }
}

/// Installed by `main()` as the root-zone handler.
void reportUncaught(Object error, StackTrace stack) =>
    AppErrorReporter.report(error, stack, context: 'uncaught zone error');

/// Used by the widget tests and by `bootstrap()` when it wants a failure that
/// the framework would otherwise swallow.
void reportFlutterError(FlutterErrorDetails details) => AppErrorReporter.report(
  details.exception,
  details.stack ?? StackTrace.current,
  context: 'flutter error',
);
