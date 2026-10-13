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
      queryParameters: <String, String>{
        Routes.returnToParam: location,
      },
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
