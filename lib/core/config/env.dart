import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'flavors.dart';

/// Compile-time configuration, injected with `--dart-define` or
/// `--dart-define-from-file` (see `config/*.json.example`).
///
/// These are deliberately `const String.fromEnvironment` reads so the tree
/// shaker can strip unused flavors from a production binary.
abstract final class Env {
  const Env._();

  static const String _supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const String _logLevel =
      String.fromEnvironment('LOG_LEVEL', defaultValue: 'info');
  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Supabase project URL, e.g. `https://abcdefgh.supabase.co`.
  static String get supabaseUrl => _supabaseUrl.trim();

  /// Supabase **anon** key. The service-role key must never reach the client.
  static String get supabaseAnonKey => _supabaseAnonKey.trim();

  /// Sentry DSN; empty in local/dev runs unless explicitly provided.
  static String get sentryDsn => _sentryDsn.trim();

  /// Base URL for Supabase Edge Functions (used by the rate-limited inquiry
  /// endpoint in Part 2). Falls back to the project's own `/functions/v1`.
  static String get functionsBaseUrl =>
      _apiBaseUrl.trim().isNotEmpty ? _apiBaseUrl.trim() : '$supabaseUrl/functions/v1';

  static String get logLevel => _logLevel;

  static bool get hasSentry => sentryDsn.isNotEmpty;

  /// True when the binary has been configured with a backend.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Throws a descriptive [StateError] when the build is missing configuration.
  /// Called once from `bootstrap()` so failures are loud and early rather than
  /// surfacing as opaque network errors later.
  static void assertConfigured() {
    final List<String> missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing compile-time configuration for flavor '
        '"${AppFlavor.current.name}": ${missing.join(', ')}.\n'
        'Build with:\n'
        '  flutter run --dart-define-from-file=config/${AppFlavor.current.name}.json\n'
        'and ensure the file defines ${missing.join(' and ')}.',
      );
    }
    if (looksLikeServiceRoleKey(supabaseAnonKey)) {
      throw StateError(
        'SUPABASE_ANON_KEY is a service-role key. Ship only the anon (or '
        'publishable) key to clients; the service-role key bypasses every row '
        'level security policy in the database.',
      );
    }
  }

  /// Detects a Supabase **service-role** key passed as the anon key.
  ///
  /// Legacy Supabase keys are JWTs whose `role` claim says who they are, so the
  /// only reliable check is to read that claim: an anon key and a service-role
  /// key are the same length and differ *solely* in `role`. Newer
  /// `sb_publishable_…` / `sb_secret_…` keys are not JWTs at all, so those are
  /// matched by prefix instead.
  @visibleForTesting
  static bool looksLikeServiceRoleKey(String key) {
    if (key.startsWith('sb_secret_')) return true;
    final List<String> parts = key.split('.');
    // Not a JWT (e.g. sb_publishable_…): nothing to decode.
    if (parts.length != 3) return false;
    try {
      final String payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final Object? decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> &&
          decoded['role'] == 'service_role';
    } on Object {
      // Malformed token: not something we can classify, so don't block startup.
      return false;
    }
  }
}
