import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/l10n/text_catalog.dart';
import 'package:amu_sharif_majlis/core/utils/formatters.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('intlLocaleFor always yields a locale intl can format with', () {
    test('Oromo falls back to an intl-supported locale', () {
      expect(intlLocaleFor('om'), equals('en_US'));
      expect(intlLocaleFor('om').contains('_'), isTrue);
    });

    test('the other shipped languages keep deterministic values', () {
      expect(intlLocaleFor('en'), equals('en_US'));
      expect(intlLocaleFor('am'), equals('en_US'));
      expect(intlLocaleFor('ar'), equals('ar_AE'));
    });

    test('unknown and empty codes fall back to en_US', () {
      expect(intlLocaleFor('xx'), equals('en_US'));
      expect(intlLocaleFor(''), equals('en_US'));
    });
  });

  group('supportedLocaleFor mirrors supportedLocales, Oromo included', () {
    test('every shipped language keeps its own platform locale', () {
      expect(supportedLocaleFor('en'), equals(const Locale('en')));
      expect(supportedLocaleFor('am'), equals(const Locale('am')));
      expect(supportedLocaleFor('ar'), equals(const Locale('ar')));
      expect(supportedLocaleFor('om'), equals(const Locale('om')));
    });

    test('a region suffix does not change the result', () {
      expect(supportedLocaleFor('om_ET'), equals(const Locale('om')));
      expect(supportedLocaleFor('ar_AE'), equals(const Locale('ar')));
    });

    test('an unsupported code falls back to English', () {
      expect(supportedLocaleFor('xx'), equals(const Locale('en')));
    });

    test('every returned locale is one the app actually supports', () {
      for (final Locale locale in AppLocalizations.supportedLocales) {
        expect(
          supportedLocaleFor(locale.languageCode),
          equals(locale),
          reason: locale.languageCode,
        );
      }
    });
  });

  group('isAppLocale recognises only the four shipped languages', () {
    test('shipped languages are app locales, with or without a region', () {
      for (final String code in <String>['en', 'am', 'ar', 'om']) {
        expect(isAppLocale(code), isTrue, reason: code);
        expect(isAppLocale('${code}_ET'), isTrue, reason: code);
      }
    });

    test('unsupported and empty codes are not app locales', () {
      expect(isAppLocale('xx'), isFalse);
      expect(isAppLocale(''), isFalse);
    });
  });

  group('localeDisplayName reuses the editor\'s locale names', () {
    test('every shipped language has its own label', () {
      expect(localeDisplayName('en'), equals('English'));
      expect(localeDisplayName('am'), equals('አማርኛ'));
      expect(localeDisplayName('ar'), equals('العربي'));
      expect(localeDisplayName('om'), equals('Oromoo'));
    });

    test('labels come from the generated catalog, not a second copy', () {
      for (final String code in kAppTextLocales) {
        expect(localeDisplayName(code), equals(kAppTextLocaleNames[code]));
      }
    });

    test('a region suffix still finds the label', () {
      expect(localeDisplayName('om_ET'), equals('Oromoo'));
    });

    test('unknown languages label as English', () {
      expect(localeDisplayName('zz'), equals('English'));
    });
  });

  group('money survives a locale switch', () {
    test('a whole amount drops the decimals and keeps the currency', () {
      final String formatted = Formatters.money(12500, locale: 'en_US');
      expect(formatted, contains('12,500'));
      expect(formatted, contains('ETB'));
      expect(formatted, isNot(contains('12,500.')));
    });

    test('a fractional amount keeps two decimals', () {
      expect(Formatters.money(12500.5, locale: 'en_US'), contains('12,500.50'));
    });

    test('the same price formats through the Oromo fallback', () {
      expect(
        Formatters.money(12500, locale: intlLocaleFor('om')),
        equals(Formatters.money(12500, locale: 'en_US')),
      );
    });

    test('compact money still carries the currency', () {
      expect(
        Formatters.compactMoney(1250000, locale: 'en_US'),
        contains('ETB'),
      );
    });

    test('a date formats through the Oromo fallback', () {
      final String formatted = Formatters.shortDate(
        DateTime(2026, 1, 21, 10),
        locale: intlLocaleFor('om'),
      );
      expect(formatted, isNotEmpty);
      expect(formatted, contains('2026'));
    });
  });
}
