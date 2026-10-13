// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Inquiry _$InquiryFromJson(Map<String, dynamic> json) => _Inquiry(
  id: json['id'] as String,
  channel: json['channel'] as String,
  productId: json['product_id'] as String?,
  deviceId: json['device_id'] as String?,
  productTitle: json['product_title'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$InquiryToJson(_Inquiry instance) => <String, dynamic>{
  'id': instance.id,
  'channel': instance.channel,
  'product_id': ?instance.productId,
  'device_id': ?instance.deviceId,
  'product_title': ?instance.productTitle,
  'created_at': ?instance.createdAt?.toIso8601String(),
};
