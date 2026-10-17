import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Raw bytes in and out of the two public buckets.
///
/// Storage policies are the security boundary here: anon can read, only an
/// admin can insert/update/delete, and every path must live under the prefix
/// the policy allows. This class enforces nothing itself — it just builds
/// well-formed paths and lets Postgres decide.
class StorageDataSource {
  StorageDataSource(this._client);

  final SupabaseClient _client;

  static const String productMediaBucket = 'product-media';
  static const String brandBucket = 'brand';

  /// `products/{product_id}/{uuid}.{ext}` — the exact layout the storage
  /// policy requires.
  static String productMediaPath({
    required String productId,
    required String extension,
  }) => 'products/$productId/${_uuid()}${_normaliseExtension(extension)}';

  /// `brand/{name}-{uuid}.{ext}` for the logo and category covers.
  static String brandPath({required String name, required String extension}) =>
      'brand/${_safeName(name)}-${_uuid()}${_normaliseExtension(extension)}';

  /// Uploads bytes and returns the stored path (bucket-relative), which is
  /// what the catalogue rows store in `storage_path`.
  ///
  /// [retryAttempts] makes transient 5xx and connection blips self-healing;
  /// [retryController] lets the queue cancel an in-flight retry.
  Future<String> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
    int retryAttempts = 3,
    StorageRetryController? retryController,
  }) async {
    final String key = await _client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: false,
            cacheControl: '31536000',
          ),
          retryAttempts: retryAttempts,
          retryController: retryController,
        );
    // Supabase returns `bucket/path`; the catalogue columns hold the path only.
    final int slash = key.indexOf('/');
    return slash >= 0 && key.startsWith('$bucket/')
        ? key.substring(bucket.length + 1)
        : key;
  }

  Future<void> remove(String bucket, String path) =>
      _client.storage.from(bucket).remove(<String>[path]);

  /// Best-effort removal used to clean up an orphan file when the row insert
  /// that should have referenced it failed.
  Future<void> removeQuietly(String bucket, String path) async {
    try {
      await remove(bucket, path);
    } on Object {
      // The orphan-cleanup Edge Function sweeps anything left behind.
    }
  }

  static String _normaliseExtension(String raw) {
    final String ext = raw.toLowerCase().replaceFirst('.', '');
    return '.$ext';
  }

  static String _safeName(String value) {
    final String cleaned = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'asset' : cleaned;
  }

  static String _uuid() {
    // RFC-4122 v4. Storage paths only need uniqueness, but `Random.secure()`
    // costs nothing and avoids the collision surface of a seeded generator.
    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int start, int end) => bytes
        .sublist(start, end)
        .map((int v) => v.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}'
        '-${hex(10, 16)}';
  }
}
