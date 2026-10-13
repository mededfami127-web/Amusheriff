/// Pure validators.
///
/// Each returns a **message key** (resolved against the ARB files by the
/// caller) or `null` when the value is valid. Keeping them free of
/// `BuildContext` makes them trivially unit-testable.
abstract final class Validators {
  const Validators._();

  static final RegExp _slug = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
  static final RegExp _phone = RegExp(r'^\+?[0-9\s\-()]{7,20}$');
  static final RegExp _url = RegExp(r'^https?://[^\s]+$');

  static String? required(String? value, {int min = 1, int max = 255}) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'validateRequired';
    if (v.length < min) return 'validateTooShort';
    if (v.length > max) return 'validateTooLong';
    return null;
  }

  /// Matches the `categories.name` CHECK constraint (1–80 chars).
  static String? categoryName(String? value) =>
      required(value, min: 1, max: 80);

  /// Matches the `products.title` CHECK constraint (1–140 chars).
  static String? productTitle(String? value) =>
      required(value, min: 1, max: 140);

  static String? slug(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'validateRequired';
    if (!_slug.hasMatch(v)) return 'validateSlug';
    return null;
  }

  static String? email(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'validateRequired';
    if (!_email.hasMatch(v)) return 'validateEmail';
    return null;
  }

  static String? phone(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'validateRequired';
    if (!_phone.hasMatch(v)) return 'validatePhone';
    return null;
  }

  static String? url(String? value, {bool allowDeepLink = false}) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'validateRequired';
    if (allowDeepLink && RegExp(r'^[a-z][a-z0-9+.-]*:').hasMatch(v)) {
      return null;
    }
    if (!_url.hasMatch(v)) return 'validateUrl';
    return null;
  }

  /// Admin password rule: 10+ chars with upper, lower and a digit.
  static String? strongPassword(String? value) {
    final String v = value ?? '';
    if (v.length < 10) return 'validatePasswordLength';
    final bool hasUpper = v.contains(RegExp('[A-Z]'));
    final bool hasLower = v.contains(RegExp('[a-z]'));
    final bool hasDigit = v.contains(RegExp('[0-9]'));
    if (!hasUpper || !hasLower || !hasDigit) return 'validatePasswordStrength';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'validateRequired';
    if (value != original) return 'validatePasswordMismatch';
    return null;
  }

  static String? price(String? value, {bool allowZero = true}) {
    final double? parsed = double.tryParse((value ?? '').trim());
    if (parsed == null) return 'validateNumber';
    if (parsed < 0) return 'validateNegative';
    if (!allowZero && parsed == 0) return 'validatePositive';
    return null;
  }

  /// `compare_at_price` must be greater than or equal to `price`, matching the
  /// database CHECK constraint.
  static String? compareAtPrice(String? value, double price) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final double? parsed = double.tryParse(v);
    if (parsed == null) return 'validateNumber';
    if (parsed < price) return 'validateCompareAtPrice';
    return null;
  }

  /// Video duration cap (the storage policy allows at most 60 seconds).
  static String? videoDuration(Duration duration, {int maxSeconds = 60}) {
    if (duration.inSeconds > maxSeconds) return 'validateVideoTooLong';
    if (duration.inSeconds <= 0) return 'validateVideoUnreadable';
    return null;
  }

  /// Normalises a WhatsApp/Telegram value into a digits-only E.164-ish form
  /// so `https://wa.me/<n>` links always resolve.
  static String digitsOnly(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  static String slugify(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
