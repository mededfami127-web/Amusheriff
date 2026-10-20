import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/text_catalog.dart';

/// Locale-aware formatting helpers. Every formatter is created lazily and
/// cached per locale so hot paths do not rebuild [NumberFormat] objects.
///
/// The app ships text in four languages: English, Amharic, Arabic and Oromo.
/// Formatting helpers take a locale that `intl` understands, so callers should
/// resolve it with [intlLocaleFor] instead of passing the raw app language.
abstract final class Formatters {
  const Formatters._();

  static final Map<String, NumberFormat> _money = <String, NumberFormat>{};
  static final Map<String, DateFormat> _shortDate = <String, DateFormat>{};

  /// Formats a price with the shop currency.
  ///
  /// Whole amounts render without decimals (`ETB12,500`) and fractional ones
  /// keep two (`ETB12,500.50`). [locale] must be a locale the `intl` package
  /// knows about, so callers should pass `intlLocaleFor(appLanguage)` rather
  /// than the raw app language code.
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

/// An `intl` locale that can format prices and dates for an app language.
///
/// The app translates every string itself, including Oromo, but the `intl`
/// package ships no Oromo number/date patterns. Money and dates therefore use
/// the closest pattern set the package does have, so `om` never reaches `intl`
/// as a raw code and never throws.
///
/// This is deliberately separate from [supportedLocaleFor]: Oromo is a
/// supported *app* locale, it just is not an `intl` one.
String intlLocaleFor(String languageCode) {
  switch (_languageCode(languageCode)) {
    case 'ar':
      return 'ar_AE';
    case 'en':
    case 'am':
    case 'om':
      return 'en_US';
    default:
      return 'en_US';
  }
}

/// The `Locale` for an app language, as listed in `supportedLocales`.
///
/// Oromo is included: `AppLocalizations` ships `AppLocalizationsOm` and the
/// app's delegate wrapper gap-fills Material/Cupertino for it, so mapping `om`
/// to English here would render platform chrome in the wrong language.
Locale supportedLocaleFor(String languageCode) {
  final String code = _languageCode(languageCode);
  return isAppLocale(code) ? Locale(code) : const Locale('en');
}

/// True when the app ships its own localizations for [languageCode].
///
/// Delegates to the generated [kAppTextLocales] list so there is one source of
/// truth for the shipped languages.
bool isAppLocale(String languageCode) =>
    kAppTextLocales.contains(_languageCode(languageCode));

/// A display label for the app language picker, from [kAppTextLocaleNames].
String localeDisplayName(String languageCode) =>
    kAppTextLocaleNames[_languageCode(languageCode)] ??
    kAppTextLocaleNames['en']!;

/// Strips a region suffix (`om_ET`) and lower-cases the remaining code.
String _languageCode(String languageCode) =>
    languageCode.split('_').first.split('-').first.toLowerCase();
