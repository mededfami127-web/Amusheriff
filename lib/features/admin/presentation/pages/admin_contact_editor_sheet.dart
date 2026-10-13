import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../contacts/domain/entities/contact_kind.dart';
import '../../../contacts/domain/entities/contact_link.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_text_field.dart';

/// Bottom sheet to add or edit one contact link.
Future<void> showContactEditorSheet(
  BuildContext context, {
  ContactLink? existing,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ContactEditorSheet(existing: existing),
    );

class _ContactEditorSheet extends ConsumerWidget {
  const _ContactEditorSheet({this.existing});

  final ContactLink? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ContactsEditorController controller =
          ref.read(contactsEditorControllerProvider.notifier);
      if (existing == null) {
        controller.startNew();
      } else {
        controller.startEdit(existing!);
      }
    });

    final ContactDraftState state = ref.watch(contactsEditorControllerProvider);
    final ContactsEditorController controller =
        ref.read(contactsEditorControllerProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              state.isNew ? l10n.adminAddContact : l10n.adminEditContact,
              style: BrandTypography.displayWeighted(700, size: 22),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<ContactKind>(
              initialValue: state.kind,
              decoration: InputDecoration(
                labelText: l10n.adminChannel,
                border: const OutlineInputBorder(),
              ),
              items: ContactKind.values
                  .map(
                    (ContactKind kind) => DropdownMenuItem<ContactKind>(
                      value: kind,
                      child: Text(
                        contactKindLabel(l10n, kind),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (ContactKind? v) {
                if (v != null) controller.setKind(v);
              },
            ),
            const SizedBox(height: 14),
            AdminTextField(
              label: l10n.adminContactLabel,
              value: state.label,
              error: state.fieldErrors['label'],
              onChanged: controller.setLabel,
            ),
            AdminTextField(
              label: l10n.adminContactValue,
              value: state.value,
              error: state.fieldErrors['value'],
              keyboardType: _keyboardFor(state.kind),
              onChanged: controller.setValue,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.adminMarkPrimary,
                  style: BrandTypography.bodyMedium),
              value: state.isPrimary,
              activeThumbColor: BrandColors.gold,
              onChanged: controller.setPrimary,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.adminVisibleInStore,
                  style: BrandTypography.bodyMedium),
              value: state.isVisible,
              activeThumbColor: BrandColors.gold,
              onChanged: controller.setVisible,
            ),
            if (state.status.failure != null) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                localizeFailure(l10n, state.status.failure!),
                style: BrandTypography.bodySmall
                    .copyWith(color: BrandColors.danger),
              ),
            ],
            const SizedBox(height: 14),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: BrandColors.royalViolet,
                foregroundColor: BrandColors.ivory,
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: state.status.saving
                  ? null
                  : () async {
                      final bool wasNew = state.isNew;
                      final bool ok = await controller.save();
                      if (ok && context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(wasNew
                                ? l10n.adminContactSaved
                                : l10n.adminContactSaved),
                          ),
                        );
                      }
                    },
              child: state.status.saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Text(state.isNew ? l10n.actionCreate : l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }

  TextInputType _keyboardFor(ContactKind kind) => switch (kind) {
        ContactKind.phone || ContactKind.whatsapp =>
          TextInputType.phone,
        ContactKind.email => TextInputType.emailAddress,
        _ => TextInputType.url,
      };
}

/// Localized channel name. The generated lookups are compile-time getters, so
/// the label has to be selected with an exhaustive switch rather than a map.
String contactKindLabel(AppLocalizations l10n, ContactKind kind) =>
    switch (kind) {
      ContactKind.whatsapp => l10n.contactWhatsApp,
      ContactKind.telegram => l10n.contactTelegram,
      ContactKind.phone => l10n.contactPhone,
      ContactKind.email => l10n.contactEmail,
      ContactKind.instagram => l10n.contactInstagram,
      ContactKind.facebook => l10n.contactFacebook,
      ContactKind.tiktok => l10n.contactTikTok,
      ContactKind.youtube => l10n.contactYouTube,
      ContactKind.website => l10n.contactWebsite,
      ContactKind.location => l10n.contactLocation,
      ContactKind.other => l10n.contactOther,
    };
