import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/media_kind.dart';
import '../../domain/entities/product_media.dart';

/// Efficient, dependency-light image processing used for principal compression
/// and video thumbnail generation before the upload step.
class MediaProcessor {
  /// Returns the original file unchanged when it is already small enough.
  Future<File> processPrincipal({
    required ProductMedia item,
    required int maxWidth,
    required bool keepAspectRatio,
  }) async {
    final File source = File(item.localPath);
    final String ext = p.extension(source.path).toLowerCase();
    final img.Image? image = _loadImage(source, ext);
    if (image == null) return source;

    final int targetWidth = keepAspectRatio ? maxWidth : image.width;
    final int targetHeight = keepAspectRatio ? (image.height * maxWidth / image.width).round() : image.height;

    final img.Image resized = _resize(image, targetWidth, targetHeight);

    final Directory destDir = await getApplicationCacheDirectory();
    final String baseName = p.basenameWithoutExtension(item.localPath);
    final String destPath = p.join(destDir.path, '${baseName}_processed${ext}');
    final File dest = File(destPath);
    await dest.create(recursive: true);
    _saveImage(resized, dest, ext);
    return dest;
  }

  /// Decodes the first frame of a video into a still image for the gallery
  /// thumbnail. Returns null when the file is not a decodable image/video.
  Future<File?> processThumbnail({required String localPath}) async {
    final File source = File(localPath);
    final String ext = p.extension(source.path).toLowerCase();
    if (ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.webp') {
      final img.Image? image = _loadImage(source, ext);
      if (image == null) return null;
      final Directory destDir = await getApplicationCacheDirectory();
      final String destPath = p.join(
        destDir.path,
        '${p.basenameWithoutExtension(source.path)}.thumbnail${ext}',
      );
      final File dest = File(destPath);
      await dest.create(recursive: true);
      _saveImage(image, dest, ext);
      return dest;
    }

    // For video files, try to extract the first frame via `ffmpeg`.
    final List<String> cmd = <String>[
      'ffmpeg',
      '-y',
      '-i',
      source.path,
      '-frames:v',
      '1',
      '-vf',
      'scale=trunc(iw/2)*2:trunc(ih/2)*2',
      '-q:v',
      '2',
      p.join(p.dirname(source.path), 'thumb_${p.basenameWithoutExtension(source.path)}.jpg'),
    ];

    final ProcessResult result = await Process.run(
      cmd[0],
      cmd.sublist(1),
      runInShell: true,
    );

    if (result.exitCode != 0) return null;

    final String thumbPath = cmd.last;
    return File(thumbPath);
  }

  static img.Image? _loadImage(File file, String ext) {
    try {
      final Uint8List bytes = file.readAsBytesSync();
      if (ext == '.jpg' || ext == '.jpeg') return img.decodeJpg(bytes);
      if (ext == '.png') return img.decodePng(bytes);
      if (ext == '.webp') return img.decodeWebp(bytes);
      if (ext == '.gif') return img.decodeGif(bytes);
    } catch (_) {
      return null;
    }
    return null;
  }

  static void _saveImage(img.Image image, File file, String ext) {
    if (ext == '.jpg' || ext == '.jpeg') {
      file.writeAsBytesSync(img.encodeJpg(image));
    } else if (ext == '.png') {
      file.writeAsBytesSync(img.encodePng(image));
    } else if (ext == '.webp') {
      file.writeAsBytesSync(img.encodeWebp(image));
    }
  }

  static img.Image _resize(img.Image image, int targetWidth, int targetHeight) {
    if (image.width == targetWidth && image.height == targetHeight) return image;
    return img.copyResize(image, width: targetWidth, height: targetHeight);
  }
}
