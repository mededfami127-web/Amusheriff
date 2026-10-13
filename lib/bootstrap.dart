import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/config/flavors.dart';
import 'features/settings/presentation/providers/site_settings_providers.dart';

/// Boots the app in a deterministic order:
///
/// 1. validate compile-time configuration (fail loudly, not with an opaque
///    network error later),
/// 2. initialise Supabase with the public anon key,
/// 3. restore the persisted language/theme so the first frame is already
///    themed and, for Arabic, already RTL,
/// 4. install error handlers (Sentry when a DSN is configured),
/// 5. `runApp`.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  Env.assertConfigured();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    // Supabase renamed "anon key" to "publishable key"; the value is the same
    // project-scoped public key. The service-role key never ships to clients.
    publishableKey: Env.supabaseAnonKey,
    debug: false,
  );

  final PreferencesStore preferences = PreferencesStore(
    const FlutterSecureStorage(),
  );
  await preferences.load(PlatformDispatcher.instance.locale.languageCode);

  _installErrorHandlers();

  if (Env.hasSentry) {
    await SentryFlutter.init(
      (SentryFlutterOptions options) {
        options
          ..dsn = Env.sentryDsn
          ..environment = AppFlavor.current.name
          ..tracesSampleRate = AppFlavor.current.isProd ? 0.2 : 1.0
          ..attachStacktrace = true
          ..sendDefaultPii = false;
      },
      appRunner: () => _run(preferences),
    );
  } else {
    _run(preferences);
  }
}

void _run(PreferencesStore preferences) {
  runApp(
    ProviderScope(
      overrides: [
        // The store is pre-loaded, so `AppPreferences.build()` can be
        // synchronous and the first frame already has the right values.
        preferencesStoreProvider.overrideWithValue(preferences),
      ],
      child: const AmuApp(),
    ),
  );
}

void _installErrorHandlers() {
  final FlutterExceptionHandler? previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (Env.hasSentry) {
      Sentry.captureException(details.exception, stackTrace: details.stack);
    }
    previous?.call(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    if (Env.hasSentry) {
      Sentry.captureException(error, stackTrace: stack);
    }
    return false;
  };

  if (kReleaseMode) {
    // Never show the red screen to a customer.
    ErrorWidget.builder = (FlutterErrorDetails details) => const _BrandedError();
  }
}

/// Minimal, branded replacement for the default release-mode error screen.
class _BrandedError extends StatelessWidget {
  const _BrandedError();

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Color(0xFF16121C),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Something went wrong.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFE6C97A), fontSize: 16),
          ),
        ),
      ),
    );
  }
}
