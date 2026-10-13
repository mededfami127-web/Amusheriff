import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../settings/domain/entities/site_settings.dart';
import '../../../settings/presentation/providers/site_settings_providers.dart';

class LanguageAndThemePage extends ConsumerWidget {
  const LanguageAndThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPreferences state =
        ref.watch(appPreferencesProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.adminDefaultLanguage, style: BrandTypography.displaySmall),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'en', label: Text('English')),
            ButtonSegment(value: 'am', label: Text('አማርኛ')),
            ButtonSegment(value: 'ar', label: Text('عربي')),
          ],
          selected: {state.language.code},
          onSelectionChanged: (v) {
            ref
                .read(appPreferencesProvider.notifier)
                .setLanguage(AppLanguage.fromCode(v.first));
          },
        ),
        const SizedBox(height: 24),
        Text(l10n.settingsTheme, style: BrandTypography.displaySmall),
        const SizedBox(height: 16),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
            ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
          ],
          selected: {state.themeMode},
          onSelectionChanged: (v) {
            ref
                .read(appPreferencesProvider.notifier)
                .setThemeMode(v.first);
          },
        ),
      ],
    );
  }
}
