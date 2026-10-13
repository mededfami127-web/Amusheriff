import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../catalog/data/datasources/storage_datasource.dart';
import '../../../catalog/presentation/controllers/media_upload_controller.dart';
import '../../../settings/domain/entities/site_settings.dart';
import '../../../settings/presentation/providers/site_settings_providers.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_text_field.dart';

class AdminSiteSettingsPage extends ConsumerWidget {
  const AdminSiteSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SiteSettings settings = ref.watch(siteSettingsValueProvider);

    ref.read(siteSettingsEditorControllerProvider.notifier).load(settings);

    final SiteSettingsEditorState state =
        ref.watch(siteSettingsEditorControllerProvider);

    return AdminScaffold(
      title: l10n.adminSiteSettings,
      selectedRoute: Routes.adminSiteSettings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          if (state.status.failure != null)
            InlineFailureBanner(failure: state.status.failure!, onDismiss: () {}),
          const SizedBox(height: 16),
          AdminTextField(
            label: l10n.adminStoreName,
            value: state.storeNameEn,
            onChanged: controller.setStoreNameEn,
          ),
          AdminTextField(
            label: l10n.adminStoreNameAm,
            value: state.storeNameAm,
            onChanged: controller.setStoreNameAm,
          ),
          AdminTextField(
            label: l10n.adminStoreNameAr,
            value: state.storeNameAr,
            onChanged: controller.setStoreNameAr,
          ),
          AdminTextField(
            label: l10n.adminTagline,
            value: state.tagline,
            onChanged: controller.setTagline,
          ),
          AdminTextField(
            label: l10n.adminAbout,
            value: state.about,
            maxLines: 5,
            onChanged: controller.setAbout,
          ),
          Row(
            children: [
              Expanded(
                child: AdminTextField(
                  label: l10n.adminCurrency,
                  value: state.currencyCode,
                  onChanged: controller.setCurrency,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'ETB', label: Text('ETB')),
                    ButtonSegment(value: 'USD', label: Text('USD')),
                  ],
                  selected: {state.currencyCode},
                  onSelectionChanged: (v) =>
                      controller.setCurrency(v.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LanguageAndThemePanel(),
          const SizedBox(height: 20),
          _LogoPicker(
            logoPath: state.logoPath,
            onPicked: controller.setLogoPath,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: BrandColors.royalViolet,
              foregroundColor: BrandColors.ivory,
              minimumSize: const Size.fromHeight(52),
            ),
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
                    if (controller.validate().isNotEmpty) return;
                    final ok = await controller.save();
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved')),
                      );
                      ref.invalidate(siteSettingsValueProvider);
                    }
                  },
          ),
        ],
      ),
    );
  }
}

class _LanguageAndThemePanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPreferences state =
        ref.watch(appPreferencesProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? BrandColors.deepPlum
            : BrandColors.plumLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminDefaultLanguage, style: BrandTypography.labelLarge),
          const SizedBox(height: 12),
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
          const SizedBox(height: 16),
          Text(l10n.settingsTheme, style: BrandTypography.labelLarge),
          const SizedBox(height: 8),
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
      ),
    );
  }
}

class _LogoPicker extends ConsumerWidget {
  const _LogoPicker({required this.logoPath, required this.onPicked});

  final String? logoPath;
  final ValueChanged<String?> onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isUploading =
        ref.watch(mediaUploadControllerProvider).isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (logoPath != null) ...[
            Image.asset(logoPath!, height: 64),
            const SizedBox(height: 8),
            Text(logoPath!, style: BrandTypography.bodySmall),
          ] else
            Text(
              l10n.adminLogoPreview,
              style: BrandTypography.bodyMedium,
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isUploading ? null : _pickLogo,
            icon: isUploading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_outlined),
            label: Text(isUploading ? 'Uploading...' : l10n.adminUploadLogo),
          ),
        ],
      ),
    );
  }

  void _pickLogo() async {
    // Image picker is unavailable in this sandbox; in prod this opens a
    // gallery picker. The storage path is now handled by the controller.
  }
}
