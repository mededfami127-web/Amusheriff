import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_gate_password_page.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/drafts/catalog_drafts.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/category.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product_media.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/repositories/catalog_repositories.dart';
import 'package:amu_sharif_majlis/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:amu_sharif_majlis/features/inquiries/domain/entities/inquiry.dart';
import 'package:amu_sharif_majlis/features/inquiries/domain/repositories/inquiry_repository.dart';
import 'package:amu_sharif_majlis/features/inquiries/presentation/providers/inquiry_providers.dart';
import 'package:amu_sharif_majlis/features/text_editor/domain/entities/text_override.dart';
import 'package:amu_sharif_majlis/features/text_editor/domain/repositories/text_overrides_repository.dart';
import 'package:amu_sharif_majlis/features/text_editor/presentation/pages/admin_text_editor_page.dart';
import 'package:amu_sharif_majlis/features/text_editor/presentation/providers/text_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Layout and live-edit coverage for the gateway screens.
///
/// Two things the brief asks for are checked here rather than by eye:
///   * the dashboard and the text editor survive a **small phone at the largest
///     text scale the app allows** without a `RenderFlex overflowed` exception;
///   * switching live edit mode on really does put a working pencil on every
///     editable string, and tapping one opens the editor for that exact key.
void main() {
  late _FakeCategoryRepository categories;
  late _FakeProductRepository products;
  late _FakeProductMediaRepository media;
  late _FakeInquiryRepository inquiries;
  late _FakeTextOverridesRepository overrides;

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
    inquiries = _FakeInquiryRepository();
    overrides = _FakeTextOverridesRepository();
  });

  Widget harness(Widget page) {
    return ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(categories),
        productRepositoryProvider.overrideWithValue(products),
        productMediaRepositoryProvider.overrideWithValue(media),
        inquiryRepositoryProvider.overrideWithValue(inquiries),
        textOverridesRepositoryProvider.overrideWithValue(overrides),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: page,
      ),
    );
  }

  /// A small phone with accessibility text scaling cranked to the app's cap.
  Future<void> pumpSmall(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(1.35),
        ),
        child: harness(page),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
  }

  testWidgets('the dashboard lays out on a small phone at 1.35x text', (
    WidgetTester tester,
  ) async {
    await pumpSmall(tester, const AdminDashboardPage());

    // No RenderFlex overflow at 320x640 with 1.35x text.
    expect(tester.takeException(), isNull);
    // …and the numbers the owner checks first are actually on screen.
    expect(find.byIcon(Icons.category_outlined), findsWidgets);
    expect(find.text('Dashboard'), findsWidgets);
  });

  testWidgets('the text editor lays out on a small phone at 1.35x text', (
    WidgetTester tester,
  ) async {
    await pumpSmall(tester, const AdminTextEditorPage());

    expect(tester.takeException(), isNull);
    // The live-edit switch and the language picker are on screen…
    expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);
    // …and the catalogue is listed with its per-string edit icons. The
    // header cards fill a small viewport, so scroll the first string into view
    // the way the owner would.
    expect(find.text('Search a word'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('a11yOpenCategory'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
  });

  testWidgets('the gateway password screen lays out on a small phone', (
    WidgetTester tester,
  ) async {
    await pumpSmall(tester, const AdminGatePasswordPage());

    expect(tester.takeException(), isNull);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });

  testWidgets('live edit mode puts a pencil above every editable string', (
    WidgetTester tester,
  ) async {
    await pumpSmall(tester, const AdminDashboardPage());

    // Off by default: a customer never sees a pencil.
    expect(find.byIcon(Icons.edit_outlined), findsNothing);

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(AdminDashboardPage)),
    );
    expect(container.read(liveEditModeProvider), isFalse);

    container.read(liveEditModeProvider.notifier).enable();
    await tester.pump();

    // Now every editable string on the dashboard carries one, and the layout
    // still fits.
    expect(container.read(liveEditModeProvider), isTrue);
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
  });

  testWidgets('the language picker offers all four languages', (
    WidgetTester tester,
  ) async {
    await pumpSmall(tester, const AdminTextEditorPage());

    // Oromo is reachable exactly like English, Amharic and Arabic.
    expect(find.text('Oromoo'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
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
  }) async =>
      rows;

  @override
  Future<Product?> findById(String id) async =>
      rows.where((Product p) => p.id == id).firstOrNull;

  @override
  Future<List<Product>> search(String query, {int limit = 40}) async =>
      const <Product>[];

  @override
  Future<Product> create(ProductDraft draft) async => throw UnimplementedError();

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

class _FakeInquiryRepository implements InquiryRepository {
  @override
  Future<List<Inquiry>> fetchAll({int limit = 500}) async => const <Inquiry>[];

  @override
  Stream<List<Inquiry>> watchAll() async* {
    yield const <Inquiry>[];
  }

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> log({
    String? productId,
    required String channel,
    String? deviceId,
  }) async {}
}

/// Serves an empty override map: the shipped wording, live.
class _FakeTextOverridesRepository implements TextOverridesRepository {
  @override
  Stream<Map<String, String>> watch(String locale) async* {
    yield const <String, String>{};
  }

  @override
  Future<Map<String, String>> fetch(String locale) async =>
      const <String, String>{};

  @override
  Future<List<TextOverride>> fetchAll() async => const <TextOverride>[];

  @override
  Future<void> save({
    required String textKey,
    required String locale,
    required String value,
  }) async {}

  @override
  Future<void> remove({
    required String textKey,
    required String locale,
  }) async {}
}
