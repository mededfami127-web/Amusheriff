import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/media_kind.dart';

/// Result of preparing one picked file for storage.
class ProcessedMedia {
  const ProcessedMedia({
    required this.bytes,
    required this.contentType,
    required this.extension,
    this.thumbnailBytes,
    this.durationSeconds,
    this.originalSize,
  });

  final Uint8List bytes;
  final String contentType;
  final String extension;
  final Uint8List? thumbnailBytes;
  final int? durationSeconds;
  final int? originalSize;
}

/// Enforces the storage policy *before* a byte is uploaded, and keeps list
/// payloads small by re-encoding images.
///
/// Limits mirror the buckets: images 5 MB after compression, videos 40 MB and
/// 60 seconds, and only `image/jpeg`, `image/png`, `image/webp` and `video/mp4`
/// are accepted. Validating here means the user sees a clear message instead
/// of an opaque 413 from Storage.
class MediaProcessor {
  const MediaProcessor();

  static const int maxImageBytes = 5 * 1024 * 1024;
  static const int maxVideoBytes = 40 * 1024 * 1024;
  static const int maxVideoSeconds = 60;

  static const Map<String, String> _imageTypes = <String, String>{
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  static const Map<String, String> _videoTypes = <String, String>{
    'mp4': 'video/mp4',
  };

  Future<ProcessedMedia> process({
    required XFile file,
    required MediaKind kind,
  }) async {
    final String ext = _extensionOf(file.name);
    return switch (kind) {
      MediaKind.image => _processImage(file, ext),
      MediaKind.video => _processVideo(file, ext),
    };
  }

  Future<ProcessedMedia> _processImage(XFile file, String ext) async {
    final String? contentType = _imageTypes[ext];
    if (contentType == null) {
      throw const ValidationFailure(
        messageKey: 'errorMediaUnsupportedImage',
        fieldErrors: <String, String>{'file': 'errorMediaUnsupportedImage'},
      );
    }

    final Uint8List source = await file.readAsBytes();
    if (source.isEmpty) throw const MediaFailure();

    Uint8List output = source;
    if (!kIsWeb) {
      output = await _compressImage(source) ?? source;
    }

    if (output.lengthInBytes > maxImageBytes) {
      throw const ValidationFailure(
        messageKey: 'errorMediaImageTooLarge',
        fieldErrors: <String, String>{'file': 'errorMediaImageTooLarge'},
      );
    }

    return ProcessedMedia(
      bytes: output,
      contentType: contentType,
      extension: ext,
      originalSize: source.lengthInBytes,
    );
  }

  Future<ProcessedMedia> _processVideo(XFile file, String ext) async {
    final String? contentType = _videoTypes[ext];
    if (contentType == null) {
      throw const ValidationFailure(
        messageKey: 'errorMediaUnsupportedVideo',
        fieldErrors: <String, String>{'file': 'errorMediaUnsupportedVideo'},
      );
    }

    final String path = file.path;
    // Video re-encoding needs a real filesystem path, so on web the original
    // is uploaded after the size check rather than silently dropped.
    if (kIsWeb || path.isEmpty) {
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > maxVideoBytes) {
        throw const ValidationFailure(
          messageKey: 'errorMediaVideoTooLarge',
          fieldErrors: <String, String>{'file': 'errorMediaVideoTooLarge'},
        );
      }
      return ProcessedMedia(
        bytes: bytes,
        contentType: contentType,
        extension: ext,
        originalSize: bytes.lengthInBytes,
      );
    }

    if (!File(path).existsSync()) {
      throw const ValidationFailure(
        messageKey: 'validateVideoUnreadable',
        fieldErrors: <String, String>{'file': 'validateVideoUnreadable'},
      );
    }

    final MediaInfo info = await VideoCompress.getMediaInfo(path);
    // `MediaInfo.duration` is reported in milliseconds.
    final double? durationMs = info.duration;
    final int? durationSeconds =
        durationMs == null ? null : (durationMs / 1000).round();

    if (durationSeconds != null && durationSeconds > maxVideoSeconds) {
      throw const ValidationFailure(
        messageKey: 'validateVideoTooLong',
        fieldErrors: <String, String>{'file': 'validateVideoTooLong'},
      );
    }

    final Uint8List original = await File(path).readAsBytes();
    if (original.lengthInBytes > maxVideoBytes) {
      throw const ValidationFailure(
        messageKey: 'errorMediaVideoTooLarge',
        fieldErrors: <String, String>{'file': 'errorMediaVideoTooLarge'},
      );
    }

    Uint8List compressed = original;
    try {
      final MediaInfo? reduced = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );
      final String? reducedPath = reduced?.file?.path;
      if (reducedPath != null && File(reducedPath).existsSync()) {
        final Uint8List bytes = await File(reducedPath).readAsBytes();
        if (bytes.isNotEmpty && bytes.lengthInBytes <= original.lengthInBytes) {
          compressed = bytes;
        }
      }
    } on Object {
      // Compression is best-effort: an uncompressed but valid upload beats a
      // failed one.
    }

    if (compressed.lengthInBytes > maxVideoBytes) {
      throw const ValidationFailure(
        messageKey: 'errorMediaVideoTooLarge',
        fieldErrors: <String, String>{'file': 'errorMediaVideoTooLarge'},
      );
    }

    return ProcessedMedia(
      bytes: compressed,
      contentType: contentType,
      extension: ext,
      durationSeconds: durationSeconds,
      thumbnailBytes: await _thumbnail(path),
      originalSize: original.lengthInBytes,
    );
  }

  Future<Uint8List?> _compressImage(Uint8List source) async {
    try {
      final Uint8List result = await FlutterImageCompress.compressWithList(
        source,
        quality: 82,
        minWidth: 1600,
        minHeight: 1600,
        keepExif: false,
      );
      return result.isEmpty ? null : result;
    } on Object {
      return null;
    }
  }

  /// Poster frame shown in the gallery and in admin grids.
  Future<Uint8List?> _thumbnail(String path) async {
    try {
      return await VideoCompress.getByteThumbnail(
        path,
        // `position` is milliseconds into the clip.
        position: 1000,
        quality: 70,
      );
    } on Object {
      return null;
    }
  }

  static String _extensionOf(String name) {
    final int dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }
}
