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
import 'features/admin/data/admin_gate_store.dart';
import 'features/admin/presentation/providers/admin_gate_providers.dart';
import 'features/storefront/data/favourites_store.dart';
import 'features/storefront/presentation/providers/favourites_providers.dart';
import 'core/errors/app_failure.dart';
import 'core/errors/error_mapper.dart';
import 'core/errors/error_reporter.dart';
import 'core/utils/app_logger.dart';
import 'core/widgets/app_error_boundary.dart';
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

  AppLog.info('boot: flavour ${AppFlavor.current.name} → ${Env.supabaseUrl}');

  Env.assertConfigured();

  // Every repository funnels its failures through ErrorMapper.guard, so this
  // single hook is what makes a denied write or a failed sign-in visible in
  // Sentry instead of only in the UI that happened to show it.
  ErrorMapper.onFailure = (AppFailure failure, StackTrace stack) {
    if (Env.hasSentry) Sentry.captureException(failure, stackTrace: stack);
  };

  await Supabase.initialize(
    url: Env.supabaseUrl,
    // Supabase renamed "anon key" to "publishable key"; the value is the same
    // project-scoped public key. The service-role key never ships to clients.
    publishableKey: Env.supabaseAnonKey,
    debug: false,
  );
  AppLog.info('boot: supabase initialised');

  final PreferencesStore preferences = PreferencesStore(
    const FlutterSecureStorage(),
  );
  await preferences.load(PlatformDispatcher.instance.locale.languageCode);

  // The five-tap owner gate lives in the same encrypted store. Loading it here
  // lets the router read the unlocked flag synchronously on the first frame.
  final AdminGateStore adminGate = AdminGateStore(const FlutterSecureStorage());
  await adminGate.load();

  // The customer's favourites live in the same store, for the same reason.
  final FavouritesStore favourites = FavouritesStore(
    const FlutterSecureStorage(),
  );
  await favourites.load();

  _installErrorHandlers();

  AppLog.info(
    Env.hasSentry
        ? 'boot: sentry enabled (${AppFlavor.current.name})'
        : 'boot: no sentry dsn — failures are logged only',
  );

  if (Env.hasSentry) {
    await SentryFlutter.init((SentryFlutterOptions options) {
      options
        ..dsn = Env.sentryDsn
        ..environment = AppFlavor.current.name
        ..tracesSampleRate = AppFlavor.current.isProd ? 0.2 : 1.0
        ..attachStacktrace = true
        ..sendDefaultPii = false;
    }, appRunner: () => _run(preferences, adminGate, favourites));
  } else {
    _run(preferences, adminGate, favourites);
  }
}

void _run(
  PreferencesStore preferences,
  AdminGateStore adminGate,
  FavouritesStore favourites,
) {
  runApp(
    ProviderScope(
      overrides: [
        // Both stores are pre-loaded, so their providers can be synchronous and
        // the first frame already has the right locale, theme and gate state.
        preferencesStoreProvider.overrideWithValue(preferences),
        adminGateStoreProvider.overrideWithValue(adminGate),
        favouritesStoreProvider.overrideWithValue(favourites),
      ],
      child: const AmuApp(),
    ),
  );
}

void _installErrorHandlers() {
  final FlutterExceptionHandler? previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    // The log/Sentry sink is the only place that reports; `presentError` only
    // decides what a debug console prints.
    reportFlutterError(details);
    if (kDebugMode) FlutterError.presentError(details);
    previous?.call(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppErrorReporter.report(error, stack, context: 'platform error');
    return false;
  };

  if (kReleaseMode) {
    // Never show the red screen to a customer. Inside an `AppErrorBoundary`
    // this card also carries a working Retry.
    ErrorWidget.builder = (FlutterErrorDetails details) =>
        const BrandedErrorFallback();
  }
}
