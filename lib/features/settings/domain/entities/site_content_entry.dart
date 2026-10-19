import 'package:flutter/foundation.dart';

/// One owner-authored home string: a site_content key rewritten in one locale.
@immutable
class SiteContentEntry {
  const SiteContentEntry({
    required this.key,
    required this.locale,
    required this.value,
  });

  final String key;
  final String locale;
  final String value;

  factory SiteContentEntry.fromJson(Map<String, dynamic> json) =>
      SiteContentEntry(
        key: json['key'] as String? ?? '',
        locale: json['locale'] as String? ?? 'en',
        value: json['value'] as String? ?? '',
      );

  /// Row payload for an upsert against `public.site_content`.
  Map<String, dynamic> toRow(String? userId) => <String, dynamic>{
    'key': key,
    'locale': locale,
    'value': value.trim(),
    if (userId != null) 'updated_by': userId,
  };

  @override
  bool operator ==(Object other) =>
      other is SiteContentEntry &&
      other.key == key &&
      other.locale == locale &&
      other.value == value;

  @override
  int get hashCode => Object.hash(key, locale, value);

  @override
  String toString() => 'SiteContentEntry($key, $locale)';
}
