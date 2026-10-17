import 'package:flutter/foundation.dart';

/// Build flavors. Each flavor ships with its own Supabase project, supplied at
/// compile time via `--dart-define-from-file=config/<flavor>.json`.
///
/// Never hard-code a service-role key here: the app only ever receives the
/// public anon key, and row level security does the rest.
enum AppFlavor {
  dev,
  staging,
  prod;

  static const String _raw = String.fromEnvironment('FLAVOR', defaultValue: '');

  /// Flavor resolved from `--dart-define=FLAVOR=...`.
  ///
  /// Falls back to [prod] for release builds and [dev] otherwise, so a plain
  /// `flutter run` works without any defines.
  static AppFlavor get current {
    if (_raw.isNotEmpty) {
      for (final AppFlavor flavor in AppFlavor.values) {
        if (flavor.name == _raw) return flavor;
      }
    }
    return kReleaseMode ? AppFlavor.prod : AppFlavor.dev;
  }

  bool get isProd => this == AppFlavor.prod;
  bool get isDev => this == AppFlavor.dev;

  /// Android application id suffix reserved for native product flavors. The
  /// Gradle build does not apply it yet (D-019), so dev/staging/prod currently
  /// share one application id and cannot be installed side by side.
  String get applicationIdSuffix => switch (this) {
    AppFlavor.dev => '.dev',
    AppFlavor.staging => '.staging',
    AppFlavor.prod => '',
  };

  /// Display suffix appended to the app label in non-production builds.
  String get labelSuffix => switch (this) {
    AppFlavor.dev => ' (dev)',
    AppFlavor.staging => ' (staging)',
    AppFlavor.prod => '',
  };
}
