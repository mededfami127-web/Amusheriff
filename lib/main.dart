import 'bootstrap.dart';

/// Entry point.
///
/// All wiring lives in [bootstrap] so every flavor (`--dart-define-from-file`)
/// starts identically and integration tests can call `bootstrap()` directly.
void main() => bootstrap();
