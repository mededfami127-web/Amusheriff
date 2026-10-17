import 'package:flutter/foundation.dart';

import '../entities/contact_kind.dart';

/// Write-side DTO for `public.contact_links`.
@immutable
class ContactLinkDraft {
  const ContactLinkDraft({
    required this.kind,
    required this.label,
    required this.value,
    this.isPrimary = false,
    this.isVisible = true,
    this.sortOrder = 0,
  });

  final ContactKind kind;
  final String label;
  final String value;
  final bool isPrimary;
  final bool isVisible;
  final int sortOrder;

  Map<String, dynamic> toInsert() => <String, dynamic>{
    'kind': kind.name,
    'label': label.trim(),
    'value': value.trim(),
    'is_primary': isPrimary,
    'is_visible': isVisible,
    'sort_order': sortOrder,
  };

  Map<String, dynamic> toUpdate() => toInsert();
}
