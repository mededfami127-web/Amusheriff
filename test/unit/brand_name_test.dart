import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/l10n/text_localizations.dart';
import 'package:amu_sharif_majlis/core/theme/app_theme.dart';
import 'package:amu_sharif_majlis/features/settings/domain/entities/site_settings.dart';
import 'package:amu_sharif_majlis/features/storefront/presentation/pages/storefront_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../layout/overflow_harness.dart';

/// The shop name is read from `public.site_settings`, so a project whose row
/// still holds a pre-rename spelling kept rendering the old brand no matter
/// what the compiled defaults or the l10n strings said. These tests pin the
/// client-side fallback that makes the rename independent of that row: a
/// legacy value resolves to the current brand, a custom value is untouched.
void main() {
  setUpAll(loadAppFonts);

  Future<void> pumpHome(
    WidgetTester tester,
    SiteSettings settings, {
    Size size = const Size(320, 640),
    double textScale = 2.0,
  }) async {
    final FakeBackend backend = FakeBackend(siteSettingsValue: settings);
    tester.view.physicalSize = size;
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
          builder: (BuildContext context, Widget? child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const StorefrontHomePage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// The hero title only — the app bar and the hero would otherwise both match
  /// the full brand string.
  String heroTitleText(WidgetTester tester) {
    final Finder hero = find.byKey(const ValueKey<String>('home-hero'));
    expect(hero, findsOneWidget);
    final Finder title = find.descendant(of: hero, matching: find.byType(Text));
    return tester
        .widgetList<Text>(title)
        .map((Text t) => t.data ?? '')
        .firstWhere(
          (String s) => s.contains('Arabiyan') || s.contains('Zahra'),
          orElse: () => '',
        );
  }

  testWidgets('a legacy stored name renders the renamed brand', (
    WidgetTester tester,
  ) async {
    await pumpHome(
      tester,
      const SiteSettings(storeNameEn: 'Amu Sharif Arabiyan Majlis'),
    );

    // App bar: first line large, the rest underneath, split on the first space.
    expect(find.text('Amusheriff'), findsOneWidget);
    expect(find.text('Arabiyan Mejlis and Furniture'), findsOneWidget);

    // Hero: the whole name, wrapping instead of ellipsising.
    expect(heroTitleText(tester), 'Amusheriff Arabiyan Mejlis and Furniture');

    // Nothing anywhere still reads as the old shop name. ("Majlis" on its own
    // is a category name, so only the full old brand is asserted absent.)
    expect(find.textContaining('Amu Sharif'), findsNothing);
    expect(find.textContaining('Sharif Arabiyan Majlis'), findsNothing);
  });

  testWidgets('every legacy spelling and a blank value resolve to the brand', (
    WidgetTester tester,
  ) async {
    for (final String legacy in <String>[
      'Amu Sharif Arabiyan Majlis',
      'Amu Sharif Arabian Majlis',
      'AMU SHARIF   ARABIYAN MAJLIS',
      'Amu Sharif Majlis',
      '',
      '   ',
    ]) {
      final SiteSettings settings = SiteSettings(storeNameEn: legacy);
      expect(
        settings.displayName('en'),
        'Amusheriff Arabiyan Mejlis and Furniture',
        reason: 'the stored name "$legacy" must not reach the screen',
      );
      expect(SiteSettings.isLegacyBrandName(legacy), isTrue);
    }

    // A name the owner typed is kept exactly as typed.
    const SiteSettings custom = SiteSettings(
      storeNameEn: 'Zahra Furniture House',
    );
    expect(custom.displayName('en'), 'Zahra Furniture House');
    expect(SiteSettings.isLegacyBrandName('Zahra Furniture House'), isFalse);
  });

  testWidgets('a custom owner name is shown instead of the brand', (
    WidgetTester tester,
  ) async {
    await pumpHome(
      tester,
      const SiteSettings(storeNameEn: 'Zahra Furniture House'),
    );

    expect(find.text('Zahra'), findsOneWidget);
    expect(find.text('Furniture House'), findsOneWidget);
    expect(heroTitleText(tester), 'Zahra Furniture House');
    expect(find.textContaining('Amusheriff'), findsNothing);
  });
}
