import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../catalog/data/datasources/storage_datasource.dart';
import '../../../catalog/domain/drafts/catalog_drafts.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/repositories/catalog_repositories.dart';
import '../../../catalog/presentation/controllers/media_upload_controller.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../controllers/admin_editors.dart';

/// Bottom sheet to create or edit a category.
Future<void> showCategoryEditorSheet(
  BuildContext context, {
  Category? category,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CategoryEditorSheet(existing: category),
    );

class _CategoryEditorSheet extends ConsumerWidget {
  const _CategoryEditorSheet({this.existing});

  final Category? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // Re-seed on first build for this sheet instance.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryEditorControllerProvider.notifier).load(existing);
    });

    final CategoryEditorState state = ref.watch(categoryEditorControllerProvider);
    final CategoryEditorController controller =
        ref.read(categoryEditorControllerProvider.notifier);

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
              state.isNew ? l10n.adminCreateCategory : l10n.adminEditCategory,
              style: BrandTypography.displayWeighted(700, size: 22),
            ),
            const SizedBox(height: 18),
            _Field(
              label: l10n.adminCategoryName,
              value: state.name,
              error: state.fieldErrors['name'],
              onChanged: controller.setName,
              onEditingComplete: controller.autoSlugFromName,
            ),
            _Field(
              label: l10n.adminCategoryNameAm,
              value: state.nameAm,
              onChanged: controller.setNameAm,
            ),
            _Field(
              label: l10n.adminCategoryNameAr,
              value: state.nameAr,
              onChanged: controller.setNameAr,
            ),
            _Field(
              label: l10n.adminSlug,
              hint: l10n.adminSlugAuto,
              value: state.slug,
              error: state.fieldErrors['slug'],
              onChanged: (String v) {
                controller.toggleSlugTouched();
                controller.setSlug(v);
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.adminVisibleInStore,
                  style: BrandTypography.bodyMedium),
              value: state.isVisible,
              activeThumbColor: BrandColors.gold,
              onChanged: controller.setVisible,
            ),
            _CoverPicker(
              coverPath: state.coverPath,
              onPicked: controller.setCoverPath,
            ),
            if (state.status.failure != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                localizeFailure(l10n, state.status.failure!),
                style: BrandTypography.bodySmall
                    .copyWith(color: BrandColors.danger),
              ),
            ],
            const SizedBox(height: 18),
            GradientButton(
              label: state.isNew ? l10n.actionCreate : l10n.actionSave,
              isLoading: state.status.saving,
              onPressed: () async {
                final bool wasNew = state.isNew;
                final bool ok = await controller.save();
                if (ok && context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        wasNew
                            ? l10n.adminCategoryCreated
                            : l10n.adminCategoryUpdated,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Labeled text field with a localized error line. Values live in the
/// controller, so the form survives rebuilds and never loses input.
class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.error,
    this.onEditingComplete,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final String? error;
  final VoidCallback? onEditingComplete;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant _Field old) {
    super.didUpdateWidget(old);
    // Only adopt external changes (slug autofill); never fight the cursor
    // while the owner is typing.
    if (old.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          errorText: widget.error,
          border: const OutlineInputBorder(),
        ),
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
      ),
    );
  }
}

// ── Delete / move ───────────────────────────────────────────────────────────

/// Confirms deletion and, when the category still holds products, offers to
/// move them first.
///
/// The database enforces `on delete restrict`, so without this the owner would
/// get an opaque foreign-key error. Here they get a clear explanation and a
/// way out.
Future<void> confirmCategoryDeletion(
  BuildContext context,
  WidgetRef ref, {
  required Category category,
  required int productCount,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context);

  if (productCount > 0) {
    final Object? choice = await showDialog<Object>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.adminConfirmDeleteCategory),
        content: Text(l10n.adminCategoryHasProducts(productCount)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('move'),
            child: Text(l10n.adminMoveProductsTo),
          ),
        ],
      ),
    );
    if (choice == 'move' && context.mounted) {
      await _moveProductsThenDelete(context, ref, category);
    }
    return;
  }

  final bool confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: Text(l10n.adminConfirmDeleteCategory),
          content: Text(l10n.adminConfirmDeleteMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: BrandColors.danger),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.actionDelete),
            ),
          ],
        ),
      ) ??
      false;

  if (!confirmed) return;

  try {
    await ref.read(categoryRepositoryProvider).delete(category.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminCategoryDeleted)),
      );
    }
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorUnknown)),
      );
    }
  }
}

/// Opens a target-category picker, reassigns every product, then deletes.
Future<void> _moveProductsThenDelete(
  BuildContext context,
  WidgetRef ref,
  Category source,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final List<Category> others = ref
          .read(allCategoriesProvider)
          .value
          ?.where((Category c) => c.id != source.id)
          .toList() ??
      const <Category>[];

  if (others.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.adminFilterAllCategories)),
    );
    return;
  }

  final Category? target = await showDialog<Category>(
    context: context,
    builder: (BuildContext dialogContext) => SimpleDialog(
      title: Text(l10n.adminMoveProductsTo),
      children: others
          .map(
            (Category c) => SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(c),
              child: Text(c.name),
            ),
          )
          .toList(),
    ),
  );
  if (target == null) return;

  try {
    final ProductRepository products = ref.read(productRepositoryProvider);
    final List<Product> toMove = await products.fetch(
      categoryId: source.id,
      onlyPublished: false,
    );

    for (final Product product in toMove) {
      await products.update(
        product.id,
        ProductDraft(
          categoryId: target.id,
          title: product.title,
          titleAm: product.titleAm,
          titleAr: product.titleAr,
          description: product.description,
          descriptionAm: product.descriptionAm,
          descriptionAr: product.descriptionAr,
          price: product.price,
          compareAtPrice: product.compareAtPrice,
          currencyCode: product.currencyCode,
          isAvailable: product.isAvailable,
          isFeatured: product.isFeatured,
          isPublished: product.isPublished,
          sortOrder: product.sortOrder,
        ),
      );
    }

    await ref.read(categoryRepositoryProvider).delete(source.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminCategoryDeleted)),
      );
    }
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorUnknown)),
      );
    }
  }
}

/// Picks a cover image, uploads it to the `brand` bucket and stores the path.
class _CoverPicker extends ConsumerWidget {
  const _CoverPicker({required this.coverPath, required this.onPicked});

  final String? coverPath;
  final ValueChanged<String?> onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Row(
      children: <Widget>[
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: BrandColors.gold.withValues(alpha: 0.12),
            border: Border.all(color: BrandColors.goldHairline),
          ),
          child: coverPath == null
              ? const Icon(Icons.image_outlined, color: BrandColors.gold)
              : const Icon(Icons.check_circle_outline, color: BrandColors.gold),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            coverPath ?? l10n.adminCoverImage,
            style: BrandTypography.bodySmall,
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            final XFile? picked = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              maxWidth: 1600,
            );
            if (picked == null) return;
            final Uint8List bytes = await picked.readAsBytes();
            final String path = StorageDataSource.brandPath(
              name: 'category',
              extension: Validators.slugify(picked.name.isEmpty
                  ? 'cover'
                  : picked.name),
            );
            await ref.read(storageDataSourceProvider).upload(
                  bucket: StorageDataSource.brandBucket,
                  path: path,
                  bytes: bytes,
                  contentType: 'image/${path.split('.').last}',
                );
            onPicked(path);
          },
          icon: const Icon(Icons.upload_rounded, size: 18),
          label: Text(l10n.actionSelectImage),
        ),
      ],
    );
  }
}
