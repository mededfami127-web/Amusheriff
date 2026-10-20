import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/inline_failure_banner.dart';
import '../../../contacts/domain/entities/contact_settings.dart';
import '../../../contacts/presentation/providers/contact_settings_providers.dart';
import 'admin_text_field.dart';

/// Owner contact channels stored in the single-row `admin_contact_settings`.
///
/// The storefront only shows the fields that are non-empty, so clearing a
/// field is how the owner hides a channel. The save is an upsert of row 1.
class AdminContactSettingsSection extends ConsumerStatefulWidget {
  const AdminContactSettingsSection({super.key});

  @override
  ConsumerState<AdminContactSettingsSection> createState() =>
      _AdminContactSettingsSectionState();
}

class _AdminContactSettingsSectionState
    extends ConsumerState<AdminContactSettingsSection> {
  ContactSettings _draft = ContactSettings.empty;
  bool _dirty = false;
  bool _saving = false;
  AppFailure? _failure;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final AsyncValue<ContactSettings> async = ref.watch(
      contactSettingsProvider,
    );
    final ContactSettings current = _dirty
        ? _draft
        : async.value ?? ContactSettings.empty;

    void change(ContactSettings next) => setState(() {
      _draft = next;
      _dirty = true;
      _failure = null;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? BrandColors.deepPlum : BrandColors.ivory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(l10n.adminContactSettings, style: BrandTypography.labelLarge),
          const SizedBox(height: 6),
          Text(l10n.adminContactSettingsHint, style: BrandTypography.bodySmall),
          const SizedBox(height: 16),
          if (_failure != null) ...<Widget>[
            InlineFailureBanner(
              failure: _failure!,
              onDismiss: () => setState(() => _failure = null),
            ),
            const SizedBox(height: 14),
          ],
          AdminTextField(
            label: l10n.adminOwnerPhone,
            value: current.ownerPhone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onChanged: (String v) => change(current.copyWith(ownerPhone: v)),
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminOwnerEmail,
            value: current.ownerEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (String v) => change(current.copyWith(ownerEmail: v)),
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminWhatsappNumber,
            value: current.whatsappNumber,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onChanged: (String v) =>
                change(current.copyWith(whatsappNumber: v)),
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminTelegramHandle,
            value: current.telegramHandle,
            textInputAction: TextInputAction.next,
            onChanged: (String v) =>
                change(current.copyWith(telegramHandle: v)),
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminInstagramHandle,
            value: current.instagramHandle,
            textInputAction: TextInputAction.next,
            onChanged: (String v) =>
                change(current.copyWith(instagramHandle: v)),
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminFacebookHandle,
            value: current.facebookHandle,
            textInputAction: TextInputAction.next,
            onChanged: (String v) =>
                change(current.copyWith(facebookHandle: v)),
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminTiktokHandle,
            value: current.tiktokHandle,
            textInputAction: TextInputAction.next,
            onChanged: (String v) => change(current.copyWith(tiktokHandle: v)),
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminYoutubeHandle,
            value: current.youtubeHandle,
            textInputAction: TextInputAction.next,
            onChanged: (String v) => change(current.copyWith(youtubeHandle: v)),
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminWebsiteUrl,
            value: current.websiteUrl,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onChanged: (String v) => change(current.copyWith(websiteUrl: v)),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: BrandColors.royalViolet,
              foregroundColor: BrandColors.ivory,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.actionSave),
            onPressed: _saving ? null : () => _save(current, l10n),
          ),
        ],
      ),
    );
  }

  Future<void> _save(ContactSettings settings, AppLocalizations l10n) async {
    setState(() {
      _saving = true;
      _failure = null;
    });
    try {
      await ref.read(contactSettingsRepositoryProvider).save(settings);
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.adminSiteSettingsSaved)));
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _failure = failure;
        _saving = false;
      });
    }
  }
}
