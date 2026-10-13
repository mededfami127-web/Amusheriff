import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../contacts/domain/entities/contact_link.dart';
import '../../../contacts/presentation/providers/contact_providers.dart';
import '../widgets/admin_scaffold.dart';
import 'admin_contact_editor_sheet.dart';

/// Contact & social manager: reorder, add, edit, hide and mark a primary link,
/// with a live preview of the exact buttons customers will tap.
class AdminContactsPage extends ConsumerWidget {
  const AdminContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<ContactLink>> async =
        ref.watch(allContactLinksProvider);

    final Widget body = async.when<Widget>(
      loading: () => const _ContactSkeleton(),
      error: (Object error, StackTrace __) => ErrorStateView(
        failure: ErrorMapper.map(error),
        onRetry: () => ref.invalidate(allContactLinksProvider),
      ),
      data: (List<ContactLink> links) {
        if (links.isEmpty) {
          return EmptyState(
            title: l10n.adminNoContacts,
            message: l10n.adminAddContact,
            icon: Icons.share_outlined,
            action: TextButton.icon(
              onPressed: () => showContactEditorSheet(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.adminAddContact),
            ),
          );
        }
        return _ContactList(links: links);
      },
    );

    return AdminScaffold(
      title: l10n.adminContacts,
      selectedRoute: Routes.adminContacts,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: BrandColors.royalViolet,
        foregroundColor: BrandColors.ivory,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.adminAddContact),
        onPressed: () => showContactEditorSheet(context),
      ),
      child: body,
    );
  }
}

class _ContactList extends ConsumerWidget {
  const _ContactList({required this.links});

  final List<ContactLink> links;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: <Widget>[
        Text(l10n.adminLivePreview, style: BrandTypography.titleMedium),
        const SizedBox(height: 10),
        _CustomerPreview(links: links),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            Expanded(child: Text(l10n.adminContacts,
                style: BrandTypography.titleMedium)),
            Text(
              l10n.adminDragToReorder,
              style: BrandTypography.bodySmall.copyWith(
                color: BrandTypography.mutedOn(Theme.of(context).brightness),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: true,
          itemCount: links.length,
          onReorderItem: (int oldIndex, int newIndex) async {
            final List<ContactLink> moved = List<ContactLink>.from(links);
            final ContactLink item = moved.removeAt(oldIndex);
            moved.insert(newIndex, item);
            await ref.read(contactRepositoryProvider).reorder(
                  moved.map((ContactLink c) => c.id).toList(growable: false),
                );
          },
          itemBuilder: (BuildContext context, int index) {
            final ContactLink link = links[index];
            return Container(
              key: ValueKey<String>(link.id),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: dark ? BrandColors.plumSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: BrandColors.goldHairline),
              ),
              child: Row(
                children: <Widget>[
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color:
                            BrandTypography.mutedOn(Theme.of(context).brightness),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    link.kind.icon,
                    color: BrandColors.gold,
                  ),
                      title: Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              link.label,
                              overflow: TextOverflow.ellipsis,
                              style: BrandTypography.titleMedium,
                            ),
                          ),
                          if (link.isPrimary) ...<Widget>[
                            const SizedBox(width: 8),
                            _PrimaryBadge(label: l10n.adminPrimaryBadge),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        link.displayValue,
                        overflow: TextOverflow.ellipsis,
                        style: BrandTypography.bodySmall,
                      ),
                      onTap: () =>
                          showContactEditorSheet(context, existing: link),
                    ),
                  ),
                  IconButton(
                    tooltip:
                        link.isVisible ? l10n.adminHide : l10n.adminShow,
                    icon: Icon(
                      link.isVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: link.isVisible
                          ? BrandColors.gold
                          : BrandColors.danger,
                    ),
                    onPressed: () => ref
                        .read(contactRepositoryProvider)
                        .setVisibility(link.id, isVisible: !link.isVisible),
                  ),
                  IconButton(
                    tooltip: l10n.actionDelete,
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 20, color: BrandColors.danger),
                    onPressed: () => _confirmDelete(context, ref, link),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ContactLink link,
  ) async {    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool ok = await showDialog<bool>(
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
                    backgroundColor: BrandColors.danger),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.actionDelete),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await ref.read(contactRepositoryProvider).delete(link.id);
  }
}

/// Exactly the buttons the storefront renders, so what the owner sees here is
/// what the customer gets.
class _CustomerPreview extends StatelessWidget {
  const _CustomerPreview({required this.links});

  final List<ContactLink> links;

  @override
  Widget build(BuildContext context) {
    final List<ContactLink> visible =
        links.where((ContactLink l) => l.isVisible).toList(growable: false);
    if (visible.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: BrandGradients.brand,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: visible
            .map(
              (ContactLink link) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: BrandColors.gold.withValues(alpha: 0.7),
                  ),
                ),
                child: Text(
                  link.label,
                  style: BrandTypography.labelLarge
                      .copyWith(color: BrandColors.ivory),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _PrimaryBadge extends StatelessWidget {
  const _PrimaryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        gradient: BrandGradients.gold,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: BrandTypography.labelSmall
            .copyWith(color: BrandColors.charcoal, fontSize: 10),
      ),
    );
  }
}

class _ContactSkeleton extends StatelessWidget {
  const _ContactSkeleton();

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) => Container(
        height: 64,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: (dark ? BrandColors.plumSurface : Colors.grey.shade200)
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
