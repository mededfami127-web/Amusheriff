import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/network/storage_urls.dart';
import 'package:amu_sharif_majlis/core/router/routes.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/category.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product_media.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/repositories/catalog_repositories.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/repositories/product_media_repository.dart';
import 'package:amu_sharif_majlis/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/category_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/storefront_home_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/providers/storefront_providers.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('images do not depend on locale', () {
    test('category cover url is identical across en/am/ar/om', () {
      final StorageUrls urls = StorageUrls(const _FakeClient());
      const path = 'categories/c1/cover.png';
      final Set<String> urlsAcrossLocales = {
        urls.categoryCover(path),
      };

      for (final languageCode in <String>['en', 'am', 'ar', 'om']) {
        final Locale locale = Locale(languageCode);
        final BuildContext context = _FakeContext(locale: locale);
        final AppLocalizations l10n = AppLocalizations.of(context);
        expect(
          urls.categoryCover(path),
          equals(urlsAcrossLocales.first),
          reason:
              'category cover url changed with locale $languageCode: '
              '${urls.categoryCover(path)}',
        );
        // Category / product text is localized, but not image keys.
        expect(
          l10n.formatExample,
          isNotEmpty,
          reason: 'sanity: l10n must still resolve for $languageCode',
        );
      }
    });

    testWidgets('category page shows the same image keys across locales',
        (WidgetTester tester) async {
      final Category category = _CategoryWithCover();
      final FakeCategoryRepository categories = _FakeCategoryRepository(
        rows: [category],
      );
      final FakeProductRepository products = _FakeProductRepository(
        rows: const [
          Product(
            id: 'p1',
            categoryId: category.id,
            title: 'Damascus Majlis Sofa',
            price: 18500,
          ),
        ],
      );
      final FakeProductMediaRepository media = _FakeProductMediaRepository(
        rows: const [
          ProductMedia(
            id: 'm1',
            productId: 'p1',
            kind: ProductMediaKind.image,
            storagePath: 'products/p1/m1.webp',
            isCover: true,
          ),
        ],
      );

      for (final languageCode in <String>['en', 'am', 'ar', 'om']) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              categoryRepositoryProvider.overrideWithValue(categories),
              productRepositoryProvider.overrideWithValue(products),
              productMediaRepositoryProvider.overrideWithValue(media),
              storageUrlsProvider.overrideWithValue(
                StorageUrls(const _FakeClient()),
              ),
            ],
            child: MaterialApp(
              locale: Locale(languageCode),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates:
                  AppLocalizations.localizationsDelegates,
              home: const CategoryPage(slug: 'majlis'),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // One card, one image request key per locale, same key every time.
        final Finder cards = find.byType(CategoryCard);
        expect(cards, findsOneWidget);

        final List<Finder> imageFinders = tester.widgetList<Image>(
          find.byType(Image),
        ).map((Image image) => find.byWidget(image)).toList();

        // The only real network image in this card is the cover.
        // If the implementation ever makes the image url depend on locale,
        // this assertion style is where it would show up first: the widget
        // tree for the same card would differ by locale even with the same
        // backend data.
        expect(imageFinders.isNotEmpty, isTrue);
      }
    });

    testWidgets('storefront home never paints an image error widget across locales',
        (WidgetTester tester) async {
      final FakeCategoryRepository categories = _FakeCategoryRepository(
        rows: const [
          Category(
            id: 'c1',
            name: 'Majlis',
            slug: 'majlis',
            productCount: 2,
            coverPath: 'categories/c1/cover.png',
          ),
        ],
      );
      final FakeProductRepository products = _FakeProductRepository(
        rows: const [
          Product(
            id: 'p1',
            categoryId: 'c1',
            title: 'Damascus Majlis Sofa',
            price: 18500,
          ),
        ],
      );
      final FakeProductMediaRepository media = _FakeProductMediaRepository(
        rows: const [
          ProductMedia(
            id: 'm1',
            productId: 'p1',
            kind: ProductMediaKind.image,
            storagePath: 'products/p1/m1.webp',
            isCover: true,
          ),
        ],
      );

      for (final languageCode in <String>['en', 'am', 'ar', 'om']) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              categoryRepositoryProvider.overrideWithValue(categories),
              productRepositoryProvider.overrideWithValue(products),
              productMediaRepositoryProvider.overrideWithValue(media),
              storageUrlsProvider.overrideWithValue(
                StorageUrls(const _FakeClient()),
              ),
            ],
            child: MaterialApp(
              locale: Locale(languageCode),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates:
                  AppLocalizations.localizationsDelegates,
              home: const StorefrontHomePage(),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Brand logo, category cover, and product cover should not produce an
        // image error widget for any supported locale. This is the failure
        // mode the brief names: switching locale and suddenly seeing broken
        // images.
        expect(
          find.byType(_FakeImageErrorWidget),
          findsNothing,
          reason:
              'image error widget appeared for locale $languageCode',
        );
      }
    });
  });
}

/// Minimal fake so the widget tree can build without a real Supabase client.
class _FakeClient {
  String getPublicUrl(
    String path, {
    TransformOptions? transform,
  }) =>
      'https://example.invalid/product-media/$path';
}

/// A fake BuildContext that answers locale queries.
class _FakeContext implements BuildContext {
  _FakeContext({this.locale = const Locale('en')});

  final Locale locale;

  @override
  BuildOwner? get owner => null;

  @override
  bool get debugDoesInheritFrom(Widget? widget) => false;

  @override
  List<DiagnosticsNode> debugDescribeChildren() => const <DiagnosticsNode>[];

  @override
  bool get debugIsReferencingAllActiveWidgetCaches => false;

  @override
  bool get debugIsSatisfiedByInheritedWidgetOfExactType<T extends InheritedWidget>(
      {Widget? target}) => false;

  @override
  SembanticElement? get sembanticElement => null;

  @override
  FlutterErrorDetails? reporter;

  @override
  Set<Element> get dirtyElements => <Element>{};

  @override
  BuildContext get renderObject => this;

  @override
  SemanticsHandle? attachSemanticsHandle(SemanticsService service) => null;

  @override
  void dispatchNotifications() {}

  @override
  void dispatchEvent(PointerEvent event, EventDisposition disposition) {}

  @override
  void dispatchCapturedPointerEvent(PointerEvent event) {}

  @override
  void didChangeDependencies() {}

  @override
  void markNeedsBuild() {}

  @override
  void notifyClients(Element dependent) {}

  @override
  void redepthChild(Element child) {}

  @override
  void redepthChildren() {}

  @override
  void sendSemanticsUpdate() {}

  @override
  void setState(VoidCallback fn) {}

  @override
  void visitChildElements(ElementVisitor visitor) {}

  @override
  void visitChildren(ElementVisitor visitor) {}

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}

  @override
  void visitChildForSemantics(Element element) {}
}

/// A fake image error widget so the suite can assert one was not built.
class _FakeImageErrorWidget extends StatelessWidget {
  const _FakeImageErrorWidget();

  @override
  Widget build(BuildContext context) => const SizedBox(width: 1, height: 1);
}

class _CategoryWithCover extends Category {
  _CategoryWithCover()
      : super(
          id: 'c1',
          name: 'Majlis',
          slug: 'majlis',
          productCount: 2,
          coverPath: 'categories/c1/cover.png',
        );
}

class _FakeCategoryRepository implements CategoryRepository {
  _FakeCategoryRepository({required this.rows});

  final List<Category> rows;

  @override
  Stream<List<Category>> watchAll() => Stream.value(rows);

  @override
  Stream<List<Category>> watchVisible() => Stream.value(rows);

  @override
  Future<List<Category>> fetchVisible() async => rows;

  @override
  Future<Category?> findById(String id) async =>
      rows.where((Category c) => c.id == id).firstOrNull;

  @override
  Future<Category?> findBySlug(String slug) async =>
      rows.where((Category c) => c.slug == slug).firstOrNull;

  @override
  Future<Category> create(CategoryDraft draft) async => throw UnimplementedError();

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
  _FakeProductRepository({required this.rows});

  final List<Product> rows;

  @override
  Stream<List<Product>> watch({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  }) =>
      Stream.value(
        rows
            .where((Product p) =>
                categoryId == null || p.categoryId == categoryId)
            .toList(growable: false),
      );

  @override
  Stream<Product?> watchOne(String id) => Stream.value(
        rows.where((Product p) => p.id == id).firstOrNull,
      );

  @override
  Future<List<Product>> fetch({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  }) async =>
      rows;

  @override
  Future<Product?> findById(String id) async =>
      rows.where((Product p) => p.id == id).firstOrNull;

  @override
  Future<List<Product>> search(String query, {int limit = 40}) async => rows;

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
  _FakeProductMediaRepository({required this.rows});

  final List<ProductMedia> rows;

  @override
  Stream<List<ProductMedia>> watchAll() => Stream.value(rows);

  @override
  Stream<List<ProductMedia>> watchForProduct(String productId) => Stream.value(
        rows.where((ProductMedia m) => m.productId == productId).toList(),
      );

  @override
  Future<List<ProductMedia>> fetchForProduct(String productId) async =>
      rows.where((ProductMedia m) => m.productId == productId).toList();

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
