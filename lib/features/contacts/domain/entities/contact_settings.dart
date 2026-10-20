import 'package:flutter/foundation.dart';

/// The owner's own contact channels, backed by the single-row
/// `public.admin_contact_settings` table (id = 1).
///
/// The storefront only renders the fields that are non-empty, so the owner can
/// publish just the channels they use without any client-side filtering rules.
@immutable
class ContactSettings {
  const ContactSettings({
    this.ownerPhone = '',
    this.ownerEmail = '',
    this.whatsappNumber = '',
    this.telegramHandle = '',
    this.instagramHandle = '',
    this.facebookHandle = '',
    this.tiktokHandle = '',
    this.youtubeHandle = '',
    this.websiteUrl = '',
  });

  /// Before the row arrives, or when the owner has not filled anything in.
  static const ContactSettings empty = ContactSettings();

  final String ownerPhone;
  final String ownerEmail;
  final String whatsappNumber;
  final String telegramHandle;
  final String instagramHandle;
  final String facebookHandle;
  final String tiktokHandle;
  final String youtubeHandle;
  final String websiteUrl;

  factory ContactSettings.fromJson(Map<String, dynamic> json) =>
      ContactSettings(
        ownerPhone: _text(json['owner_phone']),
        ownerEmail: _text(json['owner_email']),
        whatsappNumber: _text(json['whatsapp_number']),
        telegramHandle: _text(json['telegram_handle']),
        instagramHandle: _text(json['instagram_handle']),
        facebookHandle: _text(json['facebook_handle']),
        tiktokHandle: _text(json['tiktok_handle']),
        youtubeHandle: _text(json['youtube_handle']),
        websiteUrl: _text(json['website_url']),
      );

  /// Row payload for the singleton upsert. Empty fields are written as `null`
  /// so the storefront's "only non-empty entries" rule is also true in the DB.
  Map<String, dynamic> toRow() => <String, dynamic>{
    'id': 1,
    'owner_phone': _nullable(ownerPhone),
    'owner_email': _nullable(ownerEmail),
    'whatsapp_number': _nullable(whatsappNumber),
    'telegram_handle': _nullable(telegramHandle),
    'instagram_handle': _nullable(instagramHandle),
    'facebook_handle': _nullable(facebookHandle),
    'tiktok_handle': _nullable(tiktokHandle),
    'youtube_handle': _nullable(youtubeHandle),
    'website_url': _nullable(websiteUrl),
  };

  ContactSettings copyWith({
    String? ownerPhone,
    String? ownerEmail,
    String? whatsappNumber,
    String? telegramHandle,
    String? instagramHandle,
    String? facebookHandle,
    String? tiktokHandle,
    String? youtubeHandle,
    String? websiteUrl,
  }) => ContactSettings(
    ownerPhone: ownerPhone ?? this.ownerPhone,
    ownerEmail: ownerEmail ?? this.ownerEmail,
    whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    telegramHandle: telegramHandle ?? this.telegramHandle,
    instagramHandle: instagramHandle ?? this.instagramHandle,
    facebookHandle: facebookHandle ?? this.facebookHandle,
    tiktokHandle: tiktokHandle ?? this.tiktokHandle,
    youtubeHandle: youtubeHandle ?? this.youtubeHandle,
    websiteUrl: websiteUrl ?? this.websiteUrl,
  );

  bool get hasPhone => ownerPhone.trim().isNotEmpty;
  bool get hasEmail => ownerEmail.trim().isNotEmpty;
  bool get hasWhatsApp => whatsappNumber.trim().isNotEmpty;
  bool get hasTelegram => telegramHandle.trim().isNotEmpty;
  bool get hasInstagram => instagramHandle.trim().isNotEmpty;
  bool get hasFacebook => facebookHandle.trim().isNotEmpty;
  bool get hasTikTok => tiktokHandle.trim().isNotEmpty;
  bool get hasYouTube => youtubeHandle.trim().isNotEmpty;
  bool get hasWebsite => websiteUrl.trim().isNotEmpty;

  /// True when at least one channel can be shown to a customer.
  bool get hasAny =>
      hasPhone ||
      hasEmail ||
      hasWhatsApp ||
      hasTelegram ||
      hasInstagram ||
      hasFacebook ||
      hasTikTok ||
      hasYouTube ||
      hasWebsite;

  static String _text(Object? value) => value is String ? value.trim() : '';

  static String? _nullable(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
