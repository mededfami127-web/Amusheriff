import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'env.dart';
import 'flavors.dart';

/// Immutable runtime configuration object, exposed through [appConfigProvider]
/// so widgets never read compile-time constants directly.
@immutable
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.sentryDsn,
    required this.functionsBaseUrl,
    required this.supportsRealtime,
  });

  final AppFlavor flavor;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String sentryDsn;
  final String functionsBaseUrl;

  /// Realtime is enabled on all platforms except web debug builds, where the
  /// extra websocket can slow down hot reload.
  final bool supportsRealtime;

  factory AppConfig.fromEnvironment() => AppConfig(
    flavor: AppFlavor.current,
    supabaseUrl: Env.supabaseUrl,
    supabaseAnonKey: Env.supabaseAnonKey,
    sentryDsn: Env.sentryDsn,
    functionsBaseUrl: Env.functionsBaseUrl,
    supportsRealtime: !(kIsWeb && kDebugMode),
  );

  bool get hasSentry => sentryDsn.isNotEmpty;

  /// Tables the storefront subscribes to. Keeping the list in one place makes
  /// the realtime wiring auditable.
  static const List<String> realtimeTables = <String>[
    'categories',
    'products',
    'product_media',
    'contact_links',
    'site_settings',
  ];

  @override
  bool operator ==(Object other) =>
      other is AppConfig &&
      other.flavor == flavor &&
      other.supabaseUrl == supabaseUrl &&
      other.supabaseAnonKey == supabaseAnonKey &&
      other.sentryDsn == sentryDsn &&
      other.functionsBaseUrl == functionsBaseUrl &&
      other.supportsRealtime == supportsRealtime;

  @override
  int get hashCode => Object.hash(
    flavor,
    supabaseUrl,
    supabaseAnonKey,
    sentryDsn,
    functionsBaseUrl,
    supportsRealtime,
  );
}

/// Overridden in `bootstrap()` once the environment has been validated.
final Provider<AppConfig> appConfigProvider = Provider<AppConfig>(
  (Ref ref) => AppConfig.fromEnvironment(),
  name: 'appConfigProvider',
);
