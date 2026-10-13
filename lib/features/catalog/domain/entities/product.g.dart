// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  categoryId: json['category_id'] as String,
  title: json['title'] as String,
  titleAm: json['title_am'] as String?,
  titleAr: json['title_ar'] as String?,
  description: json['description'] as String?,
  descriptionAm: json['description_am'] as String?,
  descriptionAr: json['description_ar'] as String?,
  price: (json['price'] as num).toDouble(),
  compareAtPrice: (json['compare_at_price'] as num?)?.toDouble(),
  currencyCode: json['currency_code'] as String? ?? 'ETB',
  isAvailable: json['is_available'] as bool? ?? true,
  isFeatured: json['is_featured'] as bool? ?? false,
  isPublished: json['is_published'] as bool? ?? true,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  media:
      (json['product_media'] as List<dynamic>?)
          ?.map((e) => ProductMedia.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ProductMedia>[],
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'category_id': instance.categoryId,
  'title': instance.title,
  'title_am': ?instance.titleAm,
  'title_ar': ?instance.titleAr,
  'description': ?instance.description,
  'description_am': ?instance.descriptionAm,
  'description_ar': ?instance.descriptionAr,
  'price': instance.price,
  'compare_at_price': ?instance.compareAtPrice,
  'currency_code': instance.currencyCode,
  'is_available': instance.isAvailable,
  'is_featured': instance.isFeatured,
  'is_published': instance.isPublished,
  'sort_order': instance.sortOrder,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'product_media': instance.media,
};
