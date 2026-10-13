import 'package:freezed_annotation/freezed_annotation.dart';

import 'contact_kind.dart';

part 'contact_link.freezed.dart';
part 'contact_link.g.dart';

/// A way for a customer to reach the owner.
@freezed
abstract class ContactLink with _$ContactLink {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory ContactLink({
    required String id,
    required ContactKind kind,
    required String label,
    required String value,
    @Default(false) bool isPrimary,
    @Default(true) bool isVisible,
    @Default(0) int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ContactLink;

  const ContactLink._();

  factory ContactLink.fromJson(Map<String, dynamic> json) =>
      _$ContactLinkFromJson(json);

  /// True when [value] looks like a URL rather than a handle/number.
  bool get valueIsUrl =>
      value.startsWith('http://') || value.startsWith('https://');

  /// A human-readable form of the raw value for display under the label.
  String get displayValue {
    final String v = value.trim();
    if (kind == ContactKind.phone) return v;
    if (kind == ContactKind.email) return v;
    return v.replaceFirst(RegExp(r'^https?://(www\.)?'), '');
  }
}
