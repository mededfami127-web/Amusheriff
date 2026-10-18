import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes.dart';

/// Route guard for the admin gateway.
///
/// Deliberately a **pure function** so it can be unit-tested without a widget
/// tree or a router instance. The rules:
///
/// * Public storefront paths are never redirected.
/// * Any `/admin/**` path other than the login page requires a session.
/// * A signed-in non-admin is bounced back to the login page with
///   `?error=notAdmin` (the page explains that the account is not an owner).
/// * While the admin check is still in flight we allow the route through and
///   let the page render a loader, which avoids a login flash on cold start.
/// * A confirmed admin visiting the login page is sent to the dashboard.
/// * The five-tap owner panel is a device-local convenience lock and **not**
///   an authorisation boundary, so unlocking it grants no route access on its
///   own. Every admin write is decided by row-level security, which only
///   admits a signed-in owner (`public.is_admin()`); letting an unlocked but
///   anonymous visitor into `/admin/**` could therefore only ever end in a
///   save rejected with PostgreSQL 42501 — the "you do not have permission to
///   do that" the owner saw when creating a category or a product. The panel
///   now routes to the sign-in page (which keeps `returnTo`) instead of past
///   it, so every Save is issued with the owner's session attached.
String? resolveAdminRedirect({
  required String location,
  required bool isSignedIn,
  required AsyncValue<bool> adminStatus,
}) {
  final bool isLoginRoute = location == Routes.adminLogin;

  if (isLoginRoute) {
    if (isSignedIn && adminStatus.value == true) {
      return Routes.adminRoot;
    }
    return null;
  }

  if (!Routes.isGuardedAdminPath(location)) return null;

  if (!isSignedIn) {
    return Uri(
      path: Routes.adminLogin,
      queryParameters: <String, String>{Routes.returnToParam: location},
    ).toString();
  }

  if (adminStatus.isLoading) {
    // Verdict not in yet — render the page's own loading state.
    return null;
  }

  if (adminStatus.value != true) {
    return Uri(
      path: Routes.adminLogin,
      queryParameters: <String, String>{
        'error': 'notAdmin',
        Routes.returnToParam: location,
      },
    ).toString();
  }

  return null;
}

/// Bridges Riverpod providers to go_router's `refreshListenable`.
///
/// `ref.listen` on the session and admin-status providers calls [refresh], and
/// go_router re-runs its redirect on the next frame.
class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
