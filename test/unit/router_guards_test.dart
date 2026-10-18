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

  group('the five-tap owner gate is not an authorisation boundary', () {
    test('unlocking without a session goes to sign-in', () {
      // The regression: an unlocked panel used to admit an anonymous visitor,
      // so every Save went to Postgres as `anon` and came back 42501 ("you do
      // not have permission to do that").
      final String? target = resolveAdminRedirect(
        location: Routes.adminProducts,
        isSignedIn: false,
        adminStatus: notAdmin,
      );
      expect(target, isNotNull);
      final Uri uri = Uri.parse(target!);
      expect(uri.path, Routes.adminLogin);
      expect(uri.queryParameters[Routes.returnToParam], Routes.adminProducts);

      final String? textTarget = resolveAdminRedirect(
        location: Routes.adminTextEditor,
        isSignedIn: false,
        adminStatus: notAdmin,
      );
      expect(textTarget, isNotNull);
      expect(Uri.parse(textTarget!).path, Routes.adminLogin);
    });

    test('the sign-in page stays reachable so the owner can sign in', () {
      expect(
        resolveAdminRedirect(
          location: Routes.adminLogin,
          isSignedIn: false,
          adminStatus: notAdmin,
        ),
        isNull,
      );
    });

    test('the storefront stays public', () {
      expect(
        resolveAdminRedirect(
          location: Routes.favourites,
          isSignedIn: false,
          adminStatus: notAdmin,
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
