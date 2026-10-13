// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContactLink _$ContactLinkFromJson(Map<String, dynamic> json) => _ContactLink(
  id: json['id'] as String,
  kind: $enumDecode(_$ContactKindEnumMap, json['kind']),
  label: json['label'] as String,
  value: json['value'] as String,
  isPrimary: json['is_primary'] as bool? ?? false,
  isVisible: json['is_visible'] as bool? ?? true,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ContactLinkToJson(_ContactLink instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$ContactKindEnumMap[instance.kind]!,
      'label': instance.label,
      'value': instance.value,
      'is_primary': instance.isPrimary,
      'is_visible': instance.isVisible,
      'sort_order': instance.sortOrder,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'updated_at': ?instance.updatedAt?.toIso8601String(),
    };

const _$ContactKindEnumMap = {
  ContactKind.whatsapp: 'whatsapp',
  ContactKind.telegram: 'telegram',
  ContactKind.phone: 'phone',
  ContactKind.email: 'email',
  ContactKind.instagram: 'instagram',
  ContactKind.facebook: 'facebook',
  ContactKind.tiktok: 'tiktok',
  ContactKind.youtube: 'youtube',
  ContactKind.website: 'website',
  ContactKind.location: 'location',
  ContactKind.other: 'other',
};
