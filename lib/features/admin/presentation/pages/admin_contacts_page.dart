import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../contacts/domain/entities/contact_link.dart';
import '../../../contacts/presentation/providers/contact_providers.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_scaffold.dart';
import 'admin_contact_editor_sheet.dart';

/// Contact channels: the ways a customer reaches the owner.
///
/// Order is the storefront order, so the list is reorderable and persisted in
/// one `reorder` round trip. Exactly one link should be primary — the
/// repository clears the old flag when a new primary is set.
class AdminContactsPage extends ConsumerWidget {
  const AdminContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<ContactLink>> async = ref.watch(
      allContactLinksProvider,
    );

    return AdminScaffold(
      title: l10n.adminContacts,
      selectedRoute: Routes.adminContacts,
      floatingActionButton: FloatingActionButton(
        backgroundColor: BrandColors.royalViolet,
        foregroundColor: BrandColors.ivory,
        tooltip: l10n.adminAddContact,
        onPressed: () => _openSheet(context, ref, null),
        child: const Icon(Icons.add, size: 28),
      ),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorStateView(
          failure: ErrorMapper.map(error),
          onRetry: () => ref.invalidate(allContactLinksProvider),
        ),
        data: (List<ContactLink> links) {
          if (links.isEmpty) {
            return EmptyState(
              title: l10n.adminContacts,
              message: l10n.adminNoContacts,
              icon: Icons.share_outlined,
              action: FilledButton.icon(
                onPressed: () => _openSheet(context, ref, null),
                icon: const Icon(Icons.add),
                label: Text(l10n.adminAddContact),
              ),
            );
          }
          return _ContactList(
            links: links,
            onEditRequested: (ContactLink link) =>
                _openSheet(context, ref, link),
          );
        },
      ),
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref, ContactLink? existing) {
    final ContactsEditorController controller = ref.read(
      contactsEditorControllerProvider.notifier,
    );
    if (existing == null) {
      controller.startNew();
    } else {
      controller.startEdit(existing);
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ContactsEditorSheet(existing: existing),
    );
  }
}

class _ContactList extends ConsumerWidget {
  const _ContactList({required this.links, required this.onEditRequested});

  final List<ContactLink> links;
  final ValueChanged<ContactLink> onEditRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      onReorderItem: (int oldIndex, int newIndex) {
        final List<ContactLink> ordered = <ContactLink>[...links];
        final ContactLink moved = ordered.removeAt(oldIndex);
        ordered.insert(newIndex, moved);
        ref
            .read(contactRepositoryProvider)
            .reorder(
              ordered.map((ContactLink l) => l.id).toList(growable: false),
            );
      },
      children: <Widget>[
        for (final ContactLink link in links)
          _ContactTile(
            key: ValueKey<String>(link.id),
            link: link,
            onEdit: () => onEditRequested(link),
          ),
      ],
    );
  }
}

class _ContactTile extends ConsumerWidget {
  const _ContactTile({super.key, required this.link, required this.onEdit});

  final ContactLink link;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool hidden = !link.isVisible;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: link.isPrimary
              ? BrandColors.gold
              : BrandColors.royalViolet,
          child: Icon(
            link.kind.icon,
            color: link.isPrimary ? BrandColors.deepPlum : BrandColors.ivory,
          ),
        ),
        title: Row(
          children: <Widget>[
            Flexible(
              child: Text(
                link.label,
                style: BrandTypography.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (link.isPrimary) ...<Widget>[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: BrandColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.adminPrimaryBadge,
                  style: BrandTypography.labelSmall,
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${link.kind.name} · ${link.displayValue}',
          style: BrandTypography.bodySmall.copyWith(
            color: hidden ? BrandColors.warning : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(
                hidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              tooltip: hidden ? l10n.adminShow : l10n.adminHide,
              onPressed: () => ref
                  .read(contactRepositoryProvider)
                  .setVisibility(link.id, isVisible: hidden),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.actionEdit,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: l10n.actionDelete,
              onPressed: () => _confirmDelete(context, ref, l10n),
            ),
          ],
        ),
        onTap: () => ref
            .read(contactRepositoryProvider)
            .setPrimary(link.id, isPrimary: !link.isPrimary),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: Text(l10n.adminConfirmDeleteContact),
            content: Text(l10n.adminConfirmDeleteMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: BrandColors.danger,
                  foregroundColor: BrandColors.ivory,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.actionDelete),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(contactRepositoryProvider).delete(link.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminContactDeleted)));
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizeFailure(l10n, ErrorMapper.map(error)))),
      );
    }
  }
}
