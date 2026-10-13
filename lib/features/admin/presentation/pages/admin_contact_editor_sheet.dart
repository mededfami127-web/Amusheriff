import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/typography.dart';
import '../../../contacts/domain/entities/contact_kind.dart';
import '../../../contacts/domain/entities/contact_link.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_text_field.dart';

/// Create/edit sheet for a contact link.
///
/// Like the category sheet, the draft lives in [ContactsEditorController]; the
/// caller seeds it with `startNew()` / `startEdit(existing)` before opening.
class ContactsEditorSheet extends ConsumerWidget {
  const ContactsEditorSheet({super.key, this.existing});

  final ContactLink? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ContactDraftState state = ref.watch(contactsEditorControllerProvider);
    final ContactsEditorController controller =
        ref.read(contactsEditorControllerProvider.notifier);
    final bool saving = state.status.saving;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              existing == null ? l10n.adminAddContact : l10n.adminEditContact,
              style: BrandTypography.titleMedium,
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<ContactKind>(
              initialValue: state.kind,
              decoration: InputDecoration(labelText: l10n.adminChannel),
              items: ContactKind.values
                  .map(
                    (ContactKind kind) => DropdownMenuItem<ContactKind>(
                      value: kind,
                      child: Row(
                        children: <Widget>[
                          Icon(kind.icon, size: 18),
                          const SizedBox(width: 10),
                          Text(kind.name),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (ContactKind? kind) {
                if (kind != null) controller.setKind(kind);
              },
            ),
            const SizedBox(height: 14),
            AdminTextField(
              label: l10n.adminContactLabel,
              value: state.label,
              textInputAction: TextInputAction.next,
              onChanged: controller.setLabel,
              error: localizeFieldKey(l10n, state.fieldErrors['label']),
            ),
            const SizedBox(height: 14),
            AdminTextField(
              label: l10n.adminContactValue,
              value: state.value,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onChanged: controller.setValue,
              error: localizeFieldKey(l10n, state.fieldErrors['value']),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: state.isVisible,
              title: Text(l10n.adminVisibleInStore),
              onChanged: controller.setVisible,
            ),
            SizedBox(
              height: 48,
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: state.isPrimary,
                title: Text(l10n.adminMarkPrimary),
                onChanged: (bool? value) => controller.setPrimary(value ?? false),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: saving ? null : () => _save(context, controller),
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.actionSave),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.actionCancel),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    ContactsEditorController controller,
  ) async {
    if (controller.validate().isNotEmpty) return;
    final bool saved = await controller.save();
    if (saved && context.mounted) Navigator.of(context).pop();
  }
}
