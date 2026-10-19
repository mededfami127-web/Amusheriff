import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/router/routes.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/drafts/catalog_drafts.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/category.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product_media.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/repositories/catalog_repositories.dart';
import 'package:amu_sharif_majlis/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:amu_sharif_majlis/features/settings/domain/entities/site_settings.dart';
import 'package:amu_sharif_majlis/features/settings/presentation/providers/site_settings_providers.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/category_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/widgets/category_subcategory_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Storefront half of the subcategory feature.
///
/// A subcategory is reached from its mother category's page, and only from
/// there: the mother lists its own children as chips, and a subcategory of
/// another category — or a top-level category — never appears in that list.
void main() {
  late _FakeCategoryRepository categories;
  late _FakeProductRepository products;
  late _FakeProductMediaRepository media;

  setUp(() {
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
    products = _FakeProductRepository(const <Product>[]);
    media = _FakeProductMediaRepository();
  });

  Widget harness() {
    final GoRouter router = GoRouter(
      initialLocation: Routes.category('majlis'),
      routes: <RouteBase>[
        GoRoute(
          path: Routes.categoryPattern,
          builder: (_, GoRouterState state) =>
              CategoryPage(slug: state.pathParameters['slug'] ?? ''),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(categories),
        productRepositoryProvider.overrideWithValue(products),
        productMediaRepositoryProvider.overrideWithValue(media),
        siteSettingsValueProvider.overrideWithValue(SiteSettings.fallback),
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

  testWidgets('the mother category lists only its own subcategories', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.byType(CategorySubcategoryLine), findsOneWidget);
    expect(find.text('Corner Units'), findsOneWidget);
    // A top-level category is not a chip, and neither is another mother's child.
    expect(find.text('Bedrooms'), findsNothing);
    expect(find.text('Majlis'), findsWidgets);
  });

  testWidgets('tapping a subcategory chip opens that subcategory', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness());
    await settle(tester);

    await tester.tap(find.text('Corner Units'));
    await settle(tester);

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    // The subcategory page has no children of its own and no products yet, so
    // no chips are left and the empty state is what remains.
    expect(find.byType(CategoryPage), findsOneWidget);
    expect(find.byType(CategorySubcategoryLine), findsNothing);
    expect(find.text(l10n.stateEmptyTitle), findsOneWidget);
    expect(find.text('Corner Units'), findsWidgets);
  });
}

class _FakeCategoryRepository implements CategoryRepository {
  _FakeCategoryRepository(this.rows);

  List<Category> rows;

  @override
  Stream<List<Category>> watchAll() async* {
    yield rows;
  }

  @override
  Stream<List<Category>> watchVisible() async* {
    yield rows.where((Category c) => c.isVisible).toList(growable: false);
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
  Future<Category> create(CategoryDraft draft) async =>
      throw UnimplementedError();

  @override
  Future<Category> update(String id, CategoryDraft draft) async =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> setVisibility(String id, {required bool isVisible}) async {}

  @override
  Future<void> reorder(List<String> orderedIds) async {}
}

class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.rows);

  List<Product> rows;

  @override
  Stream<List<Product>> watch({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  }) async* {
    yield rows
        .where((Product p) => categoryId == null || p.categoryId == categoryId)
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
      const <Product>[];

  @override
  Future<Product> create(ProductDraft draft) async =>
      throw UnimplementedError();

  @override
  Future<Product> update(String id, ProductDraft draft) async =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> setPublished(String id, {required bool isPublished}) async {}

  @override
  Future<void> setFeatured(String id, {required bool isFeatured}) async {}

  @override
  Future<void> setAvailability(String id, {required bool isAvailable}) async {}

  @override
  Future<void> reorder(List<String> orderedIds) async {}
}

class _FakeProductMediaRepository implements ProductMediaRepository {
  @override
  Stream<List<ProductMedia>> watchAll() async* {
    yield const <ProductMedia>[];
  }

  @override
  Stream<List<ProductMedia>> watchForProduct(String productId) async* {
    yield const <ProductMedia>[];
  }

  @override
  Future<List<ProductMedia>> fetchForProduct(String productId) async =>
      const <ProductMedia>[];

  @override
  Future<ProductMedia> add(ProductMediaDraft draft) async =>
      throw UnimplementedError();

  @override
  Future<ProductMedia> update(String id, ProductMediaDraft draft) async =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> setCover(String productId, String mediaId) async {}

  @override
  Future<void> reorder(List<String> orderedIds) async {}
}
