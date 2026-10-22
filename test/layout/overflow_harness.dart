import 'dart:async';

import 'package:amu_sharif_majlis/core/errors/app_failure.dart';
import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/network/storage_urls.dart';
import 'package:amu_sharif_majlis/core/network/supabase_client_provider.dart';
import 'package:amu_sharif_majlis/core/l10n/text_localizations.dart';
import 'package:amu_sharif_majlis/core/theme/app_theme.dart';
import 'package:amu_sharif_majlis/features/admin/data/system_check_runner.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/providers/system_check_providers.dart';
import 'package:amu_sharif_majlis/features/auth/domain/repositories/auth_repository.dart';
import 'package:amu_sharif_majlis/features/auth/presentation/providers/auth_providers.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/drafts/catalog_drafts.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/category.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product_media.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/repositories/catalog_repositories.dart';
import 'package:amu_sharif_majlis/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:amu_sharif_majlis/features/contacts/domain/drafts/contact_link_draft.dart';
import 'package:amu_sharif_majlis/features/contacts/domain/entities/contact_kind.dart';
import 'package:amu_sharif_majlis/features/contacts/domain/entities/contact_link.dart';
import 'package:amu_sharif_majlis/features/contacts/domain/entities/contact_settings.dart';
import 'package:amu_sharif_majlis/features/contacts/domain/repositories/contact_repository.dart';
import 'package:amu_sharif_majlis/features/contacts/domain/repositories/contact_settings_repository.dart';
import 'package:amu_sharif_majlis/features/contacts/presentation/providers/contact_providers.dart';
import 'package:amu_sharif_majlis/features/contacts/presentation/providers/contact_settings_providers.dart';
import 'package:amu_sharif_majlis/features/inquiries/domain/entities/inquiry.dart';
import 'package:amu_sharif_majlis/features/inquiries/domain/repositories/inquiry_repository.dart';
import 'package:amu_sharif_majlis/features/inquiries/presentation/providers/inquiry_providers.dart';
import 'package:amu_sharif_majlis/features/settings/domain/drafts/site_settings_draft.dart';
import 'package:amu_sharif_majlis/features/settings/domain/entities/site_settings.dart';
import 'package:amu_sharif_majlis/features/settings/domain/repositories/site_content_repository.dart';
import 'package:amu_sharif_majlis/features/settings/domain/repositories/site_settings_repository.dart';
import 'package:amu_sharif_majlis/features/settings/presentation/providers/site_content_providers.dart';
import 'package:amu_sharif_majlis/features/settings/presentation/providers/site_settings_providers.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/providers/favourites_providers.dart';
import 'package:amu_sharif_majlis/features/text_editor/domain/entities/text_override.dart';
import 'package:amu_sharif_majlis/features/text_editor/domain/repositories/text_overrides_repository.dart';
import 'package:amu_sharif_majlis/features/text_editor/presentation/providers/text_editor_providers.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// How a fake source answers: one value, an empty list, a failure, or nothing.
enum SourceMode { data, empty, error, loading }

/// A phone/tablet viewport plus the accessibility settings the layout must
/// survive.
@immutable
class LayoutConfig {
  const LayoutConfig({
    required this.size,
    required this.textScale,
    required this.locale,
    required this.keyboard,
  });

  final Size size;
  final double textScale;
  final String locale;
  final bool keyboard;

  EdgeInsets get viewInsets => EdgeInsets.only(bottom: keyboard ? 300 : 0);

  String get label =>
      '${size.width.toInt()}x${size.height.toInt()} @${textScale}x '
      '$locale${keyboard ? ' +keyboard' : ''}';
}

const List<Size> kLayoutSizes = <Size>[
  Size(320, 568),
  Size(360, 640),
  Size(411, 891),
  Size(800, 1280),
];

const List<double> kTextScales = <double>[1.0, 1.3, 2.0];

const List<String> kLocales = <String>['en', 'am', 'ar', 'om'];

/// A representative slice of the 4 × 3 × 4 × 2 cross-product.
///
/// The full 96-config product cannot run in one process on a 2 GB machine:
/// the test isolate is OOM-killed part-way through the matrix, because each
/// pump keeps text-layout and image state alive for the life of the isolate.
/// This walk still touches every viewport, every text scale, every locale and
/// both keyboard states: locales rotate round-robin, and the keyboard is open
/// on every other size/scale pair (12 layouts per screen instead of 96).
List<LayoutConfig> layoutConfigs() => <LayoutConfig>[
  for (final (int sizeIndex, Size size) in kLayoutSizes.indexed)
    for (final (int scaleIndex, double scale) in kTextScales.indexed)
      LayoutConfig(
        size: size,
        textScale: scale,
        locale:
            kLocales[(sizeIndex * kTextScales.length + scaleIndex) %
                kLocales.length],
        keyboard: (sizeIndex + scaleIndex).isEven,
      ),
];

/// Everything a screen needs, with no network and no platform channels.
class FakeBackend {
  FakeBackend({
    this.categoriesMode = SourceMode.data,
    this.productsMode = SourceMode.data,
    this.mediaMode = SourceMode.data,
    this.contactsMode = SourceMode.data,
    this.inquiriesMode = SourceMode.data,
    this.settingsMode = SourceMode.data,
    this.withFavourites = false,
    this.categoryRows,
    this.productRows,
    this.siteSettingsValue,
  });

  final SourceMode categoriesMode;
  final SourceMode productsMode;
  final List<Category>? categoryRows;
  final List<Product>? productRows;
  final SourceMode mediaMode;
  final SourceMode contactsMode;
  final SourceMode inquiriesMode;
  final SourceMode settingsMode;

  /// Seeds the device favourites list with the sample products.
  final bool withFavourites;

  /// Branding the widgets under test should see. Defaults to
  /// [SiteSettings.fallback]; a test that needs a stored legacy or custom shop
  /// name passes its own value instead of overriding the provider twice.
  final SiteSettings? siteSettingsValue;

  late final FakeCategoryRepository categories = FakeCategoryRepository(
    mode: categoriesMode,
    rows: categoryRows ?? _categories,
  );
  late final FakeProductRepository products = FakeProductRepository(
    mode: productsMode,
    rows: productRows ?? kSampleProducts,
  );
  late final FakeProductMediaRepository media = FakeProductMediaRepository(
    mode: mediaMode,
    rows: _media,
  );
  late final FakeContactRepository contacts = FakeContactRepository(
    mode: contactsMode,
    rows: _contacts,
  );
  final FakeContactSettingsRepository contactSettings =
      FakeContactSettingsRepository();
  late final FakeInquiryRepository inquiries = FakeInquiryRepository(
    mode: inquiriesMode,
    rows: _inquiries,
  );
  late final FakeSiteSettingsRepository settings = FakeSiteSettingsRepository(
    mode: settingsMode,
  );
  final FakeSiteContentRepository siteContent = FakeSiteContentRepository();
  final FakeAuthRepository auth = FakeAuthRepository();
  final FakeTextOverridesRepository overrides = FakeTextOverridesRepository();

  /// A client that is only ever asked to build public URLs — no request is
  /// made, so the tests stay offline while the cards render real image URLs.
  static final StorageUrls storageUrls = StorageUrls(
    SupabaseClient(
      'https://harness.supabase.co',
      'harness-anon-key',
      // The URL builder needs no session, and the refresh timer would outlive
      // the test and trip the pending-timer assertion.
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    ),
  );

  List<Object> get overridesList => <Object>[
    storageUrlsProvider.overrideWithValue(storageUrls),
    categoryRepositoryProvider.overrideWithValue(categories),
    productRepositoryProvider.overrideWithValue(products),
    productMediaRepositoryProvider.overrideWithValue(media),
    contactRepositoryProvider.overrideWithValue(contacts),
    contactSettingsRepositoryProvider.overrideWithValue(contactSettings),
    inquiryRepositoryProvider.overrideWithValue(inquiries),
    siteSettingsRepositoryProvider.overrideWithValue(settings),
    siteContentRepositoryProvider.overrideWithValue(siteContent),
    siteSettingsValueProvider.overrideWithValue(
      siteSettingsValue ?? SiteSettings.fallback,
    ),
    authRepositoryProvider.overrideWithValue(auth),
    textOverridesRepositoryProvider.overrideWithValue(overrides),
    currentSessionProvider.overrideWithValue(null),
    currentUserProvider.overrideWithValue(null),
    systemChecksProvider.overrideWith(
      (Ref ref) =>
          Future<List<SystemAssetCheck>>.value(const <SystemAssetCheck>[]),
    ),
    if (withFavourites)
      favouriteProductsProvider.overrideWithValue(kSampleProducts),
  ];
}

const List<Category> _categories = <Category>[
  Category(id: 'c1', name: 'Majlis', slug: 'majlis', productCount: 2),
  Category(
    id: 'c2',
    name: 'Corner Units',
    slug: 'corner-units',
    parentId: 'c1',
    productCount: 1,
  ),
];

/// Two products, long enough to exercise wrapping and price rows.
const List<Product> kSampleProducts = <Product>[
  Product(
    id: 'p1',
    categoryId: 'c1',
    title: 'Damascus Majlis Sofa with Hand-Carved Details',
    description:
        'A long description that wraps over several lines on any phone, '
        'including a small one with the largest accessibility text size.',
    price: 18500,
    compareAtPrice: 22000,
    isFeatured: true,
  ),
  Product(
    id: 'p2',
    categoryId: 'c1',
    title: 'Amhara Corner Sofa',
    price: 24000,
  ),
];

const List<ProductMedia> _media = <ProductMedia>[];

const List<ContactLink> _contacts = <ContactLink>[
  ContactLink(
    id: 'l1',
    kind: ContactKind.whatsapp,
    label: 'WhatsApp',
    value: '+251911223344',
    isPrimary: true,
  ),
  ContactLink(
    id: 'l2',
    kind: ContactKind.phone,
    label: 'Call the showroom',
    value: '+251911556677',
  ),
];

const List<Inquiry> _inquiries = <Inquiry>[
  Inquiry(id: 'i1', channel: 'whatsapp', productTitle: 'Damascus Majlis Sofa'),
];

Stream<T> _answer<T>(SourceMode mode, T value) => switch (mode) {
  SourceMode.data || SourceMode.empty => Stream<T>.value(value),
  SourceMode.error => Stream<T>.error(const NetworkFailure()),
  SourceMode.loading => Stream<T>.fromFuture(Completer<T>().future),
};

Future<T> _answerFuture<T>(SourceMode mode, T value) async => switch (mode) {
  SourceMode.data || SourceMode.empty => value,
  SourceMode.error => throw const NetworkFailure(),
  SourceMode.loading => Completer<T>().future,
};

class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository({required this.mode, required this.rows});

  final SourceMode mode;
  final List<Category> rows;

  List<Category> get _rows =>
      mode == SourceMode.empty ? const <Category>[] : rows;

  @override
  Stream<List<Category>> watchAll() => _answer<List<Category>>(mode, _rows);

  @override
  Stream<List<Category>> watchVisible() => _answer<List<Category>>(mode, _rows);

  @override
  Future<List<Category>> fetchVisible() =>
      _answerFuture<List<Category>>(mode, _rows);

  @override
  Future<Category?> findById(String id) => _answerFuture<Category?>(
    mode,
    _rows.where((Category c) => c.id == id).firstOrNull,
  );

  @override
  Future<Category?> findBySlug(String slug) => _answerFuture<Category?>(
    mode,
    _rows.where((Category c) => c.slug == slug).firstOrNull,
  );

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

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({required this.mode, required this.rows});

  final SourceMode mode;
  final List<Product> rows;

  List<Product> get _rows =>
      mode == SourceMode.empty ? const <Product>[] : rows;

  @override
  Stream<List<Product>> watch({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  }) => _answer<List<Product>>(
    mode,
    _rows
        .where((Product p) => categoryId == null || p.categoryId == categoryId)
        .where((Product p) => !onlyFeatured || p.isFeatured)
        .toList(growable: false),
  );

  @override
  Stream<Product?> watchOne(String id) => _answer<Product?>(
    mode,
    _rows.where((Product p) => p.id == id).firstOrNull,
  );

  @override
  Future<List<Product>> fetch({
    String? categoryId,
    bool onlyPublished = true,
    bool onlyFeatured = false,
  }) => _answerFuture<List<Product>>(mode, _rows);

  @override
  Future<Product?> findById(String id) => _answerFuture<Product?>(
    mode,
    _rows.where((Product p) => p.id == id).firstOrNull,
  );

  @override
  Future<List<Product>> search(String query, {int limit = 40}) =>
      _answerFuture<List<Product>>(mode, _rows);

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

class FakeProductMediaRepository implements ProductMediaRepository {
  FakeProductMediaRepository({required this.mode, required this.rows});

  final SourceMode mode;
  final List<ProductMedia> rows;

  List<ProductMedia> get _rows =>
      mode == SourceMode.empty ? const <ProductMedia>[] : rows;

  @override
  Stream<List<ProductMedia>> watchAll() =>
      _answer<List<ProductMedia>>(mode, _rows);

  @override
  Stream<List<ProductMedia>> watchForProduct(String productId) =>
      _answer<List<ProductMedia>>(
        mode,
        _rows.where((ProductMedia m) => m.productId == productId).toList(),
      );

  @override
  Future<List<ProductMedia>> fetchForProduct(String productId) =>
      _answerFuture<List<ProductMedia>>(mode, _rows);

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

class FakeContactRepository implements ContactRepository {
  FakeContactRepository({required this.mode, required this.rows});

  final SourceMode mode;
  final List<ContactLink> rows;

  List<ContactLink> get _rows =>
      mode == SourceMode.empty ? const <ContactLink>[] : rows;

  @override
  Stream<List<ContactLink>> watchVisible() =>
      _answer<List<ContactLink>>(mode, _rows);

  @override
  Stream<List<ContactLink>> watchAll() =>
      _answer<List<ContactLink>>(mode, _rows);

  @override
  Future<List<ContactLink>> fetchVisible() =>
      _answerFuture<List<ContactLink>>(mode, _rows);

  @override
  Future<ContactLink?> findById(String id) => _answerFuture<ContactLink?>(
    mode,
    _rows.where((ContactLink l) => l.id == id).firstOrNull,
  );

  @override
  Future<ContactLink> create(ContactLinkDraft draft) async =>
      throw UnimplementedError();

  @override
  Future<ContactLink> update(String id, ContactLinkDraft draft) async =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> setVisibility(String id, {required bool isVisible}) async {}

  @override
  Future<void> setPrimary(String id, {required bool isPrimary}) async {}

  @override
  Future<void> reorder(List<String> orderedIds) async {}
}

class FakeContactSettingsRepository implements ContactSettingsRepository {
  static const ContactSettings settings = ContactSettings(
    ownerPhone: '+251911223344',
    ownerEmail: 'owner@asm.et',
    whatsappNumber: '251911223344',
    telegramHandle: 'amumejlisamusharif',
    instagramHandle: 'amusheriff',
  );

  @override
  Stream<ContactSettings> watch() => Stream<ContactSettings>.value(settings);

  @override
  Future<ContactSettings> fetch() async => settings;

  @override
  Future<void> save(ContactSettings settings) async {}
}

class FakeInquiryRepository implements InquiryRepository {
  FakeInquiryRepository({required this.mode, required this.rows});

  final SourceMode mode;
  final List<Inquiry> rows;

  List<Inquiry> get _rows =>
      mode == SourceMode.empty ? const <Inquiry>[] : rows;

  @override
  Future<List<Inquiry>> fetchAll({int limit = 500}) =>
      _answerFuture<List<Inquiry>>(mode, _rows);

  @override
  Stream<List<Inquiry>> watchAll() => _answer<List<Inquiry>>(mode, _rows);

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> log({
    String? productId,
    required String channel,
    String? deviceId,
  }) async {}
}

class FakeSiteSettingsRepository implements SiteSettingsRepository {
  FakeSiteSettingsRepository({required this.mode});

  final SourceMode mode;

  @override
  Stream<SiteSettings> watch() =>
      _answer<SiteSettings>(mode, SiteSettings.fallback);

  @override
  Future<SiteSettings?> fetch() =>
      _answerFuture<SiteSettings?>(mode, SiteSettings.fallback);

  @override
  Future<SiteSettings> save(SiteSettingsDraft draft) async =>
      SiteSettings.fallback;
}

class FakeSiteContentRepository implements SiteContentRepository {
  @override
  Stream<Map<String, String>> watch(String locale) =>
      Stream<Map<String, String>>.value(const <String, String>{});

  @override
  Future<Map<String, String>> fetch(String locale) async =>
      const <String, String>{};

  @override
  Future<Map<String, String>> fetchAll() async => const <String, String>{};

  @override
  Future<void> save({
    required String key,
    required String locale,
    required String value,
  }) async {}

  @override
  Future<void> remove({required String key, required String locale}) async {}
}

class FakeTextOverridesRepository implements TextOverridesRepository {
  @override
  Stream<Map<String, String>> watch(String locale) =>
      Stream<Map<String, String>>.value(const <String, String>{});

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

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<AuthState> get authStateChanges => const Stream<AuthState>.empty();

  @override
  Session? get currentSession => null;

  @override
  User? get currentUser => null;

  @override
  bool get isSignedIn => false;

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  Future<bool> verifyPassword({
    required String email,
    required String password,
  }) async => false;

  @override
  Future<bool> isAdmin() async => false;
}

/// Pumps [page] at [config] and returns every exception Flutter reported.
///
/// Overflows are *not* rethrown by the framework in a test; they are reported
/// through `FlutterError.onError`, so that hook is where the suite listens.
Future<List<String>> pumpPage(
  WidgetTester tester, {
  required Widget page,
  required LayoutConfig config,
  required FakeBackend backend,
  Future<void> Function(WidgetTester tester)? afterPump,
}) async {
  // Unmount the previous configuration first. Resizing a live tree to the next
  // viewport (or text scale) would report overflows from a widget that is one
  // frame from being disposed, which says nothing about the screen under test.
  await tester.pumpWidget(const SizedBox.shrink());
  // A 46-screen × 96-config matrix keeps every decoded image alive for the
  // life of the isolate otherwise; the harness runs one process for all of it.
  imageCache.clear();
  imageCache.clearLiveImages();

  final List<String> overflows = <String>[];
  final FlutterExceptionHandler? previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('overflowed')) {
      // Read the creator *now*: by the time the pump ends the element may be
      // defunct, and the widget/location information is gone.
      overflows.add(describeOverflow(details));
    }
  };

  tester.view.physicalSize = config.size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      // Riverpod 3 retries a failed provider with a timer. A layout pump has no
      // clock to run it, and the pending timer fails the test after the tree is
      // disposed; the error screens are exactly what is under test here.
      retry: (int retryCount, Object error) => null,
      overrides: backend.overridesList.cast(),
      child: MaterialApp(
        locale: Locale(config.locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: appLocalizationsDelegates(
          overrides: const <String, String>{},
        ),
        theme: AppTheme.light(),
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(config.textScale),
            viewInsets: config.viewInsets,
            size: config.size,
          ),
          child: child ?? const SizedBox.shrink(),
        ),
        home: page,
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  if (afterPump != null) await afterPump(tester);

  FlutterError.onError = previous;

  // Dispose the tree between configurations. `flutter_animate` schedules a
  // zero-duration timer per animated widget; leaving the tree mounted would
  // carry those timers into the next config and trip the test binding's
  // "A Timer is still pending" invariant on whichever config runs last.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  return overflows;
}

/// `file:line` of the widget that owns the overflowing RenderFlex.
///
/// The location lives in the diagnostic information Flutter attaches to the
/// error, not in `exception.toString()` alone.
String creationLocation(FlutterErrorDetails details) {
  final String text = <String>[
    details.toString(),
    details.context?.toString() ?? '',
    ...?details.informationCollector?.call().map(
      (DiagnosticsNode node) => node.toString(),
    ),
  ].join('\n');
  final RegExpMatch? match = RegExp(r'(file://[^\s:]+\.dart:\d+(?::\d+)?)')
      .firstMatch(text);
  if (match != null) return match.group(1)!;

  // The element chain still names the widget type even when the source
  // location was not attached (e.g. a framework-owned flex).
  final RegExpMatch? creator = RegExp(r'debugCreator: ([A-Za-z0-9_]+)')
      .firstMatch(text);
  return creator == null
      ? 'unknown location'
      : '${creator.group(1)} (no location)';
}

/// Loads the app's real faces so the measurements are glyph widths, not the
/// square Ahem test font (which overstates every string).
Future<void> loadAppFonts() async {
  const Map<String, List<String>> families = <String, List<String>>{
    'Poppins': <String>[
      'assets/fonts/Poppins-Regular.ttf',
      'assets/fonts/Poppins-Medium.ttf',
      'assets/fonts/Poppins-SemiBold.ttf',
      'assets/fonts/Poppins-Bold.ttf',
    ],
    'PlayfairDisplay': <String>['assets/fonts/PlayfairDisplay-Variable.ttf'],
    'Cairo': <String>['assets/fonts/Cairo-Variable.ttf'],
    'NotoNaskhArabic': <String>['assets/fonts/NotoNaskhArabic-Variable.ttf'],
    'NotoSansEthiopic': <String>['assets/fonts/NotoSansEthiopic-Variable.ttf'],
  };

  for (final MapEntry<String, List<String>> family in families.entries) {
    final FontLoader loader = FontLoader(family.key);
    for (final String asset in family.value) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}

/// One readable line per overflow, used to build the before/after table.
String describeOverflow(FlutterErrorDetails details) {
  final String exception = details.exceptionAsString();
  final RegExpMatch? pixels = RegExp(r'overflowed by ([\d.]+) pixels')
      .firstMatch(exception);
  final RegExpMatch? axis = RegExp(
    r'overflowed by [\d.]+ pixels on the ([a-z]+)',
  ).firstMatch(exception);
  return '${axis?.group(1) ?? '?'} ${pixels?.group(1) ?? '?'}px | '
      '${creationLocation(details)}';
}
