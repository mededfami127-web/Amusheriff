import 'dart:async';

import 'bootstrap.dart';
import 'core/errors/error_reporter.dart';

/// Entry point.
///
/// All wiring lives in [bootstrap] so every flavor (`--dart-define-from-file`)
/// starts identically and integration tests can call `bootstrap()` directly.
///
/// The root zone is guarded first: a failure from a future nobody awaited, a
/// stream listener or a platform callback lands in [reportUncaught] instead of
/// disappearing. `bootstrap()` installs the Flutter and platform hooks, and
/// those call the same reporter.
void main() {
  runZonedGuarded(bootstrap, reportUncaught);
}
