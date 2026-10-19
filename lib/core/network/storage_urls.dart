import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client_provider.dart';

part 'storage_urls.g.dart';

/// Turns bucket-relative paths into public URLs.
///
/// Both buckets are public-read (writes are admin-only via storage policies),
/// so listing pages can be rendered straight from these URLs and the CDN can
/// cache them. Nothing sensitive is ever stored in a public bucket.
class StorageUrls {
  StorageUrls(this._client);

  final SupabaseClient _client;

  static const String productMediaBucket = 'product-media';
  static const String brandBucket = 'brand';

  /// Full-size product image or video poster.
  String productMedia(String path) =>
      _client.storage.from(productMediaBucket).getPublicUrl(path);

  /// A width-limited transform for grids and rails. Supabase serves the
  /// transformed variant from cache, which keeps list payloads small.
  String productMediaThumb(String path, {int width = 480}) => _client.storage
      .from(productMediaBucket)
      .getPublicUrl(
        path,
        transform: TransformOptions(
          width: width,
          resize: ResizeMode.cover,
          quality: 78,
        ),
      );

  /// Logo and category covers.
  String brand(String path) =>
      _client.storage.from(brandBucket).getPublicUrl(path);

  /// Public URL for a category cover held in the `brand` bucket.
  ///
  /// Kept explicit (rather than free-form `brand(path)`) so the storefront
  /// thumbnails and the admin cover preview share one method and one bucket.
  String categoryCover(String path) => brand(path);

  static bool isRemote(String value) =>
      value.startsWith('http://') || value.startsWith('https://');
}

@Riverpod(keepAlive: true)
StorageUrls storageUrls(Ref ref) =>
    StorageUrls(ref.watch(supabaseClientProvider));
