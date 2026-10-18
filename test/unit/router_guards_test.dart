import 'package:amu_sharif_majlis/core/router/guards.dart';
import 'package:amu_sharif_majlis/core/router/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('public storefront', () {
    test('is never redirected', () {
      for (final String path in <String>[
        Routes.storefront,
        Routes.search,
        Routes.settings,
        Routes.about,
        Routes.favourites,
        '/category/majlis-sofas',
        '/product/abc-123',
      ]) {
        for (final bool unlocked in <bool>[true, false]) {
          expect(
            resolveAdminRedirect(location: path, gateUnlocked: unlocked),
            isNull,
            reason: '$path must stay public (gate unlocked: $unlocked)',
          );
        }
      }
    });
  });

  group('guarded admin paths', () {
    test('the unlocked owner panel is the only key needed', () {
      // No session, no e-mail/password screen: the gate is the door.
      for (final String path in <String>[
        Routes.adminRoot,
        Routes.adminProducts,
        Routes.adminProductEditor('abc'),
        Routes.adminTextEditor,
        Routes.adminGatePassword,
        Routes.adminSystemCheck,
      ]) {
        expect(
          resolveAdminRedirect(location: path, gateUnlocked: true),
          isNull,
          reason: '$path must open straight after the panel unlocks',
        );
      }
    });

    test('a locked device deep-linking into the gateway lands on the shop', () {
      for (final String path in <String>[
        Routes.adminRoot,
        Routes.adminCategories,
        Routes.adminSiteSettings,
      ]) {
        expect(
          resolveAdminRedirect(location: path, gateUnlocked: false),
          Routes.storefront,
          reason: '$path must not expose a form the customer never asked for',
        );
      }
    });
  });

  group('login route', () {
    test('an unlocked gateway sends the owner to the dashboard', () {
      expect(
        resolveAdminRedirect(location: Routes.adminLogin, gateUnlocked: true),
        Routes.adminRoot,
      );
    });

    test('a locked gateway leaves the form reachable', () {
      expect(
        resolveAdminRedirect(location: Routes.adminLogin, gateUnlocked: false),
        isNull,
      );
    });
  });

  group('Routes.isGuardedAdminPath', () {
    test('covers /admin/** but not the login page', () {
      expect(Routes.isGuardedAdminPath(Routes.adminRoot), isTrue);
      expect(Routes.isGuardedAdminPath(Routes.adminProducts), isTrue);
      expect(Routes.isGuardedAdminPath(Routes.adminProductEditor('x')), isTrue);
      expect(Routes.isGuardedAdminPath(Routes.adminTextEditor), isTrue);
      expect(Routes.isGuardedAdminPath(Routes.adminGatePassword), isTrue);
      expect(Routes.isGuardedAdminPath(Routes.adminLogin), isFalse);
      expect(Routes.isGuardedAdminPath(Routes.storefront), isFalse);
      expect(Routes.isGuardedAdminPath(Routes.favourites), isFalse);
      expect(Routes.isGuardedAdminPath('/adminish'), isTrue); // prefix match
    });
  });
}
