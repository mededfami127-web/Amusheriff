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

class AdminContactsPage extends ConsumerStatefulWidget {
  const AdminContactsPage({super.key});

  @override
  ConsumerState<AdminContactsPage> createState() =>
      _AdminContactsPageState();
}

class _AdminContactsPageState extends ConsumerState<AdminContactsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _label = TextEditingController();
  final TextEditingController _value = TextEditingController();

  @override
  void dispose() {
    _label.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<ContactLink>> async =
        ref.watch(adminContactsProvider);

    return AdminScaffold(
      title: l10n.adminContacts,
      selectedRoute: Routes.adminContacts,
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
          onRetry: () => ref.invalidate(adminContactsProvider),
        ),
        data: (List<ContactLink> links) {
          if (links.isEmpty) {
            return EmptyState(
              title: l10n.adminNoContacts,
              message: l10n.adminNoContactsPlaceholder,
              icon: Icons.share_outlined,
            );
          }
          return _LinkGrid(links);
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    _label.clear();
    _value.clear();
    _formKey.currentState?.reset();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ContactsEditorSheet(
        existing: null,
        labelController: _label,
        valueController: _value,
        formKey: _formKey,
      ),
    );
  }
}

class _LinkGrid extends StatelessWidget {
  const _LinkGrid(this.links);

  final List<ContactLink> links;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      buildDefaultDragHandles: true,
      children: [
        for (final ContactLink link in links)
          _LinkTile(
            link: link,
            onEdit: () => _showEditSheet(context, link),
            onDelete: () => _deleteLink(context, link),
          ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.link,
    required this.onEdit,
    required this.onDelete,
  });

  final ContactLink link;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: link.isPrimary
              ? BrandColors.gold
              : BrandColors.royalViolet,
          child: Icon(
            link.kind.icon,
            color: link.isPrimary ? BrandColors.deepPlum : BrandColors.ivory,
          ),
        ),
        title: Text(link.label, style: BrandTypography.titleMedium),
        subtitle: Text(
          link.kind.name.toUpperCase() + ' · ' + link.value,
          style: BrandTypography.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: link.isPrimary,
              onChanged: (v) =>
                  ref.read(contactRepositoryProvider).setPrimary(link.id, isPrimary: v!),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outlined),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

void _deleteLink(BuildContext context, ContactLink link) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Remove link?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await ref.read(contactRepositoryProvider).delete(link.id);
            Navigator.of(context).pop();
          },
          style: FilledButton.secondary,
          child: Text('Remove'),
        ),
      ],
    ),
  );
}

void _showEditSheet(BuildContext context, ContactLink link) {
  final form = GlobalKey<FormState>();
  final l = TextEditingController(text: link.label);
  final v = TextEditingController(text: link.value);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => Consumer(
      builder: (c, r, _) {
        return Form(
          key: form,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(c).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Edit link'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: l,
                    decoration: InputDecoration(labelText: 'Label'),
                    validator: (x) =>
                        Validators.required(x)?.toString(),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: v,
                    decoration: InputDecoration(labelText: 'Value'),
                    validator: (x) =>
                        validateContactValue(link.kind, x)?.toString(),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ContactKind>(
                    value: link.kind,
                    items: ContactKind.values
                        .map((k) => DropdownMenuItem(
                              value: k,
                              child: Text(k.name),
                            ))
                        .toList(),
                    onChanged: (k) {
                      if (k != null) {
                        l.text = '';
                        form.currentState!.validate();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      if (!form.currentState!.validate()) return;
                      ref
                          .read(contactRepositoryProvider)
                          .update(link.id, ContactLinkDraft(
                                kind: link.kind,
                                label: l.text.trim(),
                                value: v.text.trim(),
                              ))
                          .then((_) {
                            if (context.mounted) Navigator.of(context).pop();
                          });
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: Text('Save'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

void _showCreateSheet(BuildContext context) {
  final form = GlobalKey<FormState>();
  final l = TextEditingController();
  final v = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => Consumer(
      builder: (c, r, _) {
        return Form(
          key: form,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(c).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add link'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: l,
                    decoration: InputDecoration(labelText: 'Label'),
                    validator: (x) =>
                        Validators.required(x)?.toString(),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: v,
                    decoration: InputDecoration(labelText: 'Value'),
                    validator: (x) =>
                        validateContactValue(ContactKind.whatsapp, x)?.toString(),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ContactKind>(
                    items: ContactKind.values
                        .map((k) => DropdownMenuItem(
                              value: k,
                              child: Text(k.name),
                            ))
                        .toList(),
                    onChanged: (k) {
                      if (k != null) {
                        l.text = '';
                        form.currentState!.validate();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      if (!form.currentState!.validate()) return;
                      ref
                          .read(contactRepositoryProvider)
                          .create(ContactLinkDraft(
                                kind: ContactKind.whatsapp,
                                label: l.text.trim(),
                                value: v.text.trim(),
                              ))
                          .then((_) {
                            if (context.mounted) Navigator.of(context).pop();
                          });
                    },
                    icon: const Icon(Icons.add),
                    label: Text('Add'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
