/// Phone-number rules for the one number every Call button dials.
///
/// The owner stores the number once, as a human writes it (`0917928950`), and
/// the app normalises it at the last moment for the `tel:` intent. Keeping this
/// in `core` means the storefront widget, the settings screen and the tests all
/// agree on one conversion, and no screen ever builds a `tel:` string by hand.
abstract final class PhoneNumbers {
  const PhoneNumbers._();

  /// The shop's number before the owner has saved one of their own.
  static const String defaultOwnerPhone = '0917928950';

  /// What a customer reads: the stored value, or the default when it is blank.
  static String display(String? raw, {String fallback = defaultOwnerPhone}) {
    final String value = (raw ?? '').trim();
    return value.isEmpty ? fallback : value;
  }

  /// `0917928950` → `+251917928950`.
  ///
  /// Handles the three shapes the owner can type: a local Ethiopian number with
  /// the trunk `0` (the default), the same number without it (`917928950`), and
  /// an already-international value with or without a leading `+`. Anything
  /// else is returned with a single leading `+` so the dialer still receives a
  /// syntactically valid URI instead of an empty one.
  static String international(String? raw) {
    final String digits = (raw ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('00')) return '+${digits.substring(2)}';
    if (digits.startsWith('251')) return '+$digits';
    if (digits.startsWith('0')) return '+251${digits.substring(1)}';
    if (digits.length == 9) return '+251$digits';
    return '+$digits';
  }

  /// The `tel:` URI for the dialer, with the international number.
  static Uri telUri(String? raw) =>
      Uri(scheme: 'tel', path: international(display(raw)));

  /// True when a value can produce a dialable URI.
  static bool isDialable(String? raw) => international(raw).length > 4;
}
