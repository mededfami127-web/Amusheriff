import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_kind.dart';

part 'product_media.freezed.dart';
part 'product_media.g.dart';

/// One image or short video attached to a product.
@freezed
abstract class ProductMedia with _$ProductMedia {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory ProductMedia({
    required String id,
    required String productId,
    required MediaKind kind,
    required String storagePath,
    String? thumbnailPath,
    int? durationSeconds,
    @Default(false) bool isCover,
    @Default(0) int sortOrder,
    DateTime? createdAt,
  }) = _ProductMedia;

  const ProductMedia._();

  factory ProductMedia.fromJson(Map<String, dynamic> json) =>
      _$ProductMediaFromJson(json);

  bool get isVideo => kind.isVideo;
  bool get isImage => kind.isImage;
  bool get hasThumbnail =>
      thumbnailPath != null && thumbnailPath!.isNotEmpty;

  Duration? get duration => durationSeconds == null
      ? null
      : Duration(seconds: durationSeconds!);
}
