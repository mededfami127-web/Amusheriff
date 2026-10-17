import 'package:amu_sharif_majlis/core/utils/formatters.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/category.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/media_kind.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product_media.dart';
import 'package:amu_sharif_majlis/features/settings/domain/entities/site_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Category localized names', () {
    const Category category = Category(
      id: 'c1',
      name: 'Majlis Sofas',
      nameAm: 'የመጅሊስ ሶፋዎች',
      nameAr: 'كنب المجلس',
      slug: 'majlis-sofas',
    );

    test('resolves per language with an English fallback', () {
      expect(category.nameFor('en'), 'Majlis Sofas');
      expect(category.nameFor('am'), 'የመጅሊስ ሶፋዎች');
      expect(category.nameFor('ar'), 'كنب المجلس');
      expect(category.nameFor('fr'), 'Majlis Sofas');
    });

    test('falls back when a translation is blank', () {
      const Category partial = Category(
        id: 'c2',
        name: 'Cushions',
        nameAr: '   ',
        slug: 'cushions',
      );
      expect(partial.nameFor('ar'), 'Cushions');
    });

    test('hasCover tracks a non-empty cover path', () {
      expect(category.hasCover, isFalse);
      expect(category.copyWith(coverPath: 'categories/a.png').hasCover, isTrue);
    });
  });

  group('Product pricing', () {
    Product product({double price = 100, double? compareAt}) => Product(
      id: 'p1',
      categoryId: 'c1',
      title: 'Royal Majlis Sofa',
      price: price,
      compareAtPrice: compareAt,
    );

    test('discount is only reported when compare-at is strictly higher', () {
      expect(product().hasDiscount, isFalse);
      expect(product(price: 100, compareAt: 100).hasDiscount, isFalse);
      expect(product(price: 100, compareAt: 80).hasDiscount, isFalse);
      expect(product(price: 75, compareAt: 100).hasDiscount, isTrue);
      expect(product(price: 75, compareAt: 100).discountPercent, 25);
    });

    test('isOrderable requires both published and available', () {
      expect(product().isOrderable, isTrue);
      expect(product().copyWith(isPublished: false).isOrderable, isFalse);
      expect(product().copyWith(isAvailable: false).isOrderable, isFalse);
    });
  });

  group('Product media resolution', () {
    ProductMedia media(
      String id,
      MediaKind kind, {
      bool cover = false,
      int order = 0,
    }) => ProductMedia(
      id: id,
      productId: 'p1',
      kind: kind,
      storagePath: 'products/p1/$id',
      isCover: cover,
      sortOrder: order,
    );

    test('coverMedia prefers the flagged cover, then any image', () {
      final Product noCover = Product(
        id: 'p1',
        categoryId: 'c1',
        title: 'x',
        price: 1,
        media: <ProductMedia>[
          media('v1', MediaKind.video, order: 0),
          media('i1', MediaKind.image, order: 1),
        ],
      );
      expect(noCover.coverPath, 'products/p1/i1');

      final Product flagged = noCover.copyWith(
        media: <ProductMedia>[
          media('v1', MediaKind.video),
          media('i1', MediaKind.image),
          media('i2', MediaKind.image, cover: true),
        ],
      );
      expect(flagged.coverPath, 'products/p1/i2');
      expect(flagged.images, hasLength(2));
      expect(flagged.videos, hasLength(1));
    });

    test('toImage/aspect helpers expose durations', () {
      expect(media('v1', MediaKind.video, order: 0).duration, isNull);
      final ProductMedia withDuration = media(
        'v1',
        MediaKind.video,
      ).copyWith(durationSeconds: 42);
      expect(withDuration.duration, const Duration(seconds: 42));
      expect(withDuration.isVideo, isTrue);
    });
  });

  group('SiteSettings', () {
    test('fallback carries the exact brand names from the logo', () {
      expect(SiteSettings.fallback.storeNameEn, 'Amu Sharif Arabiyan Majlis');
      expect(SiteSettings.fallback.storeNameAm, 'አሙ ሸሪፍ አረቢያን መጅሊስ');
      expect(SiteSettings.fallback.storeNameAr, 'المجلس العربي عمو شريف');
      expect(SiteSettings.fallback.currencyCode, 'ETB');
    });

    test('storeNameFor falls back to English when a translation is blank', () {
      const SiteSettings settings = SiteSettings(storeNameAm: '');
      expect(settings.storeNameFor('am'), 'Amu Sharif Arabiyan Majlis');
      expect(settings.storeNameFor('ar'), 'المجلس العربي عمو شريف');
    });
  });

  group('AppLanguage', () {
    test('knows which direction it renders in', () {
      expect(AppLanguage.ar.isRtl, isTrue);
      expect(AppLanguage.en.isRtl, isFalse);
      expect(AppLanguage.am.isRtl, isFalse);
    });

    test('resolves unknown device locales to English', () {
      expect(AppLanguage.fromDeviceLocale('am'), AppLanguage.am);
      expect(AppLanguage.fromDeviceLocale('ar-EG'), AppLanguage.en);
      expect(AppLanguage.fromDeviceLocale(null), AppLanguage.en);
      expect(AppLanguage.fromCode('nope'), AppLanguage.en);
    });
  });

  group('Formatters', () {
    test('money renders whole amounts without decimals', () {
      expect(Formatters.money(12500, locale: 'en'), contains('12,500'));
      expect(Formatters.money(1250.5, locale: 'en'), contains('1,250.50'));
    });

    test('duration renders mm:ss and hh:mm:ss', () {
      expect(Formatters.duration(const Duration(seconds: 59)), '00:59');
      expect(
        Formatters.duration(const Duration(minutes: 2, seconds: 5)),
        '02:05',
      );
      expect(
        Formatters.duration(const Duration(hours: 1, minutes: 2, seconds: 5)),
        '01:02:05',
      );
    });

    test('fileSize matches the storage caps', () {
      expect(Formatters.fileSize(5 * 1024 * 1024), '5.0 MB');
      expect(Formatters.fileSize(40 * 1024 * 1024), '40.0 MB');
      expect(Formatters.fileSize(1024), '1.0 KB');
    });

    test('discountPercent mirrors Product.discountPercent', () {
      expect(Formatters.discountPercent(75, 100), 25);
      expect(Formatters.discountPercent(100, 100), isNull);
      expect(Formatters.discountPercent(100, null), isNull);
      expect(Formatters.discountPercent(100, 0), isNull);
    });
  });
}
