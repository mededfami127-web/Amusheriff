import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/backend_asset_status.dart';
import '../../../core/network/storage_urls.dart';

export '../../../core/errors/backend_asset_status.dart'
    show SystemAssetStatus, classifyBackendFailure;

/// What a system check is about.
enum SystemAssetKind { table, storage, function }

/// One probe result: an asset this build depends on, and its state.
class SystemAssetCheck {
  const SystemAssetCheck({
    required this.kind,
    required this.name,
    required this.status,
    this.detail,
  });

  final SystemAssetKind kind;
  final String name;
  final SystemAssetStatus status;

  /// The server's own words, shown small and muted so it can be copied into a
  /// bug report. Never rendered as the headline.
  final String? detail;

  /// True when the app can work with this asset in the state it is in.
  bool get isUsable =>
      status == SystemAssetStatus.ok || status == SystemAssetStatus.restricted;
}

/// How long a single probe may take before it counts as unreachable.
const Duration kSystemProbeTimeout = Duration(seconds: 12);

/// Probes every backend asset this build depends on, in parallel.
///
/// Read-only and cheapest-form (one row, one file listing, one no-op call), so
/// running it against production is safe.
Future<List<SystemAssetCheck>> runSystemChecks(SupabaseClient client) async {
  return Future.wait(<Future<SystemAssetCheck>>[
    for (final String table in kProbedTables) _probeTable(client, table),
    for (final String bucket in kProbedBuckets) _probeBucket(client, bucket),
    _probeFunction(client),
  ]);
}

/// Tables the app reads or writes. Order is the order the page shows.
const List<String> kProbedTables = <String>[
  'categories',
  'products',
  'product_media',
  'contact_links',
  'inquiries',
  'site_settings',
  'text_overrides',
  'profiles',
];

/// Storage buckets the migration creates, from the app's own constants.
const List<String> kProbedBuckets = <String>[
  StorageUrls.productMediaBucket,
  StorageUrls.brandBucket,
];

/// The one Edge Function in `supabase/functions/`.
const String kProbedFunction = 'inquiry';

Future<SystemAssetCheck> _probeTable(
  SupabaseClient client,
  String table,
) async {
  try {
    await client.from(table).select().limit(1).timeout(kSystemProbeTimeout);
    return SystemAssetCheck(
      kind: SystemAssetKind.table,
      name: table,
      status: SystemAssetStatus.ok,
    );
  } catch (error) {
    return SystemAssetCheck(
      kind: SystemAssetKind.table,
      name: table,
      status: classifyBackendFailure(error),
      detail: _detailOf(error),
    );
  }
}

Future<SystemAssetCheck> _probeBucket(
  SupabaseClient client,
  String bucket,
) async {
  try {
    await client.storage
        .from(bucket)
        .list(searchOptions: const SearchOptions(limit: 1))
        .timeout(kSystemProbeTimeout);
    return SystemAssetCheck(
      kind: SystemAssetKind.storage,
      name: bucket,
      status: SystemAssetStatus.ok,
    );
  } catch (error) {
    return SystemAssetCheck(
      kind: SystemAssetKind.storage,
      name: bucket,
      status: classifyBackendFailure(error),
      detail: _detailOf(error),
    );
  }
}

Future<SystemAssetCheck> _probeFunction(SupabaseClient client) async {
  try {
    // The function rejects this payload with a validation error, which is
    // fine: any answer proves it is deployed.
    await client.functions
        .invoke(kProbedFunction, body: const <String, Object?>{'probe': true})
        .timeout(kSystemProbeTimeout);
    return const SystemAssetCheck(
      kind: SystemAssetKind.function,
      name: kProbedFunction,
      status: SystemAssetStatus.ok,
    );
  } catch (error) {
    return SystemAssetCheck(
      kind: SystemAssetKind.function,
      name: kProbedFunction,
      status: classifyBackendFailure(error),
      detail: _detailOf(error),
    );
  }
}

/// The server's own wording, trimmed to something a tile can show.
String? _detailOf(Object error) {
  final String raw = switch (error) {
    PostgrestException() => error.message,
    StorageException() => error.message,
    AuthException() => error.message,
    FunctionException() =>
      error.details?.toString() ?? error.reasonPhrase ?? '',
    _ => error.toString(),
  };
  final String trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  return trimmed.length > 160 ? '${trimmed.substring(0, 157)}…' : trimmed;
}
