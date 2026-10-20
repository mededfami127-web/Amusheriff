import 'package:flutter_test/flutter_test.dart';

import '../../core/utils/formatters.dart';

void main() {
  group('intlLocaleFor falls back safely for unlocalized Oromo money/date', () {
    test('om maps to an intl-capable locale', () {
      expect(intlLocaleFor('om'), equals('en_US'));
      expect(intlLocaleFor('om').split('_'), equals(<String>['en', 'US']));
    });

    test('known app locales keep a deterministic intl locale', () {
      expect(intlLocaleFor('en'), equals('en_US'));
      expect(intlLocaleFor('am'), equals('en_US'));
      expect(intlLocaleFor('ar').split('_'), equals(<String>['ar', 'AE']));
    });

    test('unknown language codes fall back to en_US', () {
      expect(intlLocaleFor('xx'), equals('en_US'));
      expect(intlLocaleFor(''), equals('en_US'));
    });
  });

  group('supportedLocaleFor keeps Oromo from reaching intl directly', () {
    test('om is offered as English to the platform', () {
      expect(supportedLocaleFor('om'), equals(const Locale('en')));
    });

    test('supported app locales map one-to-one', () {
      expect(supportedLocaleFor('en'), equals(const Locale('en')));
      expect(supportedLocaleFor('am'), equals(const Locale('am')));
      expect(supportedLocaleFor('ar'), equals(const Locale('ar')));
    });

    test('unknown language codes fall back to en', () {
      expect(supportedLocaleFor('xx'), equals(const Locale('en')));
    });
  });

  group('isAppLocale recognises the four shipped languages', () {
    test('shipped languages are app locales', () {
      expect(isAppLocale('en'), isTrue);
      expect(isAppLocale('am'), isTrue);
      expect(isAppLocale('ar'), isTrue);
      expect(isAppLocale('om'), isTrue);
    });

    test('shipped languages accept region suffix', () {
      expect(isAppLocale('en_US'), isTrue);
      expect(isAppLocale('ar_AE'), isTrue);
      expect(isAppLocale('om_ET'), isTrue);
    });

    test('unsupported languages are not app locales', () {
      expect(isAppLocale('xx'), isFalse);
      expect(isAppLocale(''), isFalse);
    });
  });

  group('localeDisplayName stays neutral across languages', () {
    test('the four shipped languages have readable labels', () {
      expect(localeDisplayName('en'), equals('English'));
      expect(localeDisplayName('am'), equals('አማርኛ'));
      expect(localeDisplayName('ar'), equals('العربي'));
      expect(localeDisplayName('om'), equals('Oromoo'));
    });

    test('unknown languages label as English', () {
      expect(localeDisplayName('zz'), equals('English'));
    });
  });

  group('money keeps sensible shapes after the locale switch', () {
    test('whole ETB amount does not render trailing decimals for en', () {
      expect(Formatters.money(12500, locale: 'en'), equals('12,500.00 ETB'));
    });

    test('decimal ETB amount keeps two digits for en', () {
      expect(Formatters.money(12500.5, locale: 'en'), equals('12,500.50 ETB'));
    });

    test('compact money still formats', () {
      expect(
        Formatters.compactMoney(1250000, locale: 'en'),
        contains('ETB'),
      );
    });

    test('Oromo currency formatting falls back without throwing', () {
      expect(() => Formatters.money(12500, locale: 'om'), returnsNormally);
      expect(
        Formatters.shortDate(
          DateTime(2026, 01, 21, 10, 0, 0),
          locale: 'om',
        ),
        isNotEmpty,
      );
    });
  });
}
