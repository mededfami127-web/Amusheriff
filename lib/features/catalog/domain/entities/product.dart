import 'package:freezed_annotation/freezed_annotation.dart';

import 'product_media.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// A catalogue product.
@freezed
abstract class Product with _$Product {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory Product({
    required String id,
    required String categoryId,
    required String title,
    String? titleAm,
    String? titleAr,
    String? description,
    String? descriptionAm,
    String? descriptionAr,
    required double price,
    double? compareAtPrice,
    @Default('ETB') String currencyCode,
    @Default(true) bool isAvailable,
    @Default(false) bool isFeatured,
    @Default(true) bool isPublished,
    @Default(0) int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,

    /// Embedded media, present when the query selected `product_media(*)`.
    @JsonKey(name: 'product_media')
    @Default(<ProductMedia>[])
    List<ProductMedia> media,
  }) = _Product;

  const Product._();

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  // ── Localized text ────────────────────────────────────────────────────────
  String titleFor(String languageCode) => switch (languageCode) {
        'am' => _first(<String?>[titleAm, title, titleAr]),
        'ar' => _first(<String?>[titleAr, title, titleAm]),
        _ => _first(<String?>[title, titleAm, titleAr]),
      };

  String descriptionFor(String languageCode) => switch (languageCode) {
        'am' => _first(<String?>[descriptionAm, description, descriptionAr]),
        'ar' => _first(<String?>[descriptionAr, description, descriptionAm]),
        _ => _first(<String?>[description, descriptionAm, descriptionAr]),
      };

  // ── Pricing ───────────────────────────────────────────────────────────────
  bool get hasDiscount =>
      compareAtPrice != null && compareAtPrice! > price && price > 0;

  int? get discountPercent => hasDiscount
      ? (((compareAtPrice! - price) / compareAtPrice!) * 100).round()
      : null;

  // ── Media ─────────────────────────────────────────────────────────────────
  /// The cover image, or the first image, or the first item of any kind.
  ProductMedia? get coverMedia {
    if (media.isEmpty) return null;
    for (final ProductMedia m in media) {
      if (m.isCover) return m;
    }
    for (final ProductMedia m in media) {
      if (m.isImage) return m;
    }
    return media.first;
  }

  String? get coverPath => coverMedia?.storagePath;

  List<ProductMedia> get images =>
      media.where((ProductMedia m) => m.isImage).toList(growable: false);

  List<ProductMedia> get videos =>
      media.where((ProductMedia m) => m.isVideo).toList(growable: false);

  bool get isOrderable => isAvailable && isPublished;
}

String _first(List<String?> values) {
  for (final String? v in values) {
    if (v != null && v.trim().isNotEmpty) return v;
  }
  return '';
}
