import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/admin/presentation/pages/admin_categories_page.dart';
import '../../features/admin/presentation/pages/admin_change_password_page.dart';
import '../../features/admin/presentation/pages/admin_contacts_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_gate_password_page.dart';
import '../../features/admin/presentation/pages/admin_site_settings_page.dart';
import '../../features/admin/presentation/pages/admin_inquiries_page.dart';
import '../../features/admin/presentation/pages/admin_login_page.dart';
import '../../features/admin/presentation/pages/admin_product_editor_page.dart';
import '../../features/admin/presentation/pages/admin_products_page.dart';
import '../../features/admin/presentation/providers/admin_gate_providers.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/storefront/presentation/pages/category_page.dart';
import '../../features/storefront/presentation/pages/not_found_page.dart';
import '../../features/storefront/presentation/pages/product_detail_page.dart';
import '../../features/storefront/presentation/pages/search_page.dart';
import '../../features/storefront/presentation/pages/favourites_page.dart';
import '../../features/storefront/presentation/pages/storefront_home_page.dart';
import '../../features/text_editor/presentation/pages/admin_text_editor_page.dart';
import '../network/supabase_client_provider.dart';
import 'guards.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// The single router for both surfaces.
///
/// One decision point — [resolveAdminRedirect] — decides whether a path lands
/// on the public storefront or the guarded admin gateway, so the two
/// experiences can never disagree about who is allowed where.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final RouterRefreshNotifier refresher = RouterRefreshNotifier();

  ref.listen(currentSessionProvider, (_, __) => refresher.refresh());
  ref.listen(adminStatusProvider, (_, __) => refresher.refresh());
  // Unlocking the five-tap panel has to re-run the redirect, or the owner would
  // land back on the sign-in page they just avoided.
  ref.listen(adminGateUnlockedProvider, (_, __) => refresher.refresh());
  ref.onDispose(refresher.dispose);

  return GoRouter(
    initialLocation: Routes.storefront,
    refreshListenable: refresher,
    redirect: (BuildContext context, GoRouterState state) {
      final bool signedIn = ref.read(currentSessionProvider) != null;
      final AsyncValue<bool> adminStatus = ref.read(adminStatusProvider);
      return resolveAdminRedirect(
        location: state.matchedLocation,
        isSignedIn: signedIn,
        adminStatus: adminStatus,
        gateUnlocked: ref.read(adminGateUnlockedProvider),
      );
    },
    routes: <RouteBase>[
      // ── Storefront (public, no login) ─────────────────────────────────────
      GoRoute(
        path: Routes.storefront,
        name: 'storefront',
        builder: (_, __) => const StorefrontHomePage(),
      ),
      GoRoute(
        path: Routes.search,
        name: 'search',
        builder: (_, __) => const SearchPage(),
      ),
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        builder: (_, __) => const SettingsPage(),
      ),
      GoRoute(
        path: Routes.about,
        name: 'about',
        builder: (_, __) => const AboutPage(),
      ),
      GoRoute(
        path: Routes.favourites,
        name: 'favourites',
        builder: (_, __) => const FavouritesPage(),
      ),
      GoRoute(
        path: Routes.categoryPattern,
        name: 'category',
        builder: (_, GoRouterState state) => CategoryPage(
          slug: state.pathParameters['slug'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.productPattern,
        name: 'product',
        builder: (_, GoRouterState state) => ProductDetailPage(
          productId: state.pathParameters['id'] ?? '',
        ),
      ),

      // ── Admin gateway (guarded by `resolveAdminRedirect`) ─────────────────
      GoRoute(
        path: Routes.adminLogin,
        name: 'adminLogin',
        builder: (_, GoRouterState state) => AdminLoginPage(
          returnTo: state.uri.queryParameters[Routes.returnToParam],
          showNotAuthorised:
              state.uri.queryParameters['error'] == 'notAdmin',
        ),
      ),
      GoRoute(
        path: Routes.adminRoot,
        name: 'adminDashboard',
        builder: (_, __) => const AdminDashboardPage(),
        routes: <RouteBase>[
          GoRoute(
            path: 'categories',
            name: 'adminCategories',
            builder: (_, __) => const AdminCategoriesPage(),
          ),
          GoRoute(
            path: 'products',
            name: 'adminProducts',
            builder: (_, __) => const AdminProductsPage(),
            routes: <RouteBase>[
              // Declared before `:id` so `/admin/products/new` is not read as
              // the id of a product called "new".
              GoRoute(
                path: 'new',
                name: 'adminProductNew',
                builder: (_, __) => const AdminProductEditorPage(),
              ),
              GoRoute(
                path: ':id',
                name: 'adminProductEditor',
                builder: (_, GoRouterState state) => AdminProductEditorPage(
                  productId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'contacts',
            name: 'adminContacts',
            builder: (_, __) => const AdminContactsPage(),
          ),
          GoRoute(
            path: 'settings',
            name: 'adminSiteSettings',
            builder: (_, __) => const AdminSiteSettingsPage(),
          ),
          GoRoute(
            path: 'inquiries',
            name: 'adminInquiries',
            builder: (_, __) => const AdminInquiriesPage(),
          ),
          GoRoute(
            path: 'password',
            name: 'adminChangePassword',
            builder: (_, __) => const AdminChangePasswordPage(),
          ),
          GoRoute(
            path: 'text',
            name: 'adminTextEditor',
            builder: (_, __) => const AdminTextEditorPage(),
          ),
          GoRoute(
            path: 'gate-password',
            name: 'adminGatePassword',
            builder: (_, __) => const AdminGatePasswordPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (_, GoRouterState state) => NotFoundPage(
      location: state.uri.toString(),
    ),
  );
}
