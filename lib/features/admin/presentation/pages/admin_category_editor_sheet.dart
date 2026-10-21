import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/storage_urls.dart';
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
                showDetails: true,
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
              label: l10n.adminCategoryNameOm,
              value: state.nameOm,
              textInputAction: TextInputAction.next,
              onChanged: controller.setNameOm,
              error: localizeFieldKey(l10n, state.fieldErrors['nameOm']),
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
            const SizedBox(height: 14),
            _CoverField(state: state, controller: controller),
            const SizedBox(height: 6),
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
              onPressed: () async {
                // The photo may already be in the bucket; a cancelled form
                // must not strand it there.
                await controller.discardPendingCover();
                if (context.mounted) Navigator.of(context).pop(false);
              },
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

/// Optional cover image: pick → upload to the `brand` bucket → the row stores
/// the path on Save.
///
/// The upload happens while picking (storage first, row second), so the sheet
/// never writes a `cover_path` that points at nothing, and cancelling the sheet
/// deletes the file this opening uploaded.
class _CoverField extends ConsumerWidget {
  const _CoverField({required this.state, required this.controller});

  final CategoryEditorState state;
  final CategoryEditorController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String? cover = state.coverPath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.adminCoverImage,
          style: BrandTypography.labelLarge.copyWith(
            color: BrandColors.goldLight,
          ),
        ),
        const SizedBox(height: 8),
        if (cover != null) ...<Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 96,
              child: CachedNetworkImage(
                imageUrl: ref.read(storageUrlsProvider).categoryCover(cover),
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(
                  color: BrandColors.plumSurface,
                ),
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: BrandColors.plumSurface,
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Material(
          color: dark ? BrandColors.plumSurface : BrandColors.ivory,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: state.coverUploading ? null : controller.pickCover,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  state.coverUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Icon(
                          Icons.upload_outlined,
                          size: 18,
                          color: BrandColors.gold,
                        ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      cover == null
                          ? l10n.actionSelectImage
                          : l10n.adminCover,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BrandTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
