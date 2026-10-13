import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'
    show CompressFormat, FlutterImageCompress;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:video_compress/video_compress.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/media_kind.dart';

/// One file that is ready for the storage bucket: the compressed bytes, the
/// extension to write them under, and — for videos — the poster frame.
@immutable
class ProcessedMedia {
  const ProcessedMedia({
    required this.bytes,
    required this.extension,
    required this.contentType,
    this.thumbnailBytes,
    this.durationSeconds,
  });

  final Uint8List bytes;

  /// Extension without the leading dot (`jpg`, `mp4`).
  final String extension;
  final String contentType;
  final Uint8List? thumbnailBytes;
  final int? durationSeconds;
}

/// Compression + thumbnail generation that runs before the upload step.
///
/// Images go through `flutter_image_compress`; videos through `video_compress`.
/// Both are native plugins, so the image is downscaled with `minWidth`/`minHeight`
/// bounds and the video is transcoded at a low quality tier. The size and
/// duration caps mirror the bucket policy, so a file the storage layer would
/// reject is refused here first — with a localized failure.
class MediaProcessor {
  const MediaProcessor();

  /// Long edge the compressor targets for images.
  static const int imageMaxWidth = 1920;
  static const int imageMaxHeight = 1080;
  static const int imageQuality = 82;

  /// Video poster frame quality (1–100) and the frame to grab.
  static const int thumbnailQuality = 60;
  static const int thumbnailPositionMs = 0;

  Future<ProcessedMedia> process({
    required XFile file,
    required MediaKind kind,
  }) =>
      kind.isVideo ? _processVideo(file) : _processImage(file);

  Future<ProcessedMedia> _processImage(XFile file) async {
    final Uint8List? bytes = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: imageMaxWidth,
      minHeight: imageMaxHeight,
      quality: imageQuality,
      format: CompressFormat.jpeg,
    );

    if (bytes == null || bytes.isEmpty) {
      throw MediaFailure(
        messageKey: 'errorMedia',
        debugMessage: 'Could not compress ${file.name}',
      );
    }
    if (bytes.length > MediaKind.maxImageBytes) {
      throw const MediaFailure(messageKey: 'errorMediaImageTooLarge');
    }

    return ProcessedMedia(
      bytes: bytes,
      extension: 'jpg',
      contentType: 'image/jpeg',
    );
  }

  Future<ProcessedMedia> _processVideo(XFile file) async {
    final MediaInfo? info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.LowQuality,
      deleteOrigin: false,
    );

    if (info == null) {
      throw MediaFailure(
        messageKey: 'errorMedia',
        debugMessage: 'Could not compress ${file.name}',
      );
    }

    final int? durationSeconds =
        info.duration == null ? null : (info.duration! / 1000).round();
    if (durationSeconds != null && durationSeconds > MediaKind.maxVideoSeconds) {
      throw const MediaFailure(messageKey: 'validateVideoTooLong');
    }

    final File compressed = info.file ?? File(file.path);
    final Uint8List bytes = await compressed.readAsBytes();
    if (bytes.isEmpty) {
      throw MediaFailure(
        messageKey: 'errorMedia',
        debugMessage: 'Empty video payload for ${file.name}',
      );
    }
    if (bytes.length > MediaKind.maxVideoBytes) {
      throw const MediaFailure(messageKey: 'errorMediaVideoTooLarge');
    }

    return ProcessedMedia(
      bytes: bytes,
      extension: 'mp4',
      contentType: 'video/mp4',
      thumbnailBytes: await _thumbnail(file.path),
      durationSeconds: durationSeconds,
    );
  }

  /// A missing poster frame is cosmetic: the video itself still uploads, so
  /// this never throws.
  Future<Uint8List?> _thumbnail(String path) async {
    try {
      return await VideoCompress.getByteThumbnail(
        path,
        quality: thumbnailQuality,
        position: thumbnailPositionMs,
      );
    } on Object {
      return null;
    }
  }
}
