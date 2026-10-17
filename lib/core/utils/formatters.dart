import 'package:intl/intl.dart';

/// Locale-aware formatting helpers. Every formatter is created lazily and
/// cached per locale so hot paths do not rebuild [NumberFormat] objects.
abstract final class Formatters {
  const Formatters._();

  static final Map<String, NumberFormat> _money = <String, NumberFormat>{};
  static final Map<String, DateFormat> _shortDate = <String, DateFormat>{};

  /// Formats a price with the shop currency.
  ///
  /// ETB renders as `12,500.00 ETB`; locales that use a suffix currency symbol
  /// (am, ar) are handled by [NumberFormat.currency] automatically.
  static String money(num amount, {String currency = 'ETB', String? locale}) {
    // Whole amounts drop the decimals; fractional ones keep two. The digit
    // count is part of the cache key, otherwise a cached 0-decimal formatter
    // would silently round a later fractional price.
    final int digits = _decimalDigits(amount);
    final String key = '${locale ?? ''}|$currency|$digits';
    final NumberFormat format = _money.putIfAbsent(
      key,
      () => NumberFormat.currency(
        locale: locale,
        name: currency,
        symbol: currency,
        decimalDigits: digits,
      ),
    );
    return format.format(amount);
  }

  /// Compact price for dense grids, e.g. `12.5K ETB`.
  static String compactMoney(
    num amount, {
    String currency = 'ETB',
    String? locale,
  }) {
    final NumberFormat format = NumberFormat.compactCurrency(
      locale: locale,
      symbol: currency,
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  static String decimal(num value, {int digits = 0, String? locale}) =>
      NumberFormat.decimalPatternDigits(
        locale: locale,
        decimalDigits: digits,
      ).format(value);

  static String percent(num ratio, {int digits = 0, String? locale}) =>
      NumberFormat.percentPattern(locale).format(ratio);

  static String shortDate(DateTime date, {String? locale}) {
    final String key = locale ?? 'en';
    return _shortDate
        .putIfAbsent(key, () => DateFormat.yMMMd(key))
        .format(date.toLocal());
  }

  static String dateTime(DateTime date, {String? locale}) =>
      DateFormat.yMMMd(locale).add_jm().format(date.toLocal());

  /// Compact age label for activity feeds: `now`, `14min`, `3h`, `2d`, and a
  /// short date once the value is a week old.
  ///
  /// The abbreviations are unit symbols rather than prose, so the same label
  /// reads correctly in every shipped locale.
  static String relativeTime(DateTime date, {String? locale}) {
    final Duration age = DateTime.now().difference(date);
    if (age.inMinutes < 1) return 'now';
    if (age.inMinutes < 60) return '${age.inMinutes}min';
    if (age.inHours < 24) return '${age.inHours}h';
    if (age.inDays < 7) return '${age.inDays}d';
    return shortDate(date, locale: locale);
  }

  /// `mm:ss` for video durations.
  static String duration(Duration d) {
    final String mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0
        ? '${d.inHours.toString().padLeft(2, '0')}:$mm:$ss'
        : '$mm:$ss';
  }

  /// Human file size, e.g. `4.8 MB`.
  static String fileSize(int bytes) {
    const List<String> units = <String>['B', 'KB', 'MB', 'GB'];
    double value = bytes.toDouble();
    int unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
  }

  /// Percentage saved by a `compare_at_price`, or `null` when there is none.
  static int? discountPercent(num price, num? compareAt) {
    if (compareAt == null || compareAt <= price || compareAt == 0) return null;
    return (((compareAt - price) / compareAt) * 100).round();
  }

  static int _decimalDigits(num amount) => amount % 1 == 0 ? 0 : 2;
}
