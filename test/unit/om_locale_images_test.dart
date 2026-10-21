import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/network/supabase_client_provider.dart';
import 'package:amu_sharif_majlis/core/l10n/text_localizations.dart';
import 'package:amu_sharif_majlis/core/network/storage_urls.dart';
import 'package:amu_sharif_majlis/core/theme/app_theme.dart';
import 'package:amu_sharif_majlis/core/utils/formatters.dart';
import 'package:amu_sharif_majlis/features/admin/data/system_check_runner.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/providers/system_check_providers.dart';
import 'package:amu_sharif_majlis/features/auth/presentation/providers/auth_providers.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/category.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/media_kind.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product_media.dart';
import 'package:amu_sharif_majlis/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:amu_sharif_majlis/features/contacts/presentation/providers/contact_providers.dart';
import 'package:amu_sharif_majlis/features/contacts/presentation/providers/contact_settings_providers.dart';
import 'package:amu_sharif_majlis/features/inquiries/presentation/providers/inquiry_providers.dart';
import 'package:amu_sharif_majlis/features/settings/domain/entities/site_settings.dart';
import 'package:amu_sharif_majlis/features/settings/presentation/providers/site_content_providers.dart';
import 'package:amu_sharif_majlis/features/settings/presentation/providers/site_settings_providers.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/product_detail_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/storefront_home_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/widgets/category_card.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/widgets/product_card.dart';
import 'package:amu_sharif_majlis/features/text_editor/presentation/providers/text_editor_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../layout/overflow_harness.dart';

/// Afaan Oromo is a supported app language that `intl` cannot format.
///
/// The released app switched the whole storefront to Oromo and the catalogue
/// tiles vanished behind the error fallback. These tests pump the same
/// `MaterialApp` configuration the app uses (the real `supportedLocales`, the
/// real delegate list) at every shipped locale and fail on the first framework
/// exception, so a locale-only build failure cannot hide again.
const List<String> kShippedLocales = <String>['en', 'am', 'ar', 'om'];

const ProductMedia _cover = ProductMedia(
  id: 'm1',
  productId: 'p1',
  kind: MediaKind.image,
  storagePath: 'products/p1/m1.webp',
  isCover: true,
);

/// Oromo and Amharic product names are deliberately empty here: the storefront
/// must fall back to the English title, not render an empty string or crash.
const Product _product = Product(
  id: 'p1',
  categoryId: 'c1',
  title: 'Royal Majlis Sofa',
  titleAm: '',
  titleAr: 'أريكة المجلس',
  description: 'Hand-carved majlis sofa.',
  descriptionAm: '',
  descriptionAr: 'أريكة مجلس منحوتة يدويًا.',
  price: 40000,
  currencyCode: 'ETB',
  media: <ProductMedia>[_cover],
);

/// A name that needs both lines and an ellipsis on the smallest phone.
const Category _longCategory = Category(
  id: 'c2',
  name: 'Majlis Sofas and Hand-Carved Corner Units',
  nameAm: '',
  nameAr: 'أرائك المجلس والزوايا المنحوتة يدويًا',
  slug: 'corner-units',
  coverPath: 'categories/c2/cover.png',
);

const Category _category = Category(
  id: 'c1',
  name: 'Majlis',
  nameAm: '',
  nameAr: 'المجلس',
  slug: 'majlis',
  coverPath: 'categories/c1/cover.png',
);

/// Pumps [home] at [locale] and returns every framework error it reported.
Future<List<FlutterErrorDetails>> _pumpAt(
  WidgetTester tester, {
  required String locale,
  required Widget home,
}) async {
  final FakeBackend backend = FakeBackend(
    productRows: const <Product>[_product],
    categoryRows: const <Category>[_category],
  );

  final List<FlutterErrorDetails> errors = <FlutterErrorDetails>[];
  final FlutterExceptionHandler? previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) => errors.add(details);

  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: (int retryCount, Object error) => null,
      overrides: [
        storageUrlsProvider.overrideWithValue(FakeBackend.storageUrls),
        categoryRepositoryProvider.overrideWithValue(backend.categories),
        productRepositoryProvider.overrideWithValue(backend.products),
        productMediaRepositoryProvider.overrideWithValue(
          FakeProductMediaRepository(
            mode: SourceMode.data,
            rows: const <ProductMedia>[_cover],
          ),
        ),
        contactRepositoryProvider.overrideWithValue(backend.contacts),
        contactSettingsRepositoryProvider.overrideWithValue(
          backend.contactSettings,
        ),
        inquiryRepositoryProvider.overrideWithValue(backend.inquiries),
        siteSettingsRepositoryProvider.overrideWithValue(backend.settings),
        siteContentRepositoryProvider.overrideWithValue(backend.siteContent),
        siteSettingsValueProvider.overrideWithValue(SiteSettings.fallback),
        authRepositoryProvider.overrideWithValue(backend.auth),
        textOverridesRepositoryProvider.overrideWithValue(backend.overrides),
        currentSessionProvider.overrideWithValue(null),
        currentUserProvider.overrideWithValue(null),
        systemChecksProvider.overrideWith(
          (Ref ref) =>
              Future<List<SystemAssetCheck>>.value(const <SystemAssetCheck>[]),
        ),
      ],
      child: MaterialApp(
        // The app's real locale wiring.
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: appLocalizationsDelegates(
          overrides: const <String, String>{},
        ),
        theme: AppTheme.light(),
        home: home,
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  FlutterError.onError = previous;
  return errors;
}

String _describe(List<FlutterErrorDetails> errors) => errors
    .map(
      (FlutterErrorDetails details) =>
          '${details.exception}\n${details.stack ?? ''}',
    )
    .join('\n---\n');

void main() {
  group('formatters never throw for a language intl does not ship', () {
    test('Oromo money keeps the digits and the currency', () {
      final String en = Formatters.money(40000, locale: 'en');
      final String om = Formatters.money(40000, locale: 'om');

      expect(om, contains('40,000'));
      expect(om, contains('ETB'));
      // Oromo uses the same `intl` pattern set as English, so the two match.
      expect(om, en);
      expect(Formatters.money(40000.5, locale: 'om'), contains('40,000.50'));
    });

    test('the plain-text fallback is exactly ETB 40,000', () {
      expect(Formatters.plainMoney(40000), 'ETB 40,000');
      expect(Formatters.plainMoney(40000.5), 'ETB 40,000.50');
    });

    test('Oromo dates and percentages fall back to plain text', () {
      expect(
        Formatters.shortDate(DateTime(2026, 10, 21), locale: 'om'),
        isNotEmpty,
      );
      expect(Formatters.percent(0.25, locale: 'om'), contains('%'));
    });
  });

  test('a device locale resolves to a shipped one', () {
    expect(
      resolveAppLocale(
        const Locale('om', 'ET'),
        AppLocalizations.supportedLocales,
      ),
      const Locale('om'),
    );
    expect(
      resolveAppLocale(
        const Locale('ar', 'SA'),
        AppLocalizations.supportedLocales,
      ),
      const Locale('ar'),
    );
    expect(
      resolveAppLocale(const Locale('fr'), AppLocalizations.supportedLocales),
      const Locale('en'),
    );
  });

  group('Oromo keeps the storefront images', () {
    for (final String locale in kShippedLocales) {
      testWidgets('the home page renders at $locale', (
        WidgetTester tester,
      ) async {
        final List<FlutterErrorDetails> errors = await _pumpAt(
          tester,
          locale: locale,
          home: const StorefrontHomePage(),
        );

        expect(
          errors,
          isEmpty,
          reason: 'framework errors at $locale:\n${_describe(errors)}',
        );
        expect(find.byType(StorefrontHomePage), findsOneWidget);
      });

      testWidgets('a product card shows its image and price at $locale', (
        WidgetTester tester,
      ) async {
        final List<FlutterErrorDetails> errors = await _pumpAt(
          tester,
          locale: locale,
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                height: 320,
                child: ProductCard(product: _product),
              ),
            ),
          ),
        );

        expect(
          errors,
          isEmpty,
          reason: 'framework errors at $locale:\n${_describe(errors)}',
        );

        final Finder card = find.byType(ProductCard);
        expect(card, findsOneWidget);

        // The image request is the same for every language, and the tile keeps
        // it: a localised title must never leak into the URL.
        final CachedNetworkImage image = tester.widget<CachedNetworkImage>(
          find.descendant(of: card, matching: find.byType(CachedNetworkImage)),
        );
        expect(
          image.imageUrl,
          FakeBackend.storageUrls.productMediaThumb(
            _cover.storagePath,
            width: 560,
          ),
        );

        // The price is visible, not swallowed by a broken build.
        expect(find.textContaining('40,000'), findsOneWidget);
        // No error panel, no broken-image icon, no framework error widget.
        expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
        expect(find.byType(ErrorWidget), findsNothing);
      });

      testWidgets('a category card fills its area with the image at $locale', (
        WidgetTester tester,
      ) async {
        final List<FlutterErrorDetails> errors = await _pumpAt(
          tester,
          locale: locale,
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 138,
                height: 148,
                child: CategoryCard(category: _category),
              ),
            ),
          ),
        );

        expect(
          errors,
          isEmpty,
          reason: 'framework errors at $locale:\n${_describe(errors)}',
        );

        final Finder card = find.byType(CategoryCard);
        final Size cardSize = tester.getSize(card);
        final Finder image = find.descendant(
          of: card,
          matching: find.byType(CachedNetworkImage),
        );
        expect(image, findsOneWidget);
        expect(
          tester.getSize(image),
          cardSize,
          reason: 'the cover must fill the card, not sit in a corner',
        );
        expect(find.byType(ErrorWidget), findsNothing);
        expect(
          find.byIcon(Icons.weekend_outlined),
          findsNothing,
          reason: 'a real cover must not show the placeholder',
        );
        // The name is the localised one; Oromo and Amharic have no name of
        // their own here, so they fall back to the English name.
        expect(
          find.text(_category.nameFor(locale)),
          findsOneWidget,
          reason: 'category name at $locale',
        );
      });

      testWidgets('the product detail page renders at $locale', (
        WidgetTester tester,
      ) async {
        final List<FlutterErrorDetails> errors = await _pumpAt(
          tester,
          locale: locale,
          home: const ProductDetailPage(productId: 'p1'),
        );

        expect(
          errors,
          isEmpty,
          reason: 'framework errors at $locale:\n${_describe(errors)}',
        );
        expect(find.textContaining('40,000'), findsWidgets);
      });
    }
  });

  group('the category card fits the smallest phone at 2.0 text', () {
    for (final String locale in kShippedLocales) {
      testWidgets(
        '320x568 @2.0 $locale has no overflow and an RTL-safe layout',
        (WidgetTester tester) async {
          late Size cardSize;
          late Size imageSize;

          final List<String> overflows = await pumpPage(
            tester,
            config: LayoutConfig(
              size: const Size(320, 568),
              textScale: 2.0,
              locale: locale,
              keyboard: false,
            ),
            backend: FakeBackend(
              categoryRows: const <Category>[_longCategory],
              productRows: const <Product>[_product],
            ),
            page: const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 148,
                  child: CategoryCard(category: _longCategory),
                ),
              ),
            ),
            afterPump: (WidgetTester tester) async {
              final Finder card = find.byType(CategoryCard);
              cardSize = tester.getSize(card);
              imageSize = tester.getSize(
                find.descendant(
                  of: card,
                  matching: find.byType(CachedNetworkImage),
                ),
              );

              expect(
                Directionality.of(tester.element(card)),
                locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              );
              expect(find.text(_longCategory.nameFor(locale)), findsOneWidget);
            },
          );

          expect(overflows, isEmpty, reason: overflows.join('\n'));
          expect(imageSize, cardSize);
        },
      );
    }
  });
}
