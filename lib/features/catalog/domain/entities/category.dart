import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// A storefront category (e.g. "Majlis Sofas").
@freezed
abstract class Category with _$Category {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory Category({
    required String id,
    required String name,
    String? nameAm,
    String? nameAr,
    required String slug,
    String? coverPath,
    String? parentId,
    @Default(0) int sortOrder,
    @Default(true) bool isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,

    /// Populated by the `v_categories_with_counts` view; not a column.
    @Default(0) int productCount,
  }) = _Category;

  const Category._();

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  /// Name in the requested locale, falling back to English then any value.
  String nameFor(String languageCode) {
    return switch (languageCode) {
      'am' => _firstNonEmpty(<String?>[nameAm, name, nameAr]),
      'ar' => _firstNonEmpty(<String?>[nameAr, name, nameAm]),
      _ => _firstNonEmpty(<String?>[name, nameAm, nameAr]),
    };
  }

  bool get hasCover => coverPath != null && coverPath!.isNotEmpty;
}

String _firstNonEmpty(List<String?> values) =>
    values.firstWhere(
      (String? v) => v != null && v.trim().isNotEmpty,
      orElse: () => '',
    ) ??
    '';
