import 'package:flutter/foundation.dart';

import 'routes.dart';

/// Route guard for the admin gateway.
///
/// Deliberately a **pure function** so it can be unit-tested without a widget
/// tree or a router instance. The rules:
///
/// * The five-tap owner panel is the **only** door to `/admin/**`. The panel
///   itself asks for the owner's username/password, and — when the device holds
///   no Supabase session — for the owner's database account as well, so the
///   writes that follow carry a JWT (D-039).
/// * `gateUnlocked` therefore decides the guard on its own. The state lives in
///   the encrypted keystore, so it survives a restart until the owner signs out
///   of the gateway.
/// * Public storefront paths are never redirected.
/// * A locked device that deep-links into `/admin/**` lands on the storefront,
///   not on a form the customer has never seen.
/// * Once unlocked, `/admin/login` sends the owner straight to the dashboard.
///
/// This is a device-local lock: the catalogue is still read with the public
/// key, and the database decides every write through row-level security, so a
/// customer who somehow opened the panel gains no access to anyone else's data.
String? resolveAdminRedirect({
  required String location,
  required bool gateUnlocked,
}) {
  if (location == Routes.adminLogin) {
    return gateUnlocked ? Routes.adminRoot : null;
  }

  if (!Routes.isGuardedAdminPath(location)) return null;

  return gateUnlocked ? null : Routes.storefront;
}

/// Bridges Riverpod providers to go_router's `refreshListenable`.
///
/// `ref.listen` on the owner-gate state calls [refresh], and go_router re-runs
/// its redirect on the next frame.
class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
