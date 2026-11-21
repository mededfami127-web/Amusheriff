import 'package:amu_sharif_majlis/core/utils/phone_numbers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneNumbers', () {
    test('the default owner phone is the shop number', () {
      expect(PhoneNumbers.defaultOwnerPhone, '0917928950');
      expect(PhoneNumbers.display(null), '0917928950');
      expect(PhoneNumbers.display('   '), '0917928950');
    });

    test('normalises the local trunk form to +251', () {
      expect(PhoneNumbers.international('0917928950'), '+251917928950');
      expect(PhoneNumbers.international('09 17 92 89 50'), '+251917928950');
      expect(PhoneNumbers.international('(0917) 928-950'), '+251917928950');
    });

    test('accepts the already-international forms', () {
      expect(PhoneNumbers.international('+251917928950'), '+251917928950');
      expect(PhoneNumbers.international('251917928950'), '+251917928950');
      expect(PhoneNumbers.international('00917928950'), '+251917928950');
      expect(PhoneNumbers.international('917928950'), '+251917928950');
    });

    test('builds a tel URI with the international number', () {
      expect(
        PhoneNumbers.telUri('0917928950').toString(),
        'tel:+251917928950',
      );
      expect(PhoneNumbers.telUri('').toString(), 'tel:+251917928950');
      expect(PhoneNumbers.telUri('+251 918 959 071').toString(),
          'tel:+251918959071');
    });

    test('a value with no digits is not dialable', () {
      expect(PhoneNumbers.international('—'), '');
      expect(PhoneNumbers.isDialable('—'), isFalse);
      expect(PhoneNumbers.isDialable('0917928950'), isTrue);
    });
  });
}
