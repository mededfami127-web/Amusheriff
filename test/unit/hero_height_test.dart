import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/l10n/text_localizations.dart';
import 'package:amu_sharif_majlis/core/theme/app_theme.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/storefront_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../layout/overflow_harness.dart';

/// The home hero is a fixed marketing block, so its height can be pinned.
///
/// Measured at 320 dp wide: 359 dp before this change, 168 dp after (-53%).
/// The regression gate keeps it at or below 190 dp so the category rail is
/// visible without scrolling on a 320×568 phone.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('home hero stays compact at 320dp wide', (
    WidgetTester tester,
  ) async {
    final FakeBackend backend = FakeBackend();
    tester.view.physicalSize = const Size(320, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (int retryCount, Object error) => null,
        overrides: backend.overridesList.cast(),
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: appLocalizationsDelegates(
            overrides: const <String, String>{},
          ),
          theme: AppTheme.light(),
          home: const StorefrontHomePage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final Finder hero = find.byKey(const ValueKey<String>('home-hero'));
    expect(hero, findsOneWidget);

    final Size size = tester.getSize(hero);
    expect(
      size.height,
      lessThanOrEqualTo(190),
      reason: 'hero is ${size.height}dp tall, expected <= 190dp',
    );
  });
}
