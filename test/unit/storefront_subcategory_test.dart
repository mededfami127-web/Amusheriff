import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/router/routes.dart';
import 'package:amu_sharif_majlis/core/theme/app_theme.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/category.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product.dart';
import 'package:amu_sharif_majlis/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/category_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/storefront_home_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../layout/overflow_harness.dart';

/// Subcategories are names under their mother, never categories of their own.
///
/// The storefront half of the rule: the "Browse by category" rail, the chip row
/// beside "All products" and the grouped home sections list **root** rows only,
/// while a selected mother shows her children as small text chips and an
/// "All <mother>" chip that includes every child's products.
void main() {
  const List<Category> rows = <Category>[
    Category(id: 'c1', name: 'Majlis', slug: 'majlis', sortOrder: 0),
    Category(
      id: 'c2',
      name: 'Corner Units',
      slug: 'corner-units',
      parentId: 'c1',
      sortOrder: 1,
    ),
    Category(
      id: 'c3',
      name: 'Floor Seating',
      slug: 'floor-seating',
      parentId: 'c1',
      sortOrder: 2,
    ),
    Category(id: 'c4', name: 'Bedrooms', slug: 'bedrooms', sortOrder: 3),
  ];

  const List<Product> products = <Product>[
    Product(id: 'p1', categoryId: 'c1', title: 'Damascus Sofa', price: 100),
    Product(id: 'p2', categoryId: 'c2', title: 'Corner Sofa', price: 200),
    Product(id: 'p3', categoryId: 'c4', title: 'Bed Frame', price: 300),
  ];

  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend(categoryRows: rows, productRows: products);
  });

  Widget home({Locale locale = const Locale('en')}) => ProviderScope(
    retry: (int retryCount, Object error) => null,
    overrides: backend.overridesList.cast(),
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(),
      home: const StorefrontHomePage(),
    ),
  );

  Widget categoryPage(String slug, {Locale locale = const Locale('en')}) {
    final GoRouter router = GoRouter(
      initialLocation: Routes.category(slug),
      routes: <RouteBase>[
        GoRoute(
          path: Routes.categoryPattern,
          builder: (_, GoRouterState state) =>
              CategoryPage(slug: state.pathParameters['slug'] ?? ''),
        ),
      ],
    );

    return ProviderScope(
      retry: (int retryCount, Object error) => null,
      overrides: backend.overridesList.cast(),
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light(),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  Finder rootChips() => find.byKey(const ValueKey<String>('home-root-chips'));
  Finder childChips() =>
      find.byKey(const ValueKey<String>('home-subcategory-chips'));

  Future<void> selectRoot(WidgetTester tester, String name) async {
    await tester.tap(
      find.descendant(of: rootChips(), matching: find.text(name)),
    );
    await settle(tester);
  }

  testWidgets('the home rail and root chips list roots only', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(home());
    await settle(tester);

    expect(find.text('Majlis'), findsWidgets);
    expect(find.text('Bedrooms'), findsWidgets);
    // Two root tiles, and no subcategory among them.
    expect(find.byType(CategoryCard), findsNWidgets(2));
    expect(
      find.descendant(of: rootChips(), matching: find.text('Corner Units')),
      findsNothing,
    );
    expect(
      find.descendant(of: rootChips(), matching: find.text('Floor Seating')),
      findsNothing,
    );
    expect(childChips(), findsNothing);
  });

  testWidgets('selecting a root shows its children as text chips', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(home());
    await settle(tester);
    await selectRoot(tester, 'Majlis');

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    expect(childChips(), findsOneWidget);
    expect(
      find.descendant(
        of: childChips(),
        matching: find.text(l10n.labelAllInCategory('Majlis')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: childChips(), matching: find.text('Corner Units')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: childChips(), matching: find.text('Floor Seating')),
      findsOneWidget,
    );

    // "All Majlis" is selected by default: the mother's own product and its
    // child's product are both on screen.
    expect(find.text('Damascus Sofa'), findsWidgets);
    expect(find.text('Corner Sofa'), findsWidgets);
    expect(find.text('Bed Frame'), findsNothing);
  });

  testWidgets('a subcategory chip filters to that child alone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(home());
    await settle(tester);
    await selectRoot(tester, 'Majlis');

    await tester.tap(
      find.descendant(of: childChips(), matching: find.text('Corner Units')),
    );
    await settle(tester);

    expect(find.text('Corner Sofa'), findsWidgets);
    // The mother's own product and her other child's are filtered out.
    expect(find.text('Damascus Sofa'), findsNothing);
    expect(find.text('Bed Frame'), findsNothing);
  });

  testWidgets('a root without children shows no subcategory row', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(home());
    await settle(tester);
    await selectRoot(tester, 'Bedrooms');

    expect(childChips(), findsNothing);
    expect(find.text('Bed Frame'), findsWidgets);
  });

  testWidgets('the subcategory row runs right-to-left in Arabic', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(home(locale: const Locale('ar')));
    await settle(tester);
    await selectRoot(tester, 'Majlis');

    expect(Directionality.of(tester.element(childChips())), TextDirection.rtl);

    final double first = tester
        .getCenter(
          find.descendant(
            of: childChips(),
            matching: find.text('Corner Units'),
          ),
        )
        .dx;
    final double second = tester
        .getCenter(
          find.descendant(
            of: childChips(),
            matching: find.text('Floor Seating'),
          ),
        )
        .dx;
    // Chips are laid out from the right edge inwards.
    expect(second, lessThan(first));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a root category page lists its children as names only', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(categoryPage('majlis'));
    await settle(tester);

    final Finder chips = find.byKey(
      const ValueKey<String>('category-name-chips'),
    );
    expect(chips, findsOneWidget);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );
    expect(
      find.descendant(
        of: chips,
        matching: find.text(l10n.labelAllInCategory('Majlis')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: chips, matching: find.text('Corner Units')),
      findsOneWidget,
    );

    // The mother's page shows her own product plus her children's.
    expect(find.text('Damascus Sofa'), findsWidgets);
    expect(find.text('Corner Sofa'), findsWidgets);
    expect(find.text('Bed Frame'), findsNothing);
  });

  testWidgets('a subcategory page shows a breadcrumb and only its products', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(categoryPage('corner-units'));
    await settle(tester);

    expect(
      find.byKey(const ValueKey<String>('category-name-chips')),
      findsNothing,
    );
    expect(find.text('Corner Sofa'), findsWidgets);
    expect(find.text('Damascus Sofa'), findsNothing);
    // "Majlis › Corner Units" — the mother is a step back into the tree.
    expect(find.text('Majlis'), findsOneWidget);
  });

  test(
    'rootCategories excludes subcategories and childCategories finds them',
    () async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(backend.categories),
          productRepositoryProvider.overrideWithValue(backend.products),
          productMediaRepositoryProvider.overrideWithValue(backend.media),
        ],
      );
      addTearDown(container.dispose);
      // Keep the stream subscriptions alive: a bare `read` of an auto-disposed
      // provider is torn down before the fake emits its first value.
      final rootsSub = container.listen(
        rootCategoriesProvider,
        (_, __) {},
        fireImmediately: true,
      );
      final childrenSub = container.listen(
        childCategoriesProvider('c1'),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(rootsSub.close);
      addTearDown(childrenSub.close);

      final List<Category> roots = await container.read(
        rootCategoriesProvider.future,
      );
      expect(roots.map((Category c) => c.id).toList(), <String>['c1', 'c4']);

      final List<Category> children = await container.read(
        childCategoriesProvider('c1').future,
      );
      expect(children.map((Category c) => c.id).toList(), <String>['c2', 'c3']);
    },
  );
}
