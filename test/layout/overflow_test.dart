import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_categories_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_change_password_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_contacts_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_gate_password_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_inquiries_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_login_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_product_editor_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_products_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_site_settings_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_system_check_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/controllers/admin_editors.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_category_editor_sheet.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/widgets/admin_gate_sheet.dart';
import 'package:amu_sharif_majlis/features/settings/presentation/pages/about_page.dart';
import 'package:amu_sharif_majlis/features/settings/presentation/pages/settings_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/category_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/favourites_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/not_found_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/product_detail_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/search_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/storefront_home_page.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/providers/storefront_providers.dart';
import 'package:amu_sharif_majlis/features/text_editor/presentation/pages/admin_text_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'overflow_harness.dart';

/// Every screen, at every viewport, text scale, locale and keyboard state the
/// brief names.
///
/// A `RenderFlex overflowed` is not thrown into the test's zone: Flutter reports
/// it through `FlutterError.onError`, so the harness captures that hook and
/// fails the case with the screen, the widget and its `file:line`.
void main() {
  setUpAll(loadAppFonts);

  final List<_ScreenCase> cases = <_ScreenCase>[
    _ScreenCase('home', (FakeBackend b) => const StorefrontHomePage()),
    _ScreenCase(
      'home (empty)',
      (FakeBackend b) => const StorefrontHomePage(),
      backend: () => FakeBackend(
        categoriesMode: SourceMode.empty,
        productsMode: SourceMode.empty,
        mediaMode: SourceMode.empty,
        contactsMode: SourceMode.empty,
      ),
    ),
    _ScreenCase(
      'home (error)',
      (FakeBackend b) => const StorefrontHomePage(),
      backend: () => FakeBackend(
        categoriesMode: SourceMode.error,
        productsMode: SourceMode.error,
        mediaMode: SourceMode.error,
        contactsMode: SourceMode.error,
      ),
    ),
    _ScreenCase(
      'home (loading)',
      (FakeBackend b) => const StorefrontHomePage(),
      backend: () => FakeBackend(
        categoriesMode: SourceMode.loading,
        productsMode: SourceMode.loading,
        mediaMode: SourceMode.loading,
        contactsMode: SourceMode.loading,
      ),
    ),
    _ScreenCase(
      'category',
      (FakeBackend b) => const CategoryPage(slug: 'majlis'),
    ),
    _ScreenCase(
      'category (empty)',
      (FakeBackend b) => const CategoryPage(slug: 'majlis'),
      backend: () => FakeBackend(
        productsMode: SourceMode.empty,
        mediaMode: SourceMode.empty,
      ),
    ),
    _ScreenCase(
      'category (error)',
      (FakeBackend b) => const CategoryPage(slug: 'majlis'),
      backend: () => FakeBackend(
        categoriesMode: SourceMode.error,
        productsMode: SourceMode.error,
        mediaMode: SourceMode.error,
      ),
    ),
    _ScreenCase(
      'category (loading)',
      (FakeBackend b) => const CategoryPage(slug: 'majlis'),
      backend: () => FakeBackend(
        categoriesMode: SourceMode.loading,
        productsMode: SourceMode.loading,
        mediaMode: SourceMode.loading,
      ),
    ),
    _ScreenCase(
      'category (missing)',
      (FakeBackend b) => const CategoryPage(slug: 'nope'),
    ),
    _ScreenCase(
      'product',
      (FakeBackend b) => const ProductDetailPage(productId: 'p1'),
    ),
    _ScreenCase(
      'product (missing)',
      (FakeBackend b) => const ProductDetailPage(productId: 'nope'),
    ),
    _ScreenCase(
      'product (error)',
      (FakeBackend b) => const ProductDetailPage(productId: 'p1'),
      backend: () => FakeBackend(
        productsMode: SourceMode.error,
        mediaMode: SourceMode.error,
      ),
    ),
    _ScreenCase(
      'product (loading)',
      (FakeBackend b) => const ProductDetailPage(productId: 'p1'),
      backend: () => FakeBackend(
        productsMode: SourceMode.loading,
        mediaMode: SourceMode.loading,
      ),
    ),
    _ScreenCase('search (empty)', (FakeBackend b) => const SearchPage()),
    _ScreenCase(
      'search (results)',
      (FakeBackend b) => const SearchPage(),
      seedSearch: true,
    ),
    _ScreenCase(
      'favourites (empty)',
      (FakeBackend b) => const FavouritesPage(),
    ),
    _ScreenCase(
      'favourites',
      (FakeBackend b) => const FavouritesPage(),
      backend: () => FakeBackend(withFavourites: true),
    ),
    _ScreenCase('settings', (FakeBackend b) => const SettingsPage()),
    _ScreenCase('about', (FakeBackend b) => const AboutPage()),
    _ScreenCase('not found', (FakeBackend b) => const NotFoundPage()),
    _ScreenCase(
      'admin dashboard',
      (FakeBackend b) => const AdminDashboardPage(),
    ),
    _ScreenCase(
      'admin dashboard (empty)',
      (FakeBackend b) => const AdminDashboardPage(),
      backend: () => FakeBackend(
        categoriesMode: SourceMode.empty,
        productsMode: SourceMode.empty,
        mediaMode: SourceMode.empty,
        inquiriesMode: SourceMode.empty,
      ),
    ),
    _ScreenCase(
      'admin dashboard (error)',
      (FakeBackend b) => const AdminDashboardPage(),
      backend: () => FakeBackend(
        categoriesMode: SourceMode.error,
        productsMode: SourceMode.error,
        mediaMode: SourceMode.error,
        inquiriesMode: SourceMode.error,
      ),
    ),
    _ScreenCase(
      'admin categories',
      (FakeBackend b) => const AdminCategoriesPage(),
    ),
    _ScreenCase(
      'admin categories (empty)',
      (FakeBackend b) => const AdminCategoriesPage(),
      backend: () => FakeBackend(categoriesMode: SourceMode.empty),
    ),
    _ScreenCase(
      'admin categories (error)',
      (FakeBackend b) => const AdminCategoriesPage(),
      backend: () => FakeBackend(categoriesMode: SourceMode.error),
    ),
    _ScreenCase(
      'admin categories (loading)',
      (FakeBackend b) => const AdminCategoriesPage(),
      backend: () => FakeBackend(categoriesMode: SourceMode.loading),
    ),
    _ScreenCase('admin products', (FakeBackend b) => const AdminProductsPage()),
    _ScreenCase(
      'admin products (empty)',
      (FakeBackend b) => const AdminProductsPage(),
      backend: () => FakeBackend(
        productsMode: SourceMode.empty,
        mediaMode: SourceMode.empty,
      ),
    ),
    _ScreenCase(
      'admin products (error)',
      (FakeBackend b) => const AdminProductsPage(),
      backend: () => FakeBackend(
        productsMode: SourceMode.error,
        mediaMode: SourceMode.error,
      ),
    ),
    _ScreenCase(
      'product form',
      (FakeBackend b) => const AdminProductEditorPage(),
    ),
    _ScreenCase(
      'product form (edit)',
      (FakeBackend b) => const AdminProductEditorPage(productId: 'p1'),
    ),
    _ScreenCase('category form', (FakeBackend b) => const _CategorySheetHost()),
    _ScreenCase(
      'owner gateway sheet',
      (FakeBackend b) => const _GateSheetHost(),
    ),
    _ScreenCase('admin login', (FakeBackend b) => const AdminLoginPage()),
    _ScreenCase(
      'gateway password',
      (FakeBackend b) => const AdminGatePasswordPage(),
    ),
    _ScreenCase(
      'change password',
      (FakeBackend b) => const AdminChangePasswordPage(),
    ),
    _ScreenCase('admin contacts', (FakeBackend b) => const AdminContactsPage()),
    _ScreenCase(
      'admin contacts (empty)',
      (FakeBackend b) => const AdminContactsPage(),
      backend: () => FakeBackend(contactsMode: SourceMode.empty),
    ),
    _ScreenCase(
      'admin contacts (error)',
      (FakeBackend b) => const AdminContactsPage(),
      backend: () => FakeBackend(contactsMode: SourceMode.error),
    ),
    _ScreenCase(
      'admin site settings',
      (FakeBackend b) => const AdminSiteSettingsPage(),
    ),
    _ScreenCase(
      'admin inquiries',
      (FakeBackend b) => const AdminInquiriesPage(),
    ),
    _ScreenCase(
      'admin inquiries (empty)',
      (FakeBackend b) => const AdminInquiriesPage(),
      backend: () => FakeBackend(inquiriesMode: SourceMode.empty),
    ),
    _ScreenCase(
      'admin inquiries (error)',
      (FakeBackend b) => const AdminInquiriesPage(),
      backend: () => FakeBackend(inquiriesMode: SourceMode.error),
    ),
    _ScreenCase(
      'admin system check',
      (FakeBackend b) => const AdminSystemCheckPage(),
    ),
    _ScreenCase(
      'admin text editor',
      (FakeBackend b) => const AdminTextEditorPage(),
    ),
  ];

  for (final _ScreenCase screen in cases) {
    testWidgets('${screen.name} lays out without overflow', (
      WidgetTester tester,
    ) async {
      final List<String> failures = <String>[];

      for (final LayoutConfig config in layoutConfigs()) {
        final FakeBackend backend = screen.backend?.call() ?? FakeBackend();
        final List<String> overflows = await pumpPage(
          tester,
          page: screen.build(backend),
          config: config,
          backend: backend,
          afterPump: screen.seedSearch
              ? (WidgetTester tester) async {
                  final ProviderContainer container = ProviderScope.containerOf(
                    tester.element(find.byType(SearchPage)),
                  );
                  container.read(searchQueryProvider.notifier).update('sofa');
                  await tester.pump();
                  // The search box debounces for 350 ms before it queries.
                  await tester.pump(const Duration(milliseconds: 400));
                  await tester.pump(const Duration(milliseconds: 50));
                }
              : null,
        );
        for (final String overflow in overflows) {
          failures.add('${screen.name} | ${config.label} | $overflow');
        }
      }

      expect(
        failures,
        isEmpty,
        reason:
            '\n${failures.length} overflow(s) across the layout matrix:\n'
            '${failures.join('\n')}',
      );
    }, timeout: const Timeout(Duration(minutes: 10)));
  }
}

class _ScreenCase {
  const _ScreenCase(
    this.name,
    this.build, {
    this.backend,
    this.seedSearch = false,
  });

  final String name;
  final Widget Function(FakeBackend backend) build;
  final FakeBackend Function()? backend;
  final bool seedSearch;
}

/// Opens the owner panel exactly as the app does: through
/// `showAdminGateSheet`, one frame after the host mounts.
class _GateSheetHost extends StatefulWidget {
  const _GateSheetHost();

  @override
  State<_GateSheetHost> createState() => _GateSheetHostState();
}

class _GateSheetHostState extends State<_GateSheetHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showAdminGateSheet(context);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.expand());
}

/// Opens the category form as a modal sheet, seeded the way the list page does.
class _CategorySheetHost extends ConsumerStatefulWidget {
  const _CategorySheetHost();

  @override
  ConsumerState<_CategorySheetHost> createState() => _CategorySheetHostState();
}

class _CategorySheetHostState extends ConsumerState<_CategorySheetHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // The real list page seeds the draft before opening the sheet.
      ref
          .read(categoryEditorControllerProvider.notifier)
          .load(null, parentId: 'c1');
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const CategoryEditorSheet(),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.expand());
}
