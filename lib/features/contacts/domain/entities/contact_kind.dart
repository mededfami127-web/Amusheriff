import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Mirrors the `public.contact_kind` enum in Postgres.
///
/// The declaration order matches the SQL enum so ordinal comparisons stay
/// meaningful if we ever need them.
enum ContactKind {
  @JsonValue('whatsapp')
  whatsapp,
  @JsonValue('telegram')
  telegram,
  @JsonValue('phone')
  phone,
  @JsonValue('email')
  email,
  @JsonValue('instagram')
  instagram,
  @JsonValue('facebook')
  facebook,
  @JsonValue('tiktok')
  tiktok,
  @JsonValue('youtube')
  youtube,
  @JsonValue('website')
  website,
  @JsonValue('location')
  location,
  @JsonValue('other')
  other;

  /// ARB key used for the default label.
  String get labelKey => switch (this) {
    ContactKind.whatsapp => 'contactWhatsApp',
    ContactKind.telegram => 'contactTelegram',
    ContactKind.phone => 'contactPhone',
    ContactKind.email => 'contactEmail',
    ContactKind.instagram => 'contactInstagram',
    ContactKind.facebook => 'contactFacebook',
    ContactKind.tiktok => 'contactTikTok',
    ContactKind.youtube => 'contactYouTube',
    ContactKind.website => 'contactWebsite',
    ContactKind.location => 'contactLocation',
    ContactKind.other => 'contactOther',
  };

  IconData get icon => switch (this) {
    ContactKind.whatsapp => Icons.chat_bubble_outline_rounded,
    ContactKind.telegram => Icons.send_rounded,
    ContactKind.phone => Icons.call_outlined,
    ContactKind.email => Icons.mail_outline_rounded,
    ContactKind.instagram => Icons.photo_camera_outlined,
    ContactKind.facebook => Icons.facebook_outlined,
    ContactKind.tiktok => Icons.music_note_outlined,
    ContactKind.youtube => Icons.play_circle_outline_rounded,
    ContactKind.website => Icons.language_rounded,
    ContactKind.location => Icons.location_on_outlined,
    ContactKind.other => Icons.link_rounded,
  };

  /// Channels a customer can tap straight from a product page.
  bool get isDirectMessageChannel =>
      this == ContactKind.whatsapp || this == ContactKind.telegram;

  /// Preferred ordering for the "Buy / contact" action row.
  int get actionPriority => switch (this) {
    ContactKind.whatsapp => 0,
    ContactKind.telegram => 1,
    ContactKind.phone => 2,
    ContactKind.email => 3,
    _ => 10,
  };
}
