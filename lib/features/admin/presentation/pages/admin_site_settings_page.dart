

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/inline_failure_banner.dart';
import '../../../catalog/data/datasources/storage_datasource.dart';
import '../../../catalog/presentation/controllers/media_upload_controller.dart';
import '../../../settings/domain/entities/site_settings.dart';
import '../../../settings/presentation/providers/site_settings_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_text_field.dart';

/// Owner-editable branding: store name (EN/AM/AR), tagline, about, logo,
/// currency, default language and theme.
class AdminSiteSettingsPage extends ConsumerWidget {
  const AdminSiteSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SiteSettings settings = ref.watch(siteSettingsValueProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(siteSettingsEditorControllerProvider.notifier).load(settings);
    });

    final SiteSettingsEditorState state =
        ref.watch(siteSettingsEditorControllerProvider);
    final SiteSettingsEditorController controller =
        ref.read(siteSettingsEditorControllerProvider.notifier);

    final ThemeMode currentTheme = ref.watch(
      appPreferencesProvider.select((AppPreferencesState s) => s.themeMode),
    );

    return AdminScaffold(
      title: l10n.adminSiteSettings,
      selectedRoute: Routes.adminSiteSettings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: <Widget>[
          if (state.status.failure != null)
            InlineFailureBanner(
              failure: state.status.failure!,
              onDismiss: controller.acknowledge,
            ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          const SizedBox(height: 12),
          AdminTextField(
            label: l10n.adminStoreName,
            value: state.storeNameEn,
            error: state.fieldErrors['storeNameEn'],
            onChanged: controller.setStoreNameEn,
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          AdminTextField(
            label: l10n.adminStoreNameAm,
            value: state.storeNameAm,
            onChanged: controller.setStoreNameAm,
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          AdminTextField(
            label: l10n.adminStoreNameAr,
            value: state.storeNameAr,
            onChanged: controller.setStoreNameAr,
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          AdminTextField(
            label: l10n.adminTagline,
            value: state.tagline,
            onChanged: controller.setTagline,
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          AdminTextField(
            label: l10n.adminAbout,
            value: state.about,
            maxLines: 5,
            onChanged: controller.setAbout,
          ),
        ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
      ),
    );
  }
}

// ── logo picker
          AdminTextField(
            label: l10n.adminCurrency,
            value: state.currencyCode,
            onChanged: controller.setCurrency,
            readOnly: true,
            suffixIcon: const Icon(Icons.attach_money),
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          const SizedBox(height: 16),
          _LanguageAndCurrencyPanel(
            state: state,
            controller: controller,
            prefs: ref.read(appPreferencesProvider.select(
              (AppPreferencesState s) => s,
            )),
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          const SizedBox(height: 18),
          _LogoPicker(
            logoPath: state.logoPath,
            onPicked: controller.setLogoPath,
            isUploading: false,
            l10n: l10n,
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          const SizedBox(height: 22),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: BrandColors.royalViolet,
              foregroundColor: BrandColors.ivory,
              minimumSize: const Size.fromHeight(52),
            ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
            icon: state.status.saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.actionSave),
            onPressed: state.status.saving
                ? null
                : () async {
                    final bool ok = await controller.save();
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.adminSiteSettingsSaved)),
                      );
                      ref.invalidate(siteSettingsValueProvider);
                    }
                  },
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          const SizedBox(height: 14),
          _ThemePanel(
            current: currentTheme,
            l10n: l10n,
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
        ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
      ),
    );
  }
}

// ── language & currency panel ───────────────────────────────────────────────

class _LanguageAndCurrencyPanel extends ConsumerWidget {
  const _LanguageAndCurrencyPanel({
    required this.state,
    required this.controller,
    required this.prefs,
  });

  final SiteSettingsEditorState state;
  final SiteSettingsEditorController controller;
  final AppPreferencesState prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? BrandColors.deepPlum
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.adminDefaultLanguage,
            style:
                BrandTypography.labelLarge.copyWith(color: BrandColors.goldLight),
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'en', label: Text('English')),
              ButtonSegment<String>(value: 'am', label: Text('አማርኛ')),
              ButtonSegment<String>(value: 'ar', label: Text('عربي')),
            ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
            selected: <String>{state.defaultLanguage},
            onSelectionChanged: (Set<String> v) {
              controller.setDefaultLanguage(v.first);
              if (v.first != prefs.language.code) {
                ref.read(appPreferencesProvider.notifier).setLanguage(
                      AppLanguage.fromCode(v.first),
                    );
              }
            },
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.adminCurrency,
                  style: BrandTypography.labelLarge,
                ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
              ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
              Expanded(
                child: SegmentedButton<String>(
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(
                      value: 'ETB',
                      label: Text('ETB'),
                      icon: const Icon(Icons.attach_money),
                    ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
                    ButtonSegment<String>(
                      value: 'USD',
                      label: Text('USD'),
                      icon: const Icon(Icons.attach_money),
                    ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
                  ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
                  selected: <String>{state.currencyCode},
                  onSelectionChanged: (Set<String> v) =>
                      controller.setCurrency(v.first),
                ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
              ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
            ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
        ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
      ),
    );
  }
}

// ── theme panel ─────────────────────────────────────────────────────────────

class _ThemePanel extends StatelessWidget {
  const _ThemePanel({required this.current, required this.l10n});

  final ThemeMode current;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.settingsTheme,
          style: BrandTypography.labelLarge,
        ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
        const SizedBox(height: 10),
        SegmentedButton<ThemeMode>(
          segments: <ButtonSegment<ThemeMode>>[
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text(l10n.settingsThemeLight),
              icon: const Icon(Icons.light_mode_outlined),
            ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text(l10n.settingsThemeSystem),
              icon: const Icon(Icons.brightness_auto_outlined),
            ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text(l10n.settingsThemeDark),
              icon: const Icon(Icons.dark_mode_outlined),
            ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
          selected: <ThemeMode>{current},
          onSelectionChanged: (Set<ThemeMode> v) =>
              ref.read(appPreferencesProvider.notifier).setThemeMode(v.first),
        ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker ─────────────────────────────────────────────────────────────

class _LogoPicker extends ConsumerWidget {
  const _LogoPicker({
    required this.logoPath,
    required this.onPicked,
    required this.isUploading,
    required this.l10n,
  });

  final String? logoPath;
  final ValueChanged<String?> onPicked;
  final bool isUploading;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: BrandGradients.brand,
              borderRadius: BorderRadius.circular(14),
            ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
            child: Text(
              l10n.brandMonogram,
              style: BrandTypography.displayWeighted(700, size: 18)
                  .copyWith(color: BrandColors.goldLight),
            ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  logoPath ?? l10n.adminLogoPreview,
                  style: BrandTypography.bodySmall,
                ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
                if (logoPath != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    '1200 x 1200 · PNG or JPG',
                    style: BrandTypography.bodySmall.copyWith(
                      color:
                          BrandTypography.mutedOn(Theme.of(context).brightness),
                    ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
                  ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
                ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
              ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
            ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          TextButton.icon(
            onPressed: isUploading
                ? null
                : () async {
                    final XFile? picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1200,
                      imageQuality: 92,
                    );
                    if (picked == null) return;
                    final Uint8List bytes = await picked.readAsBytes();
                    final String path = StorageDataSource.brandPath(
                      name: 'logo',
                      extension: 'png',
                    );
                    await ref.read(storageDataSourceProvider).upload(
                          bucket: StorageDataSource.brandBucket,
                          path: path,
                          bytes: bytes,
                          contentType: 'image/png',
                        );
                    onPicked(path);
                  },
            icon: isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_rounded, size: 18),
            label: Text(
              isUploading ? l10n.adminUploadRetrying : l10n.adminUploadLogo,
            ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
          ),
      ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
    );
  }
}

// ── logo picker
        ],
    );
  }
}

// ── language & currency panel
    );
  }
}

// ── logo picker
      ),
    );
  }
}
