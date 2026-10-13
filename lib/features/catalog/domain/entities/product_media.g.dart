// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductMedia _$ProductMediaFromJson(Map<String, dynamic> json) =>
    _ProductMedia(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      kind: $enumDecode(_$MediaKindEnumMap, json['kind']),
      storagePath: json['storage_path'] as String,
      thumbnailPath: json['thumbnail_path'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      isCover: json['is_cover'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ProductMediaToJson(_ProductMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'kind': _$MediaKindEnumMap[instance.kind]!,
      'storage_path': instance.storagePath,
      'thumbnail_path': ?instance.thumbnailPath,
      'duration_seconds': ?instance.durationSeconds,
      'is_cover': instance.isCover,
      'sort_order': instance.sortOrder,
      'created_at': ?instance.createdAt?.toIso8601String(),
    };

const _$MediaKindEnumMap = {MediaKind.image: 'image', MediaKind.video: 'video'};
