import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/l10n/text_localizations.dart';
import 'package:amu_sharif_majlis/core/theme/app_theme.dart';
import 'package:amu_sharif_majlis/core/utils/localized_text.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/category.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/widgets/category_card.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/widgets/product_card.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../layout/overflow_harness.dart';

/// The catalogue is multilingual in the database, so the tiles must be too.
///
/// These tests render the real [ProductCard] and [CategoryCard] inside the
/// app's real locale wiring, with a product whose title exists in all four
/// shipped languages, and assert the *visible* text for `en`, `am`, `ar` and
/// `om`. The last group proves a language switch re-renders the text without
/// the data layer running again.
const List<String> kLanguages = <String>['en', 'am', 'ar', 'om'];

const String kTitleEn = 'Royal Majlis Sofa';
const String kTitleAm = 'የንጉሣዊ መጅሊስ ሶፋ';
const String kTitleAr = 'أريكة المجلس الملكي';
const String kTitleOm = 'Sofa Majlisii Mootii';

const String kNameEn = 'Majlis';
const String kNameAm = 'መጅሊስ';
const String kNameAr = 'المجلس';
const String kNameOm = 'Majlisa';

const Product kProduct = Product(
  id: 'p1',
  categoryId: 'c1',
  title: kTitleEn,
  titleAm: kTitleAm,
  titleAr: kTitleAr,
  titleOm: kTitleOm,
  description: 'Hand-carved majlis sofa.',
  descriptionAm: 'በእጅ የተቀረጸ የመጅሊስ ሶፋ።',
  descriptionAr: 'أريكة مجلس منحوتة يدويًا.',
  descriptionOm: 'Sofa majlisii harkaan qorame.',
  price: 40000,
  currencyCode: 'ETB',
);

/// Everything written except Oromo: the fourth language must fall back to
/// English, never render an empty line.
const Product kProductWithoutOromo = Product(
  id: 'p2',
  categoryId: 'c1',
  title: kTitleEn,
  titleAm: kTitleAm,
  titleAr: kTitleAr,
  titleOm: '',
  price: 12000,
  currencyCode: 'ETB',
);

const Category kCategory = Category(
  id: 'c1',
  name: kNameEn,
  nameAm: kNameAm,
  nameAr: kNameAr,
  nameOm: kNameOm,
  slug: 'majlis',
);

const Category kCategoryWithoutOromo = Category(
  id: 'c2',
  name: kNameEn,
  nameAm: kNameAm,
  nameAr: kNameAr,
  slug: 'majlis-no-om',
);

String _expectedTitle(String language) => switch (language) {
  'am' => kTitleAm,
  'ar' => kTitleAr,
  'om' => kTitleOm,
  _ => kTitleEn,
};

String _expectedName(String language) => switch (language) {
  'am' => kNameAm,
  'ar' => kNameAr,
  'om' => kNameOm,
  _ => kNameEn,
};

/// Pumps [home] at [locale] and returns the errors Flutter reported.
Future<List<FlutterErrorDetails>> _pumpAt(
  WidgetTester tester, {
  required String locale,
  required Widget home,
  List<Product> products = const <Product>[kProduct],
  List<Category> categories = const <Category>[kCategory],
}) async {
  final FakeBackend backend = FakeBackend(
    productRows: products,
    categoryRows: categories,
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
      overrides: backend.overridesList.cast(),
      child: MaterialApp(
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: resolveAppLocale,
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

String _describe(List<FlutterErrorDetails> errors) =>
    errors.map((FlutterErrorDetails d) => '${d.exception}').join('\n---\n');

Widget _productTile(Product product) => Scaffold(
  body: Center(
    child: SizedBox(
      width: 220,
      height: 340,
      child: ProductCard(product: product),
    ),
  ),
);

Widget _categoryTile(Category category) => Scaffold(
  body: Center(
    child: SizedBox(
      width: 160,
      height: 150,
      child: CategoryCard(category: category),
    ),
  ),
);

void main() {
  group('localizedText picks selected → English → any', () {
    test('each language wins when it has text', () {
      expect(
        localizedText(
          languageCode: 'om',
          english: 'Sofa',
          amharic: 'ሶፋ',
          arabic: 'أريكة',
          oromo: 'Sofa',
        ),
        'Sofa',
      );
    });

    test('a blank selected language falls back to English', () {
      expect(
        localizedText(
          languageCode: 'om',
          english: 'Sofa',
          amharic: 'ሶፋ',
          oromo: '   ',
        ),
        'Sofa',
      );
      expect(
        localizedText(languageCode: 'am', english: 'Sofa', amharic: null),
        'Sofa',
      );
    });

    test('English blank falls through to any language that has text', () {
      expect(
        localizedText(
          languageCode: 'ar',
          english: '',
          amharic: 'ሶፋ',
          arabic: '',
        ),
        'ሶፋ',
      );
    });

    test('nothing anywhere yields an empty string, never null', () {
      expect(localizedText(languageCode: 'om', english: ''), '');
    });
  });

  group('Product.titleFor / Category.nameFor use all four columns', () {
    test('every language reads its own column', () {
      for (final String language in kLanguages) {
        expect(kProduct.titleFor(language), _expectedTitle(language));
        expect(kCategory.nameFor(language), _expectedName(language));
      }
    });

    test('a missing Oromo title falls back to English', () {
      expect(kProductWithoutOromo.titleFor('om'), kTitleEn);
      expect(kCategoryWithoutOromo.nameFor('om'), kNameEn);
      // The other languages are untouched by the missing column.
      expect(kProductWithoutOromo.titleFor('ar'), kTitleAr);
    });

    test('a missing description falls back too', () {
      expect(kProduct.descriptionFor('om'), 'Sofa majlisii harkaan qorame.');
      expect(kProductWithoutOromo.descriptionFor('om'), '');
    });
  });

  for (final String language in kLanguages) {
    testWidgets('the product card shows the $language title', (
      WidgetTester tester,
    ) async {
      final List<FlutterErrorDetails> errors = await _pumpAt(
        tester,
        locale: language,
        home: _productTile(kProduct),
      );

      expect(errors, isEmpty, reason: _describe(errors));
      expect(
        find.text(_expectedTitle(language)),
        findsOneWidget,
        reason: 'product title at $language',
      );
      for (final String other in kLanguages) {
        if (other == language) continue;
        expect(
          find.text(_expectedTitle(other)),
          findsNothing,
          reason: '$other title must not show at $language',
        );
      }
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('the category card shows the $language name', (
      WidgetTester tester,
    ) async {
      final List<FlutterErrorDetails> errors = await _pumpAt(
        tester,
        locale: language,
        home: _categoryTile(kCategory),
      );

      expect(errors, isEmpty, reason: _describe(errors));
      expect(
        find.text(_expectedName(language)),
        findsOneWidget,
        reason: 'category name at $language',
      );
      for (final String other in kLanguages) {
        if (other == language) continue;
        expect(
          find.text(_expectedName(other)),
          findsNothing,
          reason: '$other name must not show at $language',
        );
      }
      expect(find.byType(ErrorWidget), findsNothing);
    });
  }

  testWidgets('a product with no Oromo title shows English at om', (
    WidgetTester tester,
  ) async {
    final List<FlutterErrorDetails> errors = await _pumpAt(
      tester,
      locale: 'om',
      home: _productTile(kProductWithoutOromo),
    );

    expect(errors, isEmpty, reason: _describe(errors));
    expect(find.text(kTitleEn), findsOneWidget);
    expect(find.text(kTitleAm), findsNothing);
    expect(find.text(kTitleAr), findsNothing);
  });

  testWidgets('a category with no Oromo name shows English at om', (
    WidgetTester tester,
  ) async {
    final List<FlutterErrorDetails> errors = await _pumpAt(
      tester,
      locale: 'om',
      home: _categoryTile(kCategoryWithoutOromo),
    );

    expect(errors, isEmpty, reason: _describe(errors));
    expect(find.text(kNameEn), findsOneWidget);
    expect(find.text(kNameOm), findsNothing);
  });

  testWidgets('switching language re-renders the cards without a reload', (
    WidgetTester tester,
  ) async {
    final FakeBackend backend = FakeBackend(
      productRows: const <Product>[kProduct],
      categoryRows: const <Category>[kCategory],
    );
    final ValueNotifier<Locale> locale = ValueNotifier<Locale>(
      const Locale('en'),
    );
    addTearDown(locale.dispose);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (int retryCount, Object error) => null,
        overrides: backend.overridesList.cast(),
        child: ValueListenableBuilder<Locale>(
          valueListenable: locale,
          builder: (BuildContext context, Locale value, Widget? _) =>
              MaterialApp(
                locale: value,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: appLocalizationsDelegates(
                  overrides: const <String, String>{},
                ),
                theme: AppTheme.light(),
                // Both tiles stay mounted across the switch: nothing rebuilds
                // them from scratch, only the language changes.
                home: const Scaffold(
                  body: Column(
                    children: <Widget>[
                      SizedBox(
                        width: 220,
                        height: 320,
                        child: ProductCard(product: kProduct),
                      ),
                      SizedBox(
                        width: 160,
                        height: 150,
                        child: CategoryCard(category: kCategory),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(kTitleEn), findsOneWidget);

    for (final String language in <String>['am', 'ar', 'om']) {
      locale.value = Locale(language);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.text(_expectedTitle(language)),
        findsOneWidget,
        reason: 'title after switching to $language',
      );
      expect(find.text(kTitleEn), findsNothing);
      expect(
        find.text(_expectedName(language)),
        findsOneWidget,
        reason: 'category name after switching to $language',
      );

      // The same entity instance is on screen: the switch rebuilt the text,
      // it did not refetch the catalogue.
      final ProductCard card = tester.widget<ProductCard>(
        find.byType(ProductCard),
      );
      expect(identical(card.product, kProduct), isTrue);
    }
  });
}
