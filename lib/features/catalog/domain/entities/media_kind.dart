import 'package:json_annotation/json_annotation.dart';

/// Mirrors the `public.media_kind` enum in Postgres.
enum MediaKind {
  @JsonValue('image')
  image,
  @JsonValue('video')
  video;

  bool get isImage => this == MediaKind.image;
  bool get isVideo => this == MediaKind.video;

  /// Storage bucket mime allow-list, per the storage policy.
  static const Map<MediaKind, List<String>> allowedMimeTypes =
      <MediaKind, List<String>>{
    MediaKind.image: <String>['image/jpeg', 'image/png', 'image/webp'],
    MediaKind.video: <String>['video/mp4'],
  };

  /// Hard size caps enforced client-side before upload and server-side by the
  /// bucket policy.
  static const int maxImageBytes = 5 * 1024 * 1024; // 5 MB after compression
  static const int maxVideoBytes = 40 * 1024 * 1024; // 40 MB
  static const int maxVideoSeconds = 60;
}
