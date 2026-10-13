import 'package:freezed_annotation/freezed_annotation.dart';

part 'inquiry.freezed.dart';
part 'inquiry.g.dart';

/// An anonymous lead: a customer tapped a contact button on a product.
///
/// Written through the rate-limited Edge Function so anon can log intent
/// without gaining any write access to catalogue tables. Admins read the full
/// table through RLS; nobody but an admin can read it back.
@freezed
abstract class Inquiry with _$Inquiry {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory Inquiry({
    required String id,
    required String channel,
    String? productId,
    String? deviceId,
    String? productTitle,
    DateTime? createdAt,
  }) = _Inquiry;

  const Inquiry._();

  /// `created_at` may be absent on a freshly-inserted row; treat that as "now"
  /// so relative labels never render blank.
  DateTime get effectiveCreatedAt => createdAt ?? DateTime.now();

  /// True when the lead landed within the last seven days.
  bool isWithinLast(Duration window, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    return reference.difference(effectiveCreatedAt) <= window;
  }
}
