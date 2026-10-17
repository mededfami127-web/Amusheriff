import 'package:amu_sharif_majlis/core/router/guards.dart';
import 'package:amu_sharif_majlis/core/router/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const AsyncValue<bool> loading = AsyncValue<bool>.loading();
  const AsyncValue<bool> admin = AsyncValue<bool>.data(true);
  const AsyncValue<bool> notAdmin = AsyncValue<bool>.data(false);
  final AsyncValue<bool> failed = AsyncValue<bool>.error(
    StateError('boom'),
    StackTrace.empty,
  );

  group('public storefront', () {
    test('is never redirected', () {
      for (final String path in <String>[
        Routes.storefront,
        Routes.search,
        Routes.settings,
        Routes.about,
        '/category/majlis-sofas',
        '/product/abc-123',
      ]) {
        expect(
          resolveAdminRedirect(
            location: path,
            isSignedIn: false,
            adminStatus: notAdmin,
          ),
          isNull,
          reason: '$path must stay public',
        );
      }
    });
  });

  group('guarded admin paths', () {
    test('anonymous users go to login with returnTo preserved', () {
      final String? target = resolveAdminRedirect(
        location: Routes.adminProducts,
        isSignedIn: false,
        adminStatus: notAdmin,
      );
      expect(target, isNotNull);
      final Uri uri = Uri.parse(target!);
      expect(uri.path, Routes.adminLogin);
      expect(uri.queryParameters[Routes.returnToParam], Routes.adminProducts);
    });

    test('a signed-in non-admin is bounced with error=notAdmin', () {
      final String? target = resolveAdminRedirect(
        location: Routes.adminRoot,
        isSignedIn: true,
        adminStatus: notAdmin,
      );
      final Uri uri = Uri.parse(target!);
      expect(uri.path, Routes.adminLogin);
      expect(uri.queryParameters['error'], 'notAdmin');
    });

    test('an errored admin check is treated as not-admin', () {
      final String? target = resolveAdminRedirect(
        location: Routes.adminRoot,
        isSignedIn: true,
        adminStatus: failed,
      );
      expect(Uri.parse(target!).path, Routes.adminLogin);
    });

    test('a pending check lets the route render its own loader', () {
      expect(
        resolveAdminRedirect(
          location: Routes.adminRoot,
          isSignedIn: true,
          adminStatus: loading,
        ),
        isNull,
      );
    });

    test('a confirmed admin passes through', () {
      expect(
        resolveAdminRedirect(
          location: Routes.adminProducts,
          isSignedIn: true,
          adminStatus: admin,
        ),
        isNull,
      );
    });
  });

  group('the five-tap owner gate', () {
    test('unlocking admits a visitor with no Supabase session', () {
      expect(
        resolveAdminRedirect(
          location: Routes.adminProducts,
          isSignedIn: false,
          adminStatus: notAdmin,
          gateUnlocked: true,
        ),
        isNull,
      );
      expect(
        resolveAdminRedirect(
          location: Routes.adminTextEditor,
          isSignedIn: false,
          adminStatus: notAdmin,
          gateUnlocked: true,
        ),
        isNull,
      );
    });

    test('the sign-in page stays reachable, because saving needs a session', () {
      // Unlocking the panel opens the gateway; it does not sign anyone in, and
      // every write is still decided by RLS.
      expect(
        resolveAdminRedirect(
          location: Routes.adminLogin,
          isSignedIn: false,
          adminStatus: notAdmin,
          gateUnlocked: true,
        ),
        isNull,
      );
    });

    test('a locked gate leaves the existing rules untouched', () {
      final String? target = resolveAdminRedirect(
        location: Routes.adminRoot,
        isSignedIn: true,
        adminStatus: notAdmin,
        gateUnlocked: false,
      );
      expect(Uri.parse(target!).path, Routes.adminLogin);
    });

    test('the storefront stays public either way', () {
      expect(
        resolveAdminRedirect(
          location: Routes.favourites,
          isSignedIn: false,
          adminStatus: notAdmin,
          gateUnlocked: true,
        ),
        isNull,
      );
    });
  });

  group('login route', () {
    test('a confirmed admin is sent to the dashboard', () {
      expect(
        resolveAdminRedirect(
          location: Routes.adminLogin,
          isSignedIn: true,
          adminStatus: admin,
        ),
        Routes.adminRoot,
      );
    });

    test('anonymous visitors stay on the form', () {
      expect(
        resolveAdminRedirect(
          location: Routes.adminLogin,
          isSignedIn: false,
          adminStatus: notAdmin,
        ),
        isNull,
      );
    });

    test('a signed-in non-admin stays on the form to read the explanation', () {
      expect(
        resolveAdminRedirect(
          location: Routes.adminLogin,
          isSignedIn: true,
          adminStatus: notAdmin,
        ),
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
