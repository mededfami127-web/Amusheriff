import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/typography.dart';
import '../../../catalog/domain/entities/category.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_text_field.dart';

/// Create/edit sheet for a category.
///
/// The sheet is stateless: [CategoryEditorController] holds the draft, so the
/// caller seeds it with `load(existing)` before opening and the fields simply
/// render whatever the controller holds.
class CategoryEditorSheet extends ConsumerWidget {
  const CategoryEditorSheet({super.key, this.existing});

  final Category? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CategoryEditorState state = ref.watch(
      categoryEditorControllerProvider,
    );
    final CategoryEditorController controller = ref.read(
      categoryEditorControllerProvider.notifier,
    );
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
              existing == null
                  ? l10n.adminCreateCategory
                  : l10n.adminEditCategory,
              style: BrandTypography.titleMedium,
            ),
            const SizedBox(height: 18),
            AdminTextField(
              label: l10n.adminCategoryName,
              value: state.name,
              autofocus: existing == null,
              textInputAction: TextInputAction.next,
              onChanged: controller.setName,
              error: localizeFieldKey(l10n, state.fieldErrors['name']),
            ),
            const SizedBox(height: 14),
            AdminTextField(
              label: l10n.adminCategoryNameAm,
              value: state.nameAm,
              textInputAction: TextInputAction.next,
              onChanged: controller.setNameAm,
              error: localizeFieldKey(l10n, state.fieldErrors['nameAm']),
            ),
            const SizedBox(height: 14),
            AdminTextField(
              label: l10n.adminCategoryNameAr,
              value: state.nameAr,
              textInputAction: TextInputAction.next,
              onChanged: controller.setNameAr,
              error: localizeFieldKey(l10n, state.fieldErrors['nameAr']),
            ),
            const SizedBox(height: 14),
            AdminTextField(
              label: l10n.adminSlug,
              value: state.slug,
              textInputAction: TextInputAction.done,
              onChanged: (String value) {
                controller.setSlug(value);
                controller.toggleSlugTouched();
              },
              error: localizeFieldKey(l10n, state.fieldErrors['slug']),
            ),
            const SizedBox(height: 6),
            Text(l10n.adminSlugAuto, style: BrandTypography.bodySmall),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: state.isVisible,
              title: Text(l10n.adminVisibleInStore),
              onChanged: controller.setVisible,
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
    CategoryEditorController controller,
  ) async {
    if (controller.validate().isNotEmpty) return;
    final bool saved = await controller.save();
    if (saved && context.mounted) Navigator.of(context).pop();
  }
}
