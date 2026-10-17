import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/l10n/overridable_localizations.dart';
import 'package:amu_sharif_majlis/core/l10n/text_catalog.dart';
import 'package:amu_sharif_majlis/core/l10n/text_localizations.dart';
import 'package:amu_sharif_majlis/features/text_editor/presentation/providers/text_editor_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reads a string the same way every screen does.
class _ShowDashboard extends StatelessWidget {
  const _ShowDashboard();

  @override
  Widget build(BuildContext context) => Text(
    AppLocalizations.of(context).adminDashboard,
    textDirection: TextDirection.ltr,
  );
}

/// Pumps [app] and waits for the localization delegates' futures, exactly as
/// the framework does before it renders a screen that reads a string.
Future<void> _pumpLocalized(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.pump();
}

void main() {
  group('catalogue', () {
    test('covers every locale the picker offers', () {
      expect(kAppTextLocales, containsAll(<String>['en', 'am', 'ar', 'om']));
      expect(kAppTextLocales.first, 'en');
      for (final String code in kAppTextLocales) {
        expect(kAppTextLocaleNames[code], isNotNull);
      }
    });

    test('every string has English wording and a listed screen', () {
      expect(kAppTextEntries, isNotEmpty);
      for (final AppTextEntry entry in kAppTextEntries) {
        expect(
          entry.defaults['en'],
          isNotNull,
          reason: '${entry.key} has no en',
        );
        expect(
          kAppTextSections,
          contains(entry.sectionKey),
          reason: '${entry.key} points at an unlisted section',
        );
        expect(kAppTextByKey[entry.key], same(entry));
      }
    });

    test('the index and the list agree', () {
      expect(kAppTextByKey, hasLength(kAppTextEntries.length));
    });

    test('Oromo is translated for every key, like the other locales', () {
      for (final AppTextEntry entry in kAppTextEntries) {
        expect(
          entry.defaults['om'],
          isNotNull,
          reason: '${entry.key} is missing Oromo',
        );
      }
    });

    test('placeholder keys are flagged so the editor can warn', () {
      final AppTextEntry? category = kAppTextByKey['a11yOpenCategory'];
      expect(category?.placeholders, contains('name'));
      expect(category?.hasPlaceholders, isTrue);

      final AppTextEntry? dashboard = kAppTextByKey['adminDashboard'];
      expect(dashboard?.hasPlaceholders, isFalse);
    });
  });

  group('fill the gap', () {
    const AppTextEntry translated = AppTextEntry(
      key: 'gapTranslated',
      sectionKey: 'groupCommon',
      defaults: <String, String>{
        'en': 'Products',
        'am': 'ምርቶች',
        'ar': 'المنتجات',
        'om': 'Oomishaalee',
      },
    );
    const AppTextEntry copiedEnglish = AppTextEntry(
      key: 'gapCopied',
      sectionKey: 'groupCommon',
      defaults: <String, String>{
        'en': 'Order now',
        'am': 'አሁን ይዘዙ',
        'ar': 'اطلب الآن',
        'om': 'Order now',
      },
    );
    const AppTextEntry absent = AppTextEntry(
      key: 'gapAbsent',
      sectionKey: 'groupCommon',
      defaults: <String, String>{'en': 'Search'},
    );

    test('English is the source language, so it has no gaps', () {
      expect(isTextGap(copiedEnglish, 'en', const <String, String>{}), isFalse);
    });

    test('a row still reading English is a gap', () {
      expect(isTextGap(copiedEnglish, 'om', const <String, String>{}), isTrue);
      expect(isTextGap(translated, 'om', const <String, String>{}), isFalse);
    });

    test('a row with no wording for the language is a gap', () {
      expect(isTextGap(absent, 'om', const <String, String>{}), isTrue);
      expect(isTextGap(absent, 'am', const <String, String>{}), isTrue);
    });

    test('an owner rewrite fills the gap for good', () {
      expect(
        isTextGap(copiedEnglish, 'om', const <String, String>{
          'gapCopied': 'Amma ajaja',
        }),
        isFalse,
      );
    });

    test('plural strings stay read-only, so they are not gaps', () {
      const AppTextEntry plural = AppTextEntry(
        key: 'gapPlural',
        sectionKey: 'groupCommon',
        defaults: <String, String>{
          'en': '{count} results',
          'om': '{count} results',
        },
        isPlural: true,
      );
      expect(isTextGap(plural, 'om', const <String, String>{}), isFalse);
    });

    test('missing-words mode narrows the catalogue to the gaps', () {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          textOverridesProvider('om').overrideWith(
            (Ref ref) => Stream<Map<String, String>>.value(
              const <String, String>{'navHome': 'Mana koo'},
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(textEditorLocaleProvider.notifier).select('om');
      container.read(textEditorGapsOnlyProvider.notifier).set(true);

      final List<AppTextEntry> entries = container.read(
        filteredTextEntriesProvider,
      );
      final Set<String> gaps = container.read(textGapKeysProvider('om'));

      expect(entries, isNotEmpty);
      // Every row the editor shows in this mode is a gap, and no gap is hidden.
      expect(entries.map((AppTextEntry e) => e.key).toSet(), gaps);
      expect(gaps, isNot(contains('navHome')));

      // English never enters the list, even with the mode on.
      container.read(textEditorLocaleProvider.notifier).select('en');
      expect(container.read(filteredTextEntriesProvider), isEmpty);
    });
  });

  group('OverridableAppLocalizations', () {
    late AppLocalizations base;

    setUp(() async {
      base = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('falls back to the shipped wording when nothing is overridden', () {
      final OverridableAppLocalizations l10n = OverridableAppLocalizations(
        base,
        const <String, String>{},
      );

      expect(l10n.adminDashboard, base.adminDashboard);
      expect(l10n.owns('adminDashboard'), isFalse);
    });

    test('returns the owner wording, on every screen, for any key', () {
      final OverridableAppLocalizations l10n = OverridableAppLocalizations(
        base,
        const <String, String>{'adminDashboard': 'Daashboordii koo'},
      );

      expect(l10n.adminDashboard, 'Daashboordii koo');
      expect(l10n.owns('adminDashboard'), isTrue);
      // Untouched keys still come from the ARB.
      expect(l10n.adminProducts, base.adminProducts);
      expect(l10n.localeName, base.localeName);
    });

    test('keeps variables working when a template is rewritten', () {
      final OverridableAppLocalizations l10n = OverridableAppLocalizations(
        base,
        const <String, String>{'a11yOpenCategory': 'Ramaddii {name} bani'},
      );

      expect(l10n.a11yOpenCategory('Majlis'), 'Ramaddii Majlis bani');
    });

    test('a template without an override still delegates', () {
      final OverridableAppLocalizations l10n = OverridableAppLocalizations(
        base,
        const <String, String>{},
      );

      expect(l10n.a11yOpenCategory('Majlis'), base.a11yOpenCategory('Majlis'));
    });

    test('ICU plurals are left to the generated wording', () {
      final OverridableAppLocalizations l10n = OverridableAppLocalizations(
        base,
        const <String, String>{'searchResultsCount': 'ignored'},
      );

      expect(l10n.searchResultsCount(3), base.searchResultsCount(3));
    });
  });

  group('wired into a real widget tree', () {
    testWidgets('a screen renders the owner wording through of(context)', (
      WidgetTester tester,
    ) async {
      await _pumpLocalized(
        tester,
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates(
            overrides: const <String, String>{
              'adminDashboard': 'Daashboordii koo',
            },
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) => Text(
              AppLocalizations.of(context).adminDashboard,
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );

      expect(find.text('Daashboordii koo'), findsOneWidget);
    });

    testWidgets('with no overrides the shipped wording still renders', (
      WidgetTester tester,
    ) async {
      await _pumpLocalized(
        tester,
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates(
            overrides: const <String, String>{},
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          home: const _ShowDashboard(),
        ),
      );

      final AppLocalizations en = await AppLocalizations.delegate.load(
        const Locale('en'),
      );
      expect(find.text(en.adminDashboard), findsOneWidget);
    });

    testWidgets('Oromo renders the generated localizations', (
      WidgetTester tester,
    ) async {
      // The same delegate list the app installs, so this also proves Oromo no
      // longer trips the "not supported by all of its localization delegates"
      // warning the SDK emits for a locale it does not translate.
      await _pumpLocalized(
        tester,
        MaterialApp(
          locale: const Locale('om'),
          localizationsDelegates: appLocalizationsDelegates(
            overrides: const <String, String>{},
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          home: const _ShowDashboard(),
        ),
      );

      final AppLocalizations om = await AppLocalizations.delegate.load(
        const Locale('om'),
      );
      expect(find.text(om.adminDashboard), findsOneWidget);
      expect(om.adminDashboard, 'Daashboordii');
    });
  });

  group('OverridableLocalizationsDelegate', () {
    test('loads the override-aware instance for the active locale', () async {
      const OverridableLocalizationsDelegate delegate =
          OverridableLocalizationsDelegate(
            overrides: <String, String>{'navHome': 'Mana koo'},
          );

      final AppLocalizations l10n = await delegate.load(const Locale('en'));
      expect(l10n, isA<OverridableAppLocalizations>());
      expect(l10n.navHome, 'Mana koo');
    });

    test('an empty map returns the generated instance untouched', () async {
      const OverridableLocalizationsDelegate delegate =
          OverridableLocalizationsDelegate();

      final AppLocalizations l10n = await delegate.load(const Locale('en'));
      expect(l10n, isNot(isA<OverridableAppLocalizations>()));
    });

    test('reloads only when the wording actually changed', () {
      const OverridableLocalizationsDelegate first =
          OverridableLocalizationsDelegate(
            overrides: <String, String>{'navHome': 'a'},
          );

      expect(
        first.shouldReload(
          const OverridableLocalizationsDelegate(
            overrides: <String, String>{'navHome': 'a'},
          ),
        ),
        isFalse,
      );
      expect(
        first.shouldReload(
          const OverridableLocalizationsDelegate(
            overrides: <String, String>{'navHome': 'b'},
          ),
        ),
        isTrue,
      );
      expect(first.isSupported(const Locale('om')), isTrue);
    });
  });
}
