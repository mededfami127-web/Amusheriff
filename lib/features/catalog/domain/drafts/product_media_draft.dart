import 'package:flutter/foundation.dart';

import '../entities/media_kind.dart';

/// Write-side DTO for the `product_media` table.
@immutable
class ProductMediaDraft {
  const ProductMediaDraft({
    required this.productId,
    required this.kind,
    required this.storagePath,
    this.thumbnailPath,
    this.durationSeconds,
    this.isCover = false,
    this.sortOrder = 0,
  });

  final String productId;
  final MediaKind kind;
  final String storagePath;
  final String? thumbnailPath;
  final int? durationSeconds;
  final bool isCover;
  final int sortOrder;

  Map<String, dynamic> toInsert() => <String, dynamic>{
        'product_id': productId,
        'kind': kind.name,
        'storage_path': storagePath,
        'thumbnail_path': _nullIfBlank(thumbnailPath),
        'duration_seconds': durationSeconds,
        'is_cover': isCover,
        'sort_order': sortOrder,
      };

  Map<String, dynamic> toUpdate() => <String, dynamic>{
        'kind': kind.name,
        'storage_path': storagePath,
        'thumbnail_path': _nullIfBlank(thumbnailPath),
        'duration_seconds': durationSeconds,
        'is_cover': isCover,
        'sort_order': sortOrder,
      };
}

String? _nullIfBlank(String? value) {
  final String v = (value ?? '').trim();
  return v.isEmpty ? null : v;
}
