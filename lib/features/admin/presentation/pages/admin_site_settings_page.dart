import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/storage_urls.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/inline_failure_banner.dart';
import '../../../catalog/data/datasources/storage_datasource.dart';
import '../../../catalog/domain/entities/media_kind.dart';
import '../../../catalog/presentation/controllers/media_upload_controller.dart';
import '../../../settings/domain/entities/site_settings.dart';
import '../../../settings/presentation/providers/site_settings_providers.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_text_field.dart';

/// Owner-editable storefront copy: store names, tagline, about, currency and
/// the logo. The draft is seeded from the live `site_settings` row, so the
/// form always opens on what customers are currently being served.
class AdminSiteSettingsPage extends ConsumerWidget {
  const AdminSiteSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SiteSettingsEditorState state = ref.watch(
      siteSettingsEditorControllerProvider,
    );
    final SiteSettingsEditorController controller = ref.read(
      siteSettingsEditorControllerProvider.notifier,
    );
    final bool saving = state.status.saving;

    return AdminScaffold(
      title: l10n.adminSiteSettings,
      selectedRoute: Routes.adminSiteSettings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: <Widget>[
          if (state.status.failure != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InlineFailureBanner(
                failure: state.status.failure!,
                onDismiss: controller.acknowledge,
              ),
            ),
          AdminTextField(
            label: l10n.adminStoreName,
            value: state.storeNameEn,
            textInputAction: TextInputAction.next,
            onChanged: controller.setStoreNameEn,
            error: localizeFieldKey(l10n, state.fieldErrors['storeNameEn']),
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminStoreNameAm,
            value: state.storeNameAm,
            textInputAction: TextInputAction.next,
            onChanged: controller.setStoreNameAm,
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminStoreNameAr,
            value: state.storeNameAr,
            textInputAction: TextInputAction.next,
            onChanged: controller.setStoreNameAr,
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminStoreNameOm,
            value: state.storeNameOm,
            textInputAction: TextInputAction.next,
            onChanged: controller.setStoreNameOm,
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminTagline,
            value: state.tagline,
            textInputAction: TextInputAction.next,
            onChanged: controller.setTagline,
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminAbout,
            value: state.about,
            maxLines: 5,
            onChanged: controller.setAbout,
          ),
          const SizedBox(height: 20),
          Text(l10n.adminCurrency, style: BrandTypography.labelLarge),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'ETB', label: Text('ETB')),
              ButtonSegment<String>(value: 'USD', label: Text('USD')),
            ],
            selected: <String>{state.currencyCode},
            showSelectedIcon: false,
            onSelectionChanged: (Set<String> selection) =>
                controller.setCurrency(selection.first),
          ),
          const SizedBox(height: 22),
          const _LanguageAndThemePanel(),
          const SizedBox(height: 22),
          _LogoPicker(
            logoPath: state.logoPath,
            onPicked: controller.setLogoPath,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: BrandColors.royalViolet,
              foregroundColor: BrandColors.ivory,
              minimumSize: const Size.fromHeight(52),
            ),
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.actionSave),
            onPressed: saving
                ? null
                : () async {
                    if (controller.validate().isNotEmpty) return;
                    final bool ok = await controller.save();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok ? l10n.adminSiteSettingsSaved : l10n.errorServer,
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

/// Language and appearance are device-local preferences, not store settings, so
/// they take effect immediately for this device.
class _LanguageAndThemePanel extends ConsumerWidget {
  const _LanguageAndThemePanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPreferencesState prefs = ref.watch(appPreferencesProvider);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? BrandColors.deepPlum : BrandColors.ivory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.adminDefaultLanguage, style: BrandTypography.labelLarge),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'en', label: Text('English')),
              ButtonSegment<String>(value: 'am', label: Text('አማርኛ')),
              ButtonSegment<String>(value: 'ar', label: Text('عربي')),
              ButtonSegment<String>(value: 'om', label: Text('Oromoo')),
            ],
            selected: <String>{prefs.language.code},
            showSelectedIcon: false,
            onSelectionChanged: (Set<String> selection) => ref
                .read(appPreferencesProvider.notifier)
                .setLanguage(AppLanguage.fromCode(selection.first)),
          ),
          const SizedBox(height: 16),
          Text(l10n.settingsTheme, style: BrandTypography.labelLarge),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text(l10n.settingsThemeLight),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text(l10n.settingsThemeSystem),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text(l10n.settingsThemeDark),
              ),
            ],
            selected: <ThemeMode>{prefs.themeMode},
            showSelectedIcon: false,
            onSelectionChanged: (Set<ThemeMode> selection) => ref
                .read(appPreferencesProvider.notifier)
                .setThemeMode(selection.first),
          ),
        ],
      ),
    );
  }
}

/// Uploads a new logo to the `brand` bucket and stores its path on the draft.
class _LogoPicker extends ConsumerStatefulWidget {
  const _LogoPicker({required this.logoPath, required this.onPicked});

  final String? logoPath;
  final ValueChanged<String?> onPicked;

  @override
  ConsumerState<_LogoPicker> createState() => _LogoPickerState();
}

class _LogoPickerState extends ConsumerState<_LogoPicker> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? path = widget.logoPath;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.adminLogoPreview, style: BrandTypography.labelLarge),
          const SizedBox(height: 12),
          if (path == null)
            Text(l10n.adminNoMedia, style: BrandTypography.bodySmall)
          else
            Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    ref.read(storageUrlsProvider).brand(path),
                    height: 56,
                    width: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(path, style: BrandTypography.bodySmall)),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: l10n.actionDelete,
                  onPressed: _uploading ? null : () => widget.onPicked(null),
                ),
              ],
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _uploading ? null : _pick,
            icon: _uploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.upload_outlined),
            label: Text(l10n.adminUploadLogo),
          ),
        ],
      ),
    );
  }

  Future<void> _pick() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final Uint8List bytes = await picked.readAsBytes();
      if (bytes.length > MediaKind.maxImageBytes) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.errorMediaImageTooLarge)),
        );
        return;
      }

      final String extension = _extensionOf(picked.name);
      final String path = await ref
          .read(storageDataSourceProvider)
          .upload(
            bucket: StorageDataSource.brandBucket,
            path: StorageDataSource.brandPath(
              name: 'logo',
              extension: extension,
            ),
            bytes: bytes,
            contentType: _contentTypeOf(extension),
          );
      widget.onPicked(path);
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizeFailure(l10n, ErrorMapper.map(error)))),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  static String _extensionOf(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return 'png';
    return fileName.substring(dot + 1).toLowerCase();
  }

  static String _contentTypeOf(String extension) => switch (extension) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'webp' => 'image/webp',
    _ => 'image/png',
  };
}
