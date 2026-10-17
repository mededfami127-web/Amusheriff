import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/inline_failure_banner.dart';
import '../../../catalog/domain/entities/category.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_text_field.dart';

/// Create/edit sheet for a category.
///
/// The sheet is stateless: [CategoryEditorController] holds the draft, and the
/// caller seeds it with `load(existing, parentId: …)` before opening. That only
/// works because the controller is `keepAlive` — an auto-disposed draft is
/// thrown away before a bottom sheet is first built, which would open an edit
/// form empty and create a subcategory as a top-level category.
///
/// It pops with `true` once the row is saved, so the list page can say which of
/// the two happened — created or updated — instead of the sheet guessing.
class CategoryEditorSheet extends ConsumerWidget {
  const CategoryEditorSheet({super.key, this.existing, this.parent});

  final Category? existing;

  /// The mother category when the owner tapped "Add subcategory" on a tile.
  /// `null` for a top-level category.
  final Category? parent;

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
    // A local so the null checks below promote it: the field itself cannot be
    // promoted, and a `parent!` at every use site would be the alternative.
    final Category? mother = parent;

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
                  ? (mother == null
                        ? l10n.adminCreateCategory
                        : l10n.adminCategoryAddSubcategory)
                  : l10n.adminEditCategory,
              style: BrandTypography.titleMedium,
            ),
            if (mother != null) ...<Widget>[
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.subdirectory_arrow_right_rounded,
                    size: 18,
                    color: BrandColors.gold,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      mother.nameFor(
                        Localizations.localeOf(context).languageCode,
                      ),
                      style: BrandTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            if (state.status.failure != null) ...<Widget>[
              const SizedBox(height: 14),
              InlineFailureBanner(
                failure: state.status.failure!,
                onDismiss: controller.acknowledge,
              ),
            ],
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
              onPressed: saving ? null : () => _save(context, ref, l10n),
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
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
          ],
        ),
      ),
    );
  }

  /// Validates, saves, and explains itself either way.
  ///
  /// A rejection used to look exactly like a dead button: the sheet stayed open
  /// with no message, because the draft's own failure was never rendered. Now a
  /// validation problem puts the field messages on screen *and* says so, and a
  /// refused write shows the typed failure in the banner above (and in a
  /// snackbar, because a bottom sheet can cover the banner).
  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final CategoryEditorController controller = ref.read(
      categoryEditorControllerProvider.notifier,
    );

    if (controller.validate().isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errorValidation)));
      return;
    }

    final bool saved = await controller.save();
    if (!context.mounted) return;

    if (saved) {
      Navigator.of(context).pop(true);
      return;
    }

    final failure = ref.read(categoryEditorControllerProvider).status.failure;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizeFailure(l10n, failure))));
    }
  }
}
