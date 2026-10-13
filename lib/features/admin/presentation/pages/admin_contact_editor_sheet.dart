import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../contacts/domain/entities/contact_kind.dart';
import '../controllers/admin_editors.dart';

class ContactsEditorSheet extends ConsumerWidget {
  const ContactsEditorSheet({
    super.key,
    this.existing,
    required this.label,
    required this.value,
    required this.kind,
    required this.labelController,
    required this.valueController,
    required this.kindController,
    required this.formKey,
  });

  final ContactLink? existing;
  final TextEditingController label;
  final TextEditingController value;
  final TextEditingController kind;
  final TextEditingController labelController;
  final TextEditingController valueController;
  final TextEditingController kindController;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

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
          children: [
            Text(
              existing == null ? l10n.adminAddContact : l10n.adminEditContact,
              style: BrandTypography.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: l10n.adminContactLabel),
              validator: (v) => Validators.required(v)?.toString(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: l10n.adminContactValue),
              validator: (v) => validateContactValue(ContactKind.whatsapp, v)?.toString(),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ContactKind>(
              value: ContactKind.whatsapp,
              items: ContactKind.values
                  .map((k) => DropdownMenuItem(
                        value: k,
                        child: Text(k.name),
                      ))
                  .toList(),
              onChanged: (k) {
                if (k != null) {
                  kindController.text = k.name;
                  formKey.currentState!.validate();
                }
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  ref
                      .read(contactsEditorControllerProvider.notifier)
                      .save()
                      .then((ok) {
                        if (ok && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                }
              },
              icon: const Icon(Icons.save_outlined),
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
}
