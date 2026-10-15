/// Every path in the app, in one place.
///
/// Keeping them as constants means the router, the deep-link handlers and the
/// navigation calls in Part 2 cannot drift apart.
abstract final class Routes {
  const Routes._();

  // ── Storefront (public) ───────────────────────────────────────────────────
  static const String storefront = '/';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String about = '/about';

  /// Customer favourites (a device-local list).
  static const String favourites = '/favourites';

  static const String categoryPattern = '/category/:slug';
  static String category(String slug) => '/category/$slug';

  static const String productPattern = '/product/:id';
  static String product(String id) => '/product/$id';

  // ── Admin gateway (guarded) ───────────────────────────────────────────────
  static const String adminLogin = '/admin/login';
  static const String adminRoot = '/admin';
  static const String adminCategories = '/admin/categories';
  static const String adminProducts = '/admin/products';
  static const String adminProductNew = '/admin/products/new';
  static const String adminProductEditorPattern = '/admin/products/:id';
  static String adminProductEditor(String id) => '/admin/products/$id';
  static const String adminContacts = '/admin/contacts';
  static const String adminSiteSettings = '/admin/settings';
  static const String adminInquiries = '/admin/inquiries';
  static const String adminChangePassword = '/admin/password';

  /// Every word of the app, per screen and per language.
  static const String adminTextEditor = '/admin/text';

  /// The device-local gateway password (the five-tap panel), as opposed to
  /// [adminChangePassword], which changes the Supabase account password.
  static const String adminGatePassword = '/admin/gate-password';

  /// Paths that require a session *and* `profiles.is_admin = true`.
  static bool isGuardedAdminPath(String path) =>
      path.startsWith(adminRoot) && path != adminLogin;

  /// Query parameter used to remember where the visitor was headed.
  static const String returnToParam = 'returnTo';

  /// Custom scheme registered on the platform side for the password-recovery
  /// email (`amusheriff://reset-password`).
  static const String recoveryDeepLink = 'amusheriff://reset-password';
}
