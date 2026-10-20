import 'package:amu_sharif_majlis/core/config/app_config.dart';
import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/theme/app_theme.dart';
import 'package:amu_sharif_majlis/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../layout/overflow_harness.dart';

/// The store listing points at a policy the app must actually open, so this
/// pins both the row and the URL behind it.
void main() {
  setUpAll(loadAppFonts);

  late _FakeUrlLauncherPlatform platform;

  setUp(() {
    platform = _FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = platform;
  });

  Widget harness(FakeBackend backend) {
    return ProviderScope(
      retry: (int retryCount, Object error) => null,
      overrides: backend.overridesList.cast(),
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light(),
        home: const SettingsPage(),
      ),
    );
  }

  testWidgets('the Privacy Policy row opens the published policy', (
    WidgetTester tester,
  ) async {
    final FakeBackend backend = FakeBackend();
    await tester.pumpWidget(harness(backend));
    await tester.pump();

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    expect(l10n.settingsPrivacyPolicy, 'Privacy Policy');

    await tester.scrollUntilVisible(
      find.text(l10n.settingsPrivacyPolicy),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Privacy Policy'), findsOneWidget);
    await tester.tap(find.text(l10n.settingsPrivacyPolicy));
    await tester.pump();

    expect(platform.launched, <String>[AppConfig.privacyPolicyUrl]);
    expect(
      AppConfig.privacyPolicyUrl,
      'https://sites.google.com/view/amusheriff-privacy/home',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a phone without a browser says so instead of doing nothing', (
    WidgetTester tester,
  ) async {
    platform.canLaunchAnything = false;
    final FakeBackend backend = FakeBackend();
    await tester.pumpWidget(harness(backend));
    await tester.pump();

    final AppLocalizations l10n = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    await tester.scrollUntilVisible(
      find.text(l10n.settingsPrivacyPolicy),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(l10n.settingsPrivacyPolicy));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(platform.launched, isEmpty);
    expect(find.text(l10n.contactLaunchFailed), findsOneWidget);
  });
}

class _FakeUrlLauncherPlatform extends UrlLauncherPlatform {
  final List<String> launched = <String>[];
  bool canLaunchAnything = true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => canLaunchAnything;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return true;
  }
}
