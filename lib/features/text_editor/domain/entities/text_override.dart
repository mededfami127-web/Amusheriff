import 'package:flutter/foundation.dart';

/// One owner-authored string: an ARB key rewritten in one locale.
///
/// The pair ([textKey], [locale]) is the identity — the table's primary key —
/// so editing the same string twice updates the one row and clearing it
/// restores the shipped wording.
@immutable
class TextOverride {
  const TextOverride({
    required this.textKey,
    required this.locale,
    required this.value,
  });

  final String textKey;
  final String locale;
  final String value;

  factory TextOverride.fromJson(Map<String, dynamic> json) => TextOverride(
    textKey: json['text_key'] as String? ?? '',
    locale: json['locale'] as String? ?? 'en',
    value: json['value'] as String? ?? '',
  );

  /// Row payload for an upsert against `public.text_overrides`.
  Map<String, dynamic> toRow(String? userId) => <String, dynamic>{
    'text_key': textKey,
    'locale': locale,
    'value': value.trim(),
    if (userId != null) 'updated_by': userId,
  };

  @override
  bool operator ==(Object other) =>
      other is TextOverride &&
      other.textKey == textKey &&
      other.locale == locale &&
      other.value == value;

  @override
  int get hashCode => Object.hash(textKey, locale, value);

  @override
  String toString() => 'TextOverride($textKey, $locale)';
}
