import 'package:amu_sharif_majlis/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.categoryName', () {
    test('accepts 1–80 characters', () {
      expect(Validators.categoryName('Majlis Sofas'), isNull);
      expect(Validators.categoryName('a'), isNull);
      expect(Validators.categoryName('x' * 80), isNull);
    });

    test('rejects blank and over-long names', () {
      expect(Validators.categoryName(''), 'validateRequired');
      expect(Validators.categoryName('   '), 'validateRequired');
      expect(Validators.categoryName('x' * 81), 'validateTooLong');
    });
  });

  group('Validators.productTitle', () {
    test('matches the 1–140 CHECK constraint', () {
      expect(Validators.productTitle('Royal Majlis Sofa'), isNull);
      expect(Validators.productTitle('x' * 140), isNull);
      expect(Validators.productTitle('x' * 141), 'validateTooLong');
      expect(Validators.productTitle(null), 'validateRequired');
    });
  });

  group('Validators.slug', () {
    test('accepts lowercase kebab-case', () {
      expect(Validators.slug('majlis-sofas'), isNull);
      expect(Validators.slug('a1-b2'), isNull);
    });

    test('rejects uppercase, spaces and leading/trailing hyphens', () {
      expect(Validators.slug('Majlis'), 'validateSlug');
      expect(Validators.slug('majlis sofas'), 'validateSlug');
      expect(Validators.slug('-majlis'), 'validateSlug');
      expect(Validators.slug(''), 'validateRequired');
    });
  });

  group('Validators.slugify', () {
    test('normalises human input', () {
      expect(Validators.slugify('Majlis Sofas & Chairs!'), 'majlis-sofas-chairs');
      expect(Validators.slugify('  Floor   Seating  '), 'floor-seating');
      expect(Validators.slugify('አረቢያን'), '');
    });
  });

  group('Validators.strongPassword', () {
    test('requires 10+ chars with upper, lower and a digit', () {
      expect(Validators.strongPassword('Str0ngPassw'), isNull);
      expect(Validators.strongPassword('short1A'), 'validatePasswordLength');
      expect(Validators.strongPassword('alllowercase1'), 'validatePasswordStrength');
      expect(Validators.strongPassword('ALLUPPERCASE1'), 'validatePasswordStrength');
      expect(Validators.strongPassword('NoDigitsHere'), 'validatePasswordStrength');
    });
  });

  group('Validators.confirmPassword', () {
    test('requires an exact match', () {
      expect(Validators.confirmPassword('secret1234', 'secret1234'), isNull);
      expect(Validators.confirmPassword('secret1234', 'other'), 'validatePasswordMismatch');
      expect(Validators.confirmPassword('', 'other'), 'validateRequired');
    });
  });

  group('Validators price rules', () {
    test('price must be a non-negative number', () {
      expect(Validators.price('0'), isNull);
      expect(Validators.price('1250.50'), isNull);
      expect(Validators.price('-1'), 'validateNegative');
      expect(Validators.price('abc'), 'validateNumber');
    });

    test('compare-at price must be >= price (mirrors the DB CHECK)', () {
      expect(Validators.compareAtPrice('', 100), isNull);
      expect(Validators.compareAtPrice('120', 100), isNull);
      expect(Validators.compareAtPrice('100', 100), isNull);
      expect(Validators.compareAtPrice('90', 100), 'validateCompareAtPrice');
    });
  });

  group('Validators video limits', () {
    test('matches the storage policy (60 s max)', () {
      expect(Validators.videoDuration(const Duration(seconds: 60)), isNull);
      expect(Validators.videoDuration(const Duration(seconds: 61)), 'validateVideoTooLong');
      expect(Validators.videoDuration(Duration.zero), 'validateVideoUnreadable');
    });
  });

  group('Validators.digitsOnly', () {
    test('strips formatting so wa.me links resolve', () {
      expect(Validators.digitsOnly('+251 917 928 950'), '251917928950');
      expect(Validators.digitsOnly('(0917) 928-950'), '0917928950');
    });
  });
}
