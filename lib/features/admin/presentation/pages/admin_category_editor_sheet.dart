import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../catalog/domain/entities/category.dart';
import '../controllers/admin_editors.dart';

class CategoryEditorSheet extends ConsumerWidget {
  const CategoryEditorSheet({
    super.key,
    this.existing,
  });

  final Category? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CategoryEditorController controller =
        ref.watch(categoryEditorControllerProvider);

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
              existing == null ? l10n.adminCreateCategory : l10n.adminEditCategory,
              style: BrandTypography.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: l10n.adminCategoryName),
              validator: (v) => Validators.categoryName(v)?.toString(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: l10n.adminCategoryNameAm),
              validator: (v) => Validators.categoryName(v)?.toString(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: l10n.adminCategoryNameAr),
              validator: (v) => Validators.categoryName(v)?.toString(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: l10n.adminSlug),
              validator: (v) => Validators.slug(v)?.toString(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                if (controller.validate().isNotEmpty) return;
                controller.save().then((saved) {
                  if (saved && context.mounted) {
                    Navigator.of(context).pop();
                  }
                });
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
