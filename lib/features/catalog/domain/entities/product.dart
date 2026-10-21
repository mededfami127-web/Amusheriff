import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/localized_text.dart';
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
    String? titleOm,
    String? description,
    String? descriptionAm,
    String? descriptionAr,
    String? descriptionOm,
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

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  // ── Localized text ────────────────────────────────────────────────────────
  // Selected language → English → any language that has text. Every screen
  // reads the title through here, so no widget has to know the column names.
  String titleFor(String languageCode) => localizedText(
    languageCode: languageCode,
    english: title,
    amharic: titleAm,
    arabic: titleAr,
    oromo: titleOm,
  );

  String descriptionFor(String languageCode) => localizedText(
    languageCode: languageCode,
    english: description ?? '',
    amharic: descriptionAm,
    arabic: descriptionAr,
    oromo: descriptionOm,
  );

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
