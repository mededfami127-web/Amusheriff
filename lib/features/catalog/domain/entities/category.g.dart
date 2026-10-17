// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  name: json['name'] as String,
  nameAm: json['name_am'] as String?,
  nameAr: json['name_ar'] as String?,
  slug: json['slug'] as String,
  coverPath: json['cover_path'] as String?,
  parentId: json['parent_id'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  isVisible: json['is_visible'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  productCount: (json['product_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'name_am': ?instance.nameAm,
  'name_ar': ?instance.nameAr,
  'slug': instance.slug,
  'cover_path': ?instance.coverPath,
  'parent_id': ?instance.parentId,
  'sort_order': instance.sortOrder,
  'is_visible': instance.isVisible,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'product_count': instance.productCount,
};
