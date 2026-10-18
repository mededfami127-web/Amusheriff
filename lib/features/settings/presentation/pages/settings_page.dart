import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/gold_divider.dart';
import '../../../admin/presentation/providers/admin_gate_providers.dart';
import '../../../admin/presentation/widgets/admin_gate_sheet.dart';
import '../../../contacts/domain/entities/contact_link.dart';
import '../../../contacts/presentation/providers/contact_providers.dart';
import '../../domain/entities/site_settings.dart';
import '../providers/site_settings_providers.dart';

/// Local preferences plus the discreet Admin entry point required by the brief:
/// customers see language and appearance, the owner knows where the gateway is.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPreferencesState prefs = ref.watch(appPreferencesProvider);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final List<ContactLink> links =
        ref.watch(visibleContactLinksProvider).value ?? const <ContactLink>[];

    return AppScaffold(
      showLockup: false,
      title: l10n.settingsTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: <Widget>[
          _Section(title: l10n.settingsLanguage, icon: Icons.translate_rounded),
          const SizedBox(height: 10),
          RadioGroup<AppLanguage>(
            groupValue: prefs.language,
            onChanged: (AppLanguage? value) {
              if (value != null) {
                ref.read(appPreferencesProvider.notifier).setLanguage(value);
              }
            },
            child: Column(
              children: AppLanguage.values
                  .map(
                    (AppLanguage language) => RadioListTile<AppLanguage>(
                      value: language,
                      title: Text(
                        language.nativeName,
                        style: BrandTypography.bodyLarge,
                      ),
                      subtitle: Text(
                        language.englishName,
                        style: BrandTypography.bodySmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 26),
          _Section(
            title: l10n.settingsTheme,
            icon: Icons.brightness_6_outlined,
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text(l10n.settingsThemeSystem),
                icon: const Icon(Icons.brightness_auto_rounded, size: 18),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text(l10n.settingsThemeLight),
                icon: const Icon(Icons.light_mode_outlined, size: 18),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text(l10n.settingsThemeDark),
                icon: const Icon(Icons.dark_mode_outlined, size: 18),
              ),
            ],
            selected: <ThemeMode>{prefs.themeMode},
            showSelectedIcon: false,
            onSelectionChanged: (Set<ThemeMode> selection) => ref
                .read(appPreferencesProvider.notifier)
                .setThemeMode(selection.first),
          ),
          const SizedBox(height: 30),
          const GoldDivider(withOrnament: true),
          const SizedBox(height: 18),
          if (links.isNotEmpty) ...<Widget>[
            _Section(title: l10n.navContact, icon: Icons.link_rounded),
            const SizedBox(height: 6),
            ...links.map(
              (ContactLink link) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(link.kind.icon, color: BrandColors.gold),
                title: Text(link.label, style: BrandTypography.titleMedium),
                subtitle: Text(
                  link.displayValue,
                  style: BrandTypography.bodySmall,
                ),
                onTap: () => ref
                    .read(contactLauncherProvider)
                    .launch(link)
                    .then((bool ok) {
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.contactLaunchFailed)),
                        );
                      }
                    }),
              ),
            ),
            const SizedBox(height: 20),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.storefront_outlined,
              color: dark ? BrandColors.goldLight : BrandColors.royalViolet,
            ),
            title: Text(l10n.settingsAbout, style: BrandTypography.titleMedium),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.about),
          ),
          const SizedBox(height: 26),
          // Discreet owner entry — the same username/password panel the logo's
          // five taps open, so there is one door and one set of credentials.
          Center(
            child: TextButton.icon(
              onPressed: () => showAdminGateSheet(
                context,
                alreadyUnlocked: ref.read(adminGateProvider).unlocked,
              ),
              icon: const Icon(Icons.lock_outline_rounded, size: 17),
              label: Text(
                '${l10n.settingsAdminEntry} · ${l10n.settingsAdminHint}',
              ),
              style: TextButton.styleFrom(
                foregroundColor: BrandTypography.mutedOn(
                  Theme.of(context).brightness,
                ),
                textStyle: BrandTypography.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: <Widget>[
        ShaderMask(
          shaderCallback: BrandGradients.goldHorizontal.createShader,
          blendMode: BlendMode.srcIn,
          child: Icon(icon, size: 20, color: BrandColors.gold),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style:
              BrandTypography.displayForLocale(
                Localizations.localeOf(context),
                base: BrandTypography.displaySmall,
              ).copyWith(
                fontSize: 19,
                color: dark ? BrandColors.goldLight : BrandColors.charcoal,
              ),
        ),
      ],
    );
  }
}
