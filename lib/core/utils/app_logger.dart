import 'package:flutter/foundation.dart';

import '../config/env.dart';

/// Level-aware logging, driven by the compile-time `LOG_LEVEL` define that
/// every flavour config ships (`debug` · `info` · `warning` · `error`).
///
/// The app is installed on devices nobody can attach a debugger to, so when a
/// flow misbehaves in the field the only trace it leaves is what reached the
/// device log. Every failure that passes through `ErrorMapper.guard` is
/// written here, which covers admin CRUD, sign-in, media upload and settings
/// with one call site instead of one per screen.
///
/// Release note: `debugPrint` reaches logcat in debug and profile builds —
/// what `.github/workflows/debug-apk.yml` produces — but a release build
/// disconnects Dart's stdout, so on a Play build these lines only surface
/// through Sentry, which bootstrap wires for that case.
abstract final class AppLog {
  const AppLog._();

  static const Map<String, int> _levels = <String, int>{
    'debug': 0,
    'info': 1,
    'warning': 2,
    'error': 3,
  };

  /// An unknown `LOG_LEVEL` falls back to `info` rather than to silence: a typo
  /// in a flavour config should never hide the failures it was meant to show.
  static int get _threshold => _levels[Env.logLevel.toLowerCase()] ?? 1;

  static void debug(String message) => _write(0, 'D', message, null);

  static void info(String message) => _write(1, 'I', message, null);

  static void warning(String message, [Object? error]) =>
      _write(2, 'W', message, error);

  static void error(String message, [Object? error]) =>
      _write(3, 'E', message, error);

  static void _write(int level, String tag, String message, Object? error) {
    if (level < _threshold) return;
    final String detail = error == null ? '' : ' — $error';
    debugPrint('[ASM/$tag] $message$detail');
  }
}
