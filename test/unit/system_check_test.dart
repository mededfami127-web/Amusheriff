import 'dart:async';
import 'dart:io';

import 'package:amu_sharif_majlis/core/errors/app_failure.dart';
import 'package:amu_sharif_majlis/core/errors/error_localizer.dart';
import 'package:amu_sharif_majlis/core/errors/error_mapper.dart';
import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/network/supabase_client_provider.dart';
import 'package:amu_sharif_majlis/core/router/routes.dart';
import 'package:amu_sharif_majlis/features/admin/data/system_check_runner.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/pages/admin_system_check_page.dart';
import 'package:amu_sharif_majlis/features/admin/presentation/providers/system_check_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Covers the two halves of "the app shows errors on every screen":
///
///  * the classifier that tells a backend that was never set up apart from one
///    that is merely restricted or unreachable, and
///  * the gateway screen that turns those findings into the exact commands
///    that repair it.
void main() {
  group('classifyBackendFailure', () {
    test('a relation PostgREST has never seen is missing', () {
      expect(
        classifyBackendFailure(
          const PostgrestException(
            code: '42P01',
            message: 'relation "public.products" does not exist',
          ),
        ),
        SystemAssetStatus.missing,
      );
      expect(
        classifyBackendFailure(
          const PostgrestException(
            message:
                "Could not find the table 'public.categories' in the schema "
                'cache',
          ),
        ),
        SystemAssetStatus.missing,
      );
    });

    test('row-level security denying us is restricted, not missing', () {
      expect(
        classifyBackendFailure(
          const PostgrestException(
            code: '42501',
            message: 'permission denied for table inquiries',
          ),
        ),
        SystemAssetStatus.restricted,
      );
      expect(
        classifyBackendFailure(const AuthException('JWT expired')),
        SystemAssetStatus.restricted,
      );
    });

    test('a bucket the migration never created is missing', () {
      expect(
        classifyBackendFailure(const StorageException('Bucket not found')),
        SystemAssetStatus.missing,
      );
      expect(
        classifyBackendFailure(
          const StorageException('denied', statusCode: '403'),
        ),
        SystemAssetStatus.restricted,
      );
    });

    test('a 404 from the gateway means the function is not deployed', () {
      expect(
        classifyBackendFailure(
          const FunctionsHttpException(status: 404, details: 'Not Found'),
        ),
        SystemAssetStatus.missing,
      );
      // Any other answer came from the function itself, so it is deployed.
      expect(
        classifyBackendFailure(
          const FunctionsHttpException(status: 422, details: 'invalid body'),
        ),
        SystemAssetStatus.ok,
      );
      expect(
        classifyBackendFailure(
          const FunctionsFetchException(details: 'connection refused'),
        ),
        SystemAssetStatus.unreachable,
      );
    });

    test('a dead network is unreachable and anything else is unknown', () {
      expect(
        classifyBackendFailure(
          const SocketException('Failed host lookup: example.supabase.co'),
        ),
        SystemAssetStatus.unreachable,
      );
      expect(
        classifyBackendFailure(TimeoutException('too slow')),
        SystemAssetStatus.unreachable,
      );
      expect(
        classifyBackendFailure(StateError('something else entirely')),
        SystemAssetStatus.unknown,
      );
    });
  });

  group('ErrorMapper', () {
    late AppLocalizations l10n;

    setUp(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('names the missing backend instead of a generic server error', () {
      final AppFailure failure = ErrorMapper.map(
        const PostgrestException(
          code: '42P01',
          message:
              "Could not find the table 'public.products' in the schema cache",
        ),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.messageKey, 'errorBackendNotSetUp');
      expect(localizeFailure(l10n, failure), l10n.errorBackendNotSetUp);
      // The message sends the owner to the screen that lists the commands,
      // rather than burying shell syntax in a banner every customer sees.
      expect(l10n.errorBackendNotSetUp.toLowerCase(), contains('system check'));
    });

    test('a missing storage bucket maps to the same explanation', () {
      final AppFailure failure = ErrorMapper.map(
        const StorageException('Bucket not found', statusCode: '404'),
      );

      expect(failure, isA<StorageFailure>());
      expect(failure.messageKey, 'errorBackendNotSetUp');
    });

    test('an undeployed edge function maps to the same explanation', () {
      final AppFailure failure = ErrorMapper.map(
        const FunctionsHttpException(status: 404, details: 'Not Found'),
      );

      expect(failure.messageKey, 'errorBackendNotSetUp');
    });

    test('an existing but restricted table is still a permission failure', () {
      final AppFailure failure = ErrorMapper.map(
        const PostgrestException(
          code: '42501',
          message: 'permission denied for table inquiries',
        ),
      );

      expect(failure, isA<PermissionFailure>());
      expect(failure.messageKey, 'errorPermission');
    });

    test('an unreachable project is still a network failure', () {
      final AppFailure failure = ErrorMapper.map(
        const SocketException('Failed host lookup: example.supabase.co'),
      );

      expect(failure, isA<NetworkFailure>());
    });
  });

  group('AdminSystemCheckPage', () {
    late AppLocalizations l10n;

    setUp(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    Widget harness(List<SystemAssetCheck> checks) {
      final GoRouter router = GoRouter(
        initialLocation: Routes.adminSystemCheck,
        routes: <RouteBase>[
          GoRoute(
            path: Routes.adminSystemCheck,
            builder: (_, __) => const AdminSystemCheckPage(),
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          systemChecksProvider.overrideWith((_) async => checks),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
    }

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('an intact backend reports that everything is present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(<SystemAssetCheck>[
          const SystemAssetCheck(
            kind: SystemAssetKind.table,
            name: 'products',
            status: SystemAssetStatus.ok,
          ),
          // A table the anon key may not read is still a table that exists.
          const SystemAssetCheck(
            kind: SystemAssetKind.table,
            name: 'inquiries',
            status: SystemAssetStatus.restricted,
          ),
          const SystemAssetCheck(
            kind: SystemAssetKind.function,
            name: 'inquiry',
            status: SystemAssetStatus.ok,
          ),
        ]),
      );
      await settle(tester);

      expect(find.text(l10n.systemCheckAllGood), findsOneWidget);
      expect(find.text(l10n.systemCheckMissingSummary), findsNothing);
      expect(find.text(l10n.systemCheckOk), findsWidgets);
      expect(find.text(l10n.systemCheckRestricted), findsOneWidget);
      expect(find.text('products'), findsOneWidget);
      expect(find.text('inquiry'), findsOneWidget);
    });

    testWidgets('a backend that was never set up prints the fix commands', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(<SystemAssetCheck>[
          const SystemAssetCheck(
            kind: SystemAssetKind.table,
            name: 'products',
            status: SystemAssetStatus.missing,
          ),
          const SystemAssetCheck(
            kind: SystemAssetKind.table,
            name: 'categories',
            status: SystemAssetStatus.missing,
          ),
          const SystemAssetCheck(
            kind: SystemAssetKind.storage,
            name: 'product-media',
            status: SystemAssetStatus.missing,
          ),
          const SystemAssetCheck(
            kind: SystemAssetKind.function,
            name: 'inquiry',
            status: SystemAssetStatus.missing,
          ),
        ]),
      );
      await settle(tester);

      expect(find.text(l10n.systemCheckMissingSummary), findsOneWidget);
      expect(find.text(l10n.systemCheckFixDatabase), findsOneWidget);
      expect(find.text(l10n.systemCheckFixSeed), findsOneWidget);
      expect(find.text(l10n.systemCheckFixFunction), findsOneWidget);
      expect(find.text(l10n.systemCheckFixNetwork), findsNothing);
      // The list is lazy, so only the tiles on screen are built — what
      // matters is that every rendered one says the same thing.
      expect(find.text(l10n.systemCheckMissing), findsWidgets);
      expect(find.text(l10n.systemCheckAllGood), findsNothing);
      expect(find.byIcon(Icons.refresh_rounded), findsWidgets);
    });

    testWidgets('an unreachable project is not mistaken for a setup problem', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(<SystemAssetCheck>[
          const SystemAssetCheck(
            kind: SystemAssetKind.table,
            name: 'products',
            status: SystemAssetStatus.unreachable,
            detail: 'Failed host lookup: example.supabase.co',
          ),
        ]),
      );
      await settle(tester);

      expect(find.text(l10n.systemCheckFixNetwork), findsOneWidget);
      expect(find.text(l10n.systemCheckFixDatabase), findsNothing);
      expect(find.text(l10n.systemCheckUnreachable), findsOneWidget);
      expect(
        find.text('Failed host lookup: example.supabase.co'),
        findsOneWidget,
      );
    });
  });
}
