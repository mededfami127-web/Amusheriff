import 'dart:async';

import 'package:amu_sharif_majlis/core/errors/app_failure.dart';
import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/router/routes.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_categories_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_product_editor_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_products_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/widgets/admin_text_field.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/drafts/catalog_drafts.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/category.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product_media.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/repositories/catalog_repositories.dart';
import 'package:amu_sharif_majlis/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget-level coverage for the admin gateway.
///
/// Every repository is faked, so these tests exercise the real widgets,
/// providers and router without touching Supabase: the list renders what the
/// repository streams, a tap opens the editor with the saved draft, a
/// validation failure stays on the sheet, and a valid save reaches the
/// repository.
void main() {
  late _FakeCategoryRepository categories;
  late _FakeProductRepository products;
  late _FakeProductMediaRepository media;

  setUp(() {
    categories = _FakeCategoryRepository(<Category>[
      const Category(id: 'c1', name: 'Majlis', slug: 'majlis'),
    ]);
    products = _FakeProductRepository(<Product>[
      const Product(
        id: 'p1',
        categoryId: 'c1',
        title: 'Damascus Sofa',
        price: 18500,
      ),
    ]);
    media = _FakeProductMediaRepository();
  });

  Widget harness({String location = Routes.adminProducts}) {
    final GoRouter router = GoRouter(
      initialLocation: location,
      routes: <RouteBase>[
        GoRoute(
          path: Routes.adminCategories,
          builder: (_, __) => const AdminCategoriesPage(),
        ),
        GoRoute(
          path: Routes.adminProducts,
          builder: (_, __) => const AdminProductsPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'new',
              builder: (_, __) => const AdminProductEditorPage(),
            ),
            GoRoute(
              path: ':id',
              builder: (_, GoRouterState state) =>
                  AdminProductEditorPage(productId: state.pathParameters['id']),
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(categories),
        productRepositoryProvider.overrideWithValue(products),
        productMediaRepositoryProvider.overrideWithValue(media),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// The forms are taller than the 800x600 default test window, and a tap on an
  /// off-screen button is silently missed. Give the sheet and the editor room.
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('products list renders the repository rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.text('Damascus Sofa'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });

  testWidgets('an empty catalogue shows the empty state', (
    WidgetTester tester,
  ) async {
    products = _FakeProductRepository(const <Product>[]);
    await tester.pumpWidget(harness());
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );
    expect(find.text(l10n.adminNoProducts), findsOneWidget);
  });

  testWidgets('tapping a product opens the editor seeded with its draft', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    await tester.tap(find.text('Damascus Sofa'));
    await settle(tester);

    // The editor renders the draft the repository holds.
    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );
    expect(find.byType(AdminProductEditorPage), findsOneWidget);
    expect(find.text(l10n.adminProductTitle), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AdminProductEditorPage),
        matching: find.text('Damascus Sofa'),
      ),
      findsOneWidget,
    );
    expect(products.saved, isEmpty);
  });

  testWidgets('saving the editor persists through the repository', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    await tester.tap(find.text('Damascus Sofa'));
    await settle(tester);

    // The form is long, so the save button is below the fold.
    await tester.scrollUntilVisible(
      find.text('Save'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester);

    expect(products.saved, hasLength(1));
    expect(products.saved.single.title, 'Damascus Sofa');
    expect(products.saved.single.price, 18500);
  });

  testWidgets('a new product saves once a category and title are given', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(location: Routes.adminProductNew));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // Creating a product is the flow the owner reported as a dead Save button:
    // pick the category from the dropdown, then name the product.
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await settle(tester);
    await tester.tap(find.text('Majlis').last);
    await settle(tester);

    // The title is the first free-text field; the dropdown above it is not one.
    await tester.enterText(find.byType(TextField).first, 'Aleppo Bench');
    await settle(tester);

    await tester.scrollUntilVisible(
      find.text(l10n.actionSave),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    expect(products.saved, hasLength(1));
    expect(products.saved.single.title, 'Aleppo Bench');
    expect(products.saved.single.categoryId, 'c1');
    expect(find.text(l10n.adminProductSaved), findsOneWidget);
  });

  testWidgets('a product can be filed under a subcategory', (
    WidgetTester tester,
  ) async {
    categories = _FakeCategoryRepository(<Category>[
      const Category(id: 'c1', name: 'Majlis', slug: 'majlis'),
      const Category(
        id: 'c2',
        name: 'Corner Units',
        slug: 'corner-units',
        parentId: 'c1',
        sortOrder: 1,
      ),
      const Category(id: 'c3', name: 'Bedrooms', slug: 'bedrooms'),
    ]);
    await tester.pumpWidget(harness(location: Routes.adminProductNew));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // The category dropdown lists mothers only; the subcategory one appears
    // after a mother that has children is chosen.
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await settle(tester);
    await tester.tap(find.text('Majlis').last);
    await settle(tester);

    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await settle(tester);

    // The child is offered indented, directly under its mother, so the owner
    // can tell the two apart.
    expect(find.text('— Corner Units'), findsOneWidget);
    await tester.tap(find.text('— Corner Units').last);
    await settle(tester);

    await tester.enterText(find.byType(TextField).first, 'Corner Sofa');
    await settle(tester);

    await tester.scrollUntilVisible(
      find.text(l10n.actionSave),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    expect(products.saved, hasLength(1));
    expect(products.saved.single.categoryId, 'c2');
  });

  testWidgets('category sheet blocks an invalid slug and saves a valid one', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(location: Routes.adminCategories));
    await settle(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // English name given, slug left invalid (upper-case and a space).
    await tester.enterText(find.byType(TextField).first, 'Chaise');
    await tester.enterText(_slugField(l10n), 'Chaise Longue');
    await tester.ensureVisible(find.text(l10n.actionSave));
    await settle(tester);
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    expect(categories.saved, isEmpty);
    expect(find.text(l10n.validateSlug), findsOneWidget);

    await tester.enterText(_slugField(l10n), 'chaise-longue');
    await tester.ensureVisible(find.text(l10n.actionSave));
    await settle(tester);
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    expect(categories.saved, hasLength(1));
    expect(categories.saved.single.slug, 'chaise-longue');
    expect(categories.saved.single.name, 'Chaise');
  });

  testWidgets('a category created with a name only saves with a derived slug', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(location: Routes.adminCategories));
    await settle(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // The hint under the slug field promises this: a name and nothing else is
    // enough, because `categories.slug` is NOT NULL and a form that refuses to
    // explain itself is the failure the owner reported.
    await tester.enterText(find.byType(TextField).first, 'Majlis Sofas');
    await settle(tester);
    expect(find.text('majlis-sofas'), findsOneWidget);

    await tester.ensureVisible(find.text(l10n.actionSave));
    await settle(tester);
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    expect(categories.saved, hasLength(1));
    expect(categories.saved.single.name, 'Majlis Sofas');
    expect(categories.saved.single.slug, 'majlis-sofas');
    // The sheet closed and the list page said what happened.
    expect(find.text(l10n.adminCategoryCreated), findsOneWidget);
  });

  testWidgets('a typed slug is never overwritten by the derived one', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(location: Routes.adminCategories));
    await settle(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    await tester.enterText(find.byType(TextField).first, 'Majlis Sofas');
    await tester.enterText(_slugField(l10n), 'sofas-majlis');
    await settle(tester);

    await tester.ensureVisible(find.text(l10n.actionSave));
    await settle(tester);
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    expect(categories.saved.single.slug, 'sofas-majlis');
  });

  testWidgets('subcategories nest under their mother and carry its id', (
    WidgetTester tester,
  ) async {
    categories = _FakeCategoryRepository(<Category>[
      const Category(id: 'c1', name: 'Majlis', slug: 'majlis'),
      const Category(
        id: 'c2',
        name: 'Corner Units',
        slug: 'corner-units',
        parentId: 'c1',
        sortOrder: 1,
      ),
      const Category(id: 'c3', name: 'Bedrooms', slug: 'bedrooms'),
    ]);
    await tester.pumpWidget(harness(location: Routes.adminCategories));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // Both levels render, and the child is marked as one.
    expect(find.text('Majlis'), findsOneWidget);
    expect(find.text('Corner Units'), findsOneWidget);
    expect(find.text('Bedrooms'), findsOneWidget);
    expect(find.byIcon(Icons.subdirectory_arrow_right_rounded), findsOneWidget);
    // Only the two top-level rows offer the action.
    expect(find.text(l10n.adminCategoryAddSubcategory), findsNWidgets(2));

    // Adding one from the mother's row presets the parent on the draft.
    await tester.tap(find.text(l10n.adminCategoryAddSubcategory).first);
    await settle(tester);
    expect(find.text(l10n.adminCategoryAddSubcategory), findsWidgets);

    await tester.enterText(find.byType(TextField).first, 'Sectionals');
    await settle(tester);
    await tester.ensureVisible(find.text(l10n.actionSave));
    await settle(tester);
    await tester.tap(find.text(l10n.actionSave).last);
    await settle(tester);

    expect(categories.saved, hasLength(1));
    expect(categories.saved.single.parentId, 'c1');
    expect(categories.saved.single.slug, 'sectionals');
  });

  testWidgets('a refused save shows the database code and message', (
    WidgetTester tester,
  ) async {
    useTallScreen(tester);
    categories.failure = const ValidationFailure(
      messageKey: 'errorDuplicate',
      debugMessage: 'duplicate key value',
      cause: PostgrestException(
        message: 'duplicate key value violates unique constraint "categories_slug_key"',
        code: '23505',
      ),
    );
    await tester.pumpWidget(harness(location: Routes.adminCategories));
    await settle(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    await tester.enterText(find.byType(TextField).first, 'Chaise');
    await tester.ensureVisible(find.text(l10n.actionSave));
    await settle(tester);
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    // The banner keeps the friendly sentence *and* the backend's own words.
    expect(find.text(l10n.errorDuplicate), findsWidgets);
    expect(find.textContaining('23505'), findsOneWidget);
    expect(find.textContaining('categories_slug_key'), findsOneWidget);
  });

  testWidgets('a double tap on Save creates one category', (
    WidgetTester tester,
  ) async {
    useTallScreen(tester);
    categories.gate = Completer<void>();
    await tester.pumpWidget(harness(location: Routes.adminCategories));
    await settle(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    await tester.enterText(find.byType(TextField).first, 'Chaise');
    await tester.ensureVisible(find.text(l10n.actionSave));
    await settle(tester);

    // Two taps in the same frame, before the button can repaint as disabled.
    await tester.tap(find.text(l10n.actionSave));
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    categories.gate!.complete();
    await settle(tester);

    expect(categories.saved, hasLength(1));
  });

  testWidgets('a refused product save shows the database code and message', (
    WidgetTester tester,
  ) async {
    useTallScreen(tester);
    products.failure = const PermissionFailure(
      debugMessage: 'permission denied',
      cause: PostgrestException(
        message: 'permission denied for table products',
        code: '42501',
      ),
    );
    await tester.pumpWidget(harness());
    await settle(tester);

    await tester.tap(find.text('Damascus Sofa'));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    await tester.scrollUntilVisible(
      find.text(l10n.actionSave),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    expect(find.text(l10n.errorPermission), findsWidgets);
    expect(find.textContaining('42501'), findsOneWidget);
    expect(
      find.textContaining('permission denied for table products'),
      findsOneWidget,
    );
  });

  testWidgets('a double tap on Save edits one product', (
    WidgetTester tester,
  ) async {
    useTallScreen(tester);
    products.gate = Completer<void>();
    await tester.pumpWidget(harness());
    await settle(tester);

    await tester.tap(find.text('Damascus Sofa'));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    await tester.scrollUntilVisible(
      find.text(l10n.actionSave),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);

    await tester.tap(find.text(l10n.actionSave));
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    products.gate!.complete();
    await settle(tester);

    expect(products.saved, hasLength(1));
  });

  testWidgets('a mother with subcategories is not deleted silently', (
    WidgetTester tester,
  ) async {
    categories = _FakeCategoryRepository(<Category>[
      const Category(id: 'c1', name: 'Majlis', slug: 'majlis'),
      const Category(
        id: 'c2',
        name: 'Corner Units',
        slug: 'corner-units',
        parentId: 'c1',
      ),
    ]);
    await tester.pumpWidget(harness(location: Routes.adminCategories));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await settle(tester);

    expect(find.text(l10n.adminCategoryHasSubcategories), findsOneWidget);
  });

  testWidgets('changing the mother category clears the chosen subcategory', (
    WidgetTester tester,
  ) async {
    categories = _FakeCategoryRepository(<Category>[
      const Category(id: 'c1', name: 'Majlis', slug: 'majlis'),
      const Category(
        id: 'c2',
        name: 'Corner Units',
        slug: 'corner-units',
        parentId: 'c1',
        sortOrder: 1,
      ),
      const Category(id: 'c4', name: 'Bedrooms', slug: 'bedrooms'),
    ]);
    await tester.pumpWidget(harness(location: Routes.adminProductNew));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // Majlis → Corner Units.
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await settle(tester);
    await tester.tap(find.text('Majlis').last);
    await settle(tester);
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await settle(tester);
    await tester.tap(find.text('— Corner Units').last);
    await settle(tester);

    // Bedrooms has no children, so the second dropdown disappears and the
    // subcategory that belonged to Majlis is gone with it.
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await settle(tester);
    await tester.tap(find.text('Bedrooms').last);
    await settle(tester);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Bed Frame');
    await settle(tester);
    await tester.scrollUntilVisible(
      find.text(l10n.actionSave),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    expect(products.saved, hasLength(1));
    expect(products.saved.single.categoryId, 'c4');
  });

  testWidgets('editing a subcategory keeps it under its mother', (
    WidgetTester tester,
  ) async {
    useTallScreen(tester);
    categories = _FakeCategoryRepository(<Category>[
      const Category(id: 'c1', name: 'Majlis', slug: 'majlis'),
      const Category(
        id: 'c2',
        name: 'Corner Units',
        slug: 'corner-units',
        parentId: 'c1',
        sortOrder: 1,
      ),
    ]);
    await tester.pumpWidget(harness(location: Routes.adminCategories));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // The subcategory row is the second tile, so its edit button is the last.
    await tester.tap(find.byIcon(Icons.edit_outlined).last);
    await settle(tester);

    expect(find.text(l10n.adminCategoryParent), findsOneWidget);
    await tester.ensureVisible(find.text(l10n.actionSave));
    await settle(tester);
    await tester.tap(find.text(l10n.actionSave));
    await settle(tester);

    expect(categories.saved, hasLength(1));
    expect(categories.saved.single.parentId, 'c1');
  });

  testWidgets('a root with subcategories cannot become a subcategory', (
    WidgetTester tester,
  ) async {
    useTallScreen(tester);
    categories = _FakeCategoryRepository(<Category>[
      const Category(id: 'c1', name: 'Majlis', slug: 'majlis'),
      const Category(
        id: 'c2',
        name: 'Corner Units',
        slug: 'corner-units',
        parentId: 'c1',
      ),
      const Category(id: 'c3', name: 'Bedrooms', slug: 'bedrooms'),
    ]);
    await tester.pumpWidget(harness(location: Routes.adminCategories));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // The first edit icon belongs to the mother row.
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await settle(tester);

    expect(find.text(l10n.adminCategoryParentLocked), findsOneWidget);
  });

  testWidgets(
    'the product editor offers category creation when there are none',
    (WidgetTester tester) async {
      categories = _FakeCategoryRepository(const <Category>[]);
      await tester.pumpWidget(harness(location: Routes.adminProductNew));
      await settle(tester);

      final AppLocalizations l10n = await AppLocalizations.delegate.load(
        const Locale('en'),
      );

      // A product needs a category, so an empty catalogue explains the gate and
      // offers the way through it instead of an empty dropdown.
      expect(find.text(l10n.adminCreateCategory), findsOneWidget);

      await tester.tap(find.text(l10n.adminCreateCategory));
      await settle(tester);
      expect(find.byType(AdminCategoriesPage), findsOneWidget);
    },
  );

  testWidgets(
    'a product without a category says so instead of failing quietly',
    (WidgetTester tester) async {
      categories = _FakeCategoryRepository(const <Category>[]);
      await tester.pumpWidget(harness(location: Routes.adminProductNew));
      await settle(tester);

      final AppLocalizations l10n = await AppLocalizations.delegate.load(
        const Locale('en'),
      );

      // Save sits at the end of a lazy list, so scroll to it first.
      await tester.scrollUntilVisible(
        find.text(l10n.actionSave),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await settle(tester);
      await tester.tap(find.text(l10n.actionSave));
      await settle(tester);

      // Nothing was written, and the reason is on screen: an unexplained no-op
      // is what the owner reported as "the Save button does nothing".
      expect(products.saved, isEmpty);
      expect(find.text(l10n.errorValidation), findsOneWidget);
    },
  );
}

class _FakeCategoryRepository implements CategoryRepository {
  _FakeCategoryRepository(this.rows);

  List<Category> rows;
  final List<CategoryDraft> saved = <CategoryDraft>[];

  /// Thrown by the next write, so a refused save can be asserted.
  Object? failure;

  /// Held open by the double-tap tests to keep `saving` true across two taps.
  Completer<void>? gate;

  @override
  Stream<List<Category>> watchAll() async* {
    yield rows;
  }

  @override
  Stream<List<Category>> watchVisible() async* {
    yield rows.where((Category c) => c.isVisible).toList(growable: false);
  }

  @override
  Stream<List<Category>> watchVisibleRoots() async* {
    yield rows
        .where((Category c) => c.isVisible && c.parentId == null)
        .toList(growable: false);
  }

  @override
  Stream<List<Category>> watchVisibleChildren(String parentId) async* {
    yield rows
        .where((Category c) => c.isVisible && c.parentId == parentId)
        .toList(growable: false);
  }

  @override
  Future<List<Category>> fetchVisible() async => rows;

  @override
  Future<Category?> findById(String id) async =>
      rows.where((Category c) => c.id == id).firstOrNull;

  @override
  Future<Category?> findBySlug(String slug) async =>
      rows.where((Category c) => c.slug == slug).firstOrNull;

  @override
  Future<Category> create(CategoryDraft draft) async {
    saved.add(draft);
    if (gate != null) await gate!.future;
    if (failure case final Object error) throw error;
    final Category created = Category(
      id: 'c${rows.length + 1}',
      name: draft.name,
      slug: draft.slug,
    );
    rows = <Category>[...rows, created];
    return created;
  }

  @override
  Future<Category> update(String id, CategoryDraft draft) async {
    saved.add(draft);
    if (gate != null) await gate!.future;
    if (failure case final Object error) throw error;
    final Category updated = Category(
      id: id,
      name: draft.name,
      slug: draft.slug,
    );
    rows = rows
        .map((Category c) => c.id == id ? updated : c)
        .toList(growable: false);
    return updated;
  }

  @override
  Future<void> delete(String id) async =>
      rows = rows.where((Category c) => c.id != id).toList(growable: false);

  @override
  Future<void> setVisibility(String id, {required bool isVisible}) async {
    rows = rows
        .map((Category c) => c.id == id ? c.copyWith(isVisible: isVisible) : c)
        .toList(growable: false);
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {}
}

class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.rows);

  List<Product> rows;
  final List<ProductDraft> saved = <ProductDraft>[];

  /// Thrown by the next write, so a refused save can be asserted.
  Object? failure;

  /// Held open by the double-tap tests to keep `saving` true across two taps.
  Completer<void>? gate;

  @override
  Stream<List<Product>> watch({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  }) async* {
    yield rows
        .where((Product p) => categoryId == null || p.categoryId == categoryId)
        .where((Product p) => !onlyPublished || p.isPublished)
        .where((Product p) => !onlyFeatured || p.isFeatured)
        .toList(growable: false);
  }

  @override
  Stream<Product?> watchOne(String id) async* {
    yield rows.where((Product p) => p.id == id).firstOrNull;
  }

  @override
  Future<List<Product>> fetch({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  }) async => rows;

  @override
  Future<Product?> findById(String id) async =>
      rows.where((Product p) => p.id == id).firstOrNull;

  @override
  Future<List<Product>> search(String query, {int limit = 40}) async =>
      rows.where((Product p) => p.title.contains(query)).take(limit).toList();

  @override
  Future<Product> create(ProductDraft draft) async {
    saved.add(draft);
    if (gate != null) await gate!.future;
    if (failure case final Object error) throw error;
    final Product created = Product(
      id: 'p${rows.length + 1}',
      categoryId: draft.categoryId,
      title: draft.title,
      price: draft.price,
    );
    rows = <Product>[...rows, created];
    return created;
  }

  @override
  Future<Product> update(String id, ProductDraft draft) async {
    saved.add(draft);
    if (gate != null) await gate!.future;
    if (failure case final Object error) throw error;
    final Product updated = Product(
      id: id,
      categoryId: draft.categoryId,
      title: draft.title,
      price: draft.price,
      isPublished: draft.isPublished,
      isFeatured: draft.isFeatured,
    );
    rows = rows.map((Product p) => p.id == id ? updated : p).toList();
    return updated;
  }

  @override
  Future<void> delete(String id) async =>
      rows = rows.where((Product p) => p.id != id).toList(growable: false);

  @override
  Future<void> setPublished(String id, {required bool isPublished}) async {
    rows = rows
        .map(
          (Product p) => p.id == id ? p.copyWith(isPublished: isPublished) : p,
        )
        .toList(growable: false);
  }

  @override
  Future<void> setFeatured(String id, {required bool isFeatured}) async {
    rows = rows
        .map((Product p) => p.id == id ? p.copyWith(isFeatured: isFeatured) : p)
        .toList(growable: false);
  }

  @override
  Future<void> setAvailability(String id, {required bool isAvailable}) async {
    rows = rows
        .map(
          (Product p) => p.id == id ? p.copyWith(isAvailable: isAvailable) : p,
        )
        .toList(growable: false);
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {}
}

class _FakeProductMediaRepository implements ProductMediaRepository {
  final List<ProductMedia> rows = <ProductMedia>[];

  @override
  Stream<List<ProductMedia>> watchAll() async* {
    yield rows;
  }

  @override
  Stream<List<ProductMedia>> watchForProduct(String productId) async* {
    yield rows.where((ProductMedia m) => m.productId == productId).toList();
  }

  @override
  Future<List<ProductMedia>> fetchForProduct(String productId) async =>
      rows.where((ProductMedia m) => m.productId == productId).toList();

  @override
  Future<ProductMedia> add(ProductMediaDraft draft) async {
    final ProductMedia created = ProductMedia(
      id: 'm${rows.length + 1}',
      productId: draft.productId,
      kind: draft.kind,
      storagePath: draft.storagePath,
      isCover: draft.isCover,
      sortOrder: draft.sortOrder,
    );
    rows.add(created);
    return created;
  }

  @override
  Future<ProductMedia> update(String id, ProductMediaDraft draft) async {
    final ProductMedia updated = ProductMedia(
      id: id,
      productId: draft.productId,
      kind: draft.kind,
      storagePath: draft.storagePath,
    );
    return updated;
  }

  @override
  Future<void> delete(String id) async =>
      rows.removeWhere((ProductMedia m) => m.id == id);

  @override
  Future<void> setCover(String productId, String mediaId) async {}

  @override
  Future<void> reorder(List<String> orderedIds) async {}
}

/// The slug input of the category sheet, addressed by its label.
///
/// A positional finder (`TextField.at(3)`) silently pointed at the wrong field
/// as soon as the sheet gained another language, so the label — which is what
/// the owner actually reads — is the anchor.
Finder _slugField(AppLocalizations l10n) => find.descendant(
  of: find.widgetWithText(AdminTextField, l10n.adminSlug),
  matching: find.byType(TextField),
);
