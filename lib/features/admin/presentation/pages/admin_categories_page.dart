import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderables/reorderables.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_scaffold.dart';

class AdminCategoriesPage extends ConsumerStatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  ConsumerState<AdminCategoriesPage> createState() =>
      _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends ConsumerState<AdminCategoriesPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _slug = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Category>> async =
        ref.watch(adminCategoriesProvider);

    return AdminScaffold(
      title: l10n.adminCategories,
      selectedRoute: Routes.adminCategories,
      floatingActionButton: FloatingActionButton(
        backgroundColor: BrandColors.royalViolet,
        foregroundColor: BrandColors.ivory,
        child: const Icon(Icons.add, size: 28),
        onPressed: () => _showCreateSheet(context),
      ),
      child: async.when(
        loading: () => const _LoadingIndicator(),
        error: (Object error, _) => ErrorStateView(
          failure: error is AppFailure ? error : UnknownFailure(cause: error),
          onRetry: () => ref.invalidate(adminCategoriesProvider),
        ),
        data: (List<Category> cats) {
          if (cats.isEmpty) {
            return EmptyState(
              title: l10n.adminNoCategories,
              message: l10n.adminNoCategoriesPlaceholder,
              icon: Icons.category_outlined,
            );
          }
          return _CategoryGrid(categories: cats);
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    _name.clear();
    _slug.clear();
    _formKey.currentState?.reset();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CategoryEditorSheet(
        existing: null,
        nameController: _name,
        slugController: _slug,
        formKey: _formKey,
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return ReorderableListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      buildDefaultDragHandles: false,
      children: [
        for (final Category c in categories)
          _CategoryTile(category: c, onEdit: () => _showEditSheet(context, c)),
        _BuildPermissionButton(),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onEdit});

  final Category category;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: category.hasCover
            ? Image.asset(
                category.coverPath!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const CircleAvatar(child: Icon(Icons.category_outlined)),
              )
            : CircleAvatar(
                backgroundColor: BrandColors.royalViolet,
                child: const Icon(Icons.category_outlined, color: BrandColors.ivory),
              ),
        title: Text(category.nameFor(Localizations.localeOf(context).languageCode),
            style: BrandTypography.titleMedium),
        subtitle: Text(
          'slug: ${category.slug} · ${category.productCount} products',
          style: BrandTypography.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () => _toggleVisibility(context, category),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outlined),
              onPressed: () => _deleteCategory(context, category),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleVisibility(BuildContext context, Category c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.adminCategoryHidden),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(ref.read(categoryRepositoryProvider).watchAll()),
            child: Text(l10n.actionCancel),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(BuildContext context, Category c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.adminConfirmDeleteCategory),
        content: Text(l10n.adminConfirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(categoryRepositoryProvider).delete(c.id);
              if (mounted) Navigator.of(context).pop();
            },
            style: FilledButton.secondary,
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}

class _BuildPermissionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        'Build permission check — no external build step is configured.',
        style: BrandTypography.bodySmall.copyWith(color: Colors.grey),
      ),
    );
  }
}

class _CategoryEditorSheet extends ConsumerWidget {
  const _CategoryEditorSheet({
    required this.existing,
    required this.nameController,
    required this.slugController,
    required this.formKey,
  });

  final Category? existing;
  final TextEditingController nameController;
  final TextEditingController slugController;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CategoryEditorController controller =
        ref.watch(categoryEditorControllerProvider);

    return ConsumerBuilder(
      builder: (context, ref, child) {
        return Form(
          key: formKey,
          child: Padding(
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: l10n.adminCategoryName),
                    validator: (v) => Validators.categoryName(v).toString(),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: slugController,
                    decoration: InputDecoration(
                      labelText: l10n.adminCategoryName,
                      helperText: l10n.adminSlugAuto,
                    ),
                    validator: (v) => Validators.slug(v).toString(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.adminSlugAuto,
                    style: BrandTypography.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _save(context, ref, controller, nameController, slugController),
                    icon: const Icon(Icons.save_outlined),
                    label: Text(l10n.actionSave),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.actionCancel),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _save(BuildContext context, WidgetRef ref, CategoryEditorController controller, TextEditingController name, TextEditingController slug) async {
    if (!formKey.currentState!.validate()) return;
    final bool ok = await controller.save();
    if (ok && mounted) Navigator.of(context).pop();
  }
}
