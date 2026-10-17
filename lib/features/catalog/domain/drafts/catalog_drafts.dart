import 'package:flutter/foundation.dart';

import '../entities/media_kind.dart';

/// Write-side DTOs for the catalogue.
///
/// Deliberately plain (no JSON code-gen): these are *inputs*, so they only ever
/// serialise outward via [toRow]. Entities stay read-side and freezed.

@immutable
class CategoryDraft {
  const CategoryDraft({
    required this.name,
    required this.slug,
    this.nameAm,
    this.nameAr,
    this.coverPath,
    this.parentId,
    this.sortOrder = 0,
    this.isVisible = true,
  });

  final String name;
  final String slug;
  final String? nameAm;
  final String? nameAr;
  final String? coverPath;

  /// Set to make this row a subcategory of [parentId]; `null` keeps it
  /// top-level. The database keeps the tree one level deep.
  final String? parentId;
  final int sortOrder;
  final bool isVisible;

  /// Full row for insert. `updated_at` is handled by the DB trigger.
  Map<String, dynamic> toInsert() => <String, dynamic>{
    'name': name.trim(),
    'slug': slug.trim(),
    'name_am': _nullIfBlank(nameAm),
    'name_ar': _nullIfBlank(nameAr),
    'cover_path': _nullIfBlank(coverPath),
    // Sent only when it is set: a project that has not applied
    // `20260101000700_subcategories.sql` yet keeps creating plain categories
    // instead of failing on a column it does not have. A subcategory needs the
    // migration, and says so through the usual Postgres error if it is missing.
    if (parentId != null) 'parent_id': parentId,
    'sort_order': sortOrder,
    'is_visible': isVisible,
  };

  /// Same shape for update — sending nulls clears the optional columns.
  Map<String, dynamic> toUpdate() => toInsert();
}

@immutable
class ProductDraft {
  const ProductDraft({
    required this.categoryId,
    required this.title,
    required this.price,
    this.titleAm,
    this.titleAr,
    this.description,
    this.descriptionAm,
    this.descriptionAr,
    this.compareAtPrice,
    this.currencyCode = 'ETB',
    this.isAvailable = true,
    this.isFeatured = false,
    this.isPublished = true,
    this.sortOrder = 0,
  });

  final String categoryId;
  final String title;
  final double price;
  final String? titleAm;
  final String? titleAr;
  final String? description;
  final String? descriptionAm;
  final String? descriptionAr;
  final double? compareAtPrice;
  final String currencyCode;
  final bool isAvailable;
  final bool isFeatured;
  final bool isPublished;
  final int sortOrder;

  Map<String, dynamic> toInsert() => <String, dynamic>{
    'category_id': categoryId,
    'title': title.trim(),
    'title_am': _nullIfBlank(titleAm),
    'title_ar': _nullIfBlank(titleAr),
    'description': _nullIfBlank(description),
    'description_am': _nullIfBlank(descriptionAm),
    'description_ar': _nullIfBlank(descriptionAr),
    'price': price,
    'compare_at_price': compareAtPrice,
    'currency_code': currencyCode,
    'is_available': isAvailable,
    'is_featured': isFeatured,
    'is_published': isPublished,
    'sort_order': sortOrder,
  };

  Map<String, dynamic> toUpdate() => toInsert();
}

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
