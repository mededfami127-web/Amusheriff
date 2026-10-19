import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../settings/presentation/providers/site_content_providers.dart';
import '../controllers/site_content_editor_controller.dart';
import '../pages/admin_site_content_editor_sheet.dart';
import '../widgets/admin_scaffold.dart';

/// Every live-editable home string, per locale.
///
/// The owner picks a locale, sees the keys the storefront reads, and each key
/// opens a sheet that saves one row to `public.site_content`. Because the home
/// screen reads that table live, the new wording appears immediately.
class AdminSiteContentEditorPage extends ConsumerWidget {
  const AdminSiteContentEditorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = ref.watch(siteContentEditorLocaleProvider);
    final Map<String, String> values =
        ref.watch(siteContentProvider(locale)).value ??
        const <String, String>{};
    final Set<String> keys = ref.watch(siteContentKeysProvider(locale));

    final List<String> allKeys = kSiteContentKeys.toList()
      ..sort((String a, String b) => a.compareTo(b));

    final List<SiteContentViewRow> rows = <SiteContentViewRow>[];
    for (final String key in allKeys) {
      final String current = values[key] ?? '';
      rows.add(
        SiteContentViewRow(
          textKey: key,
          locale: locale,
          current: current,
          isOverride: keys.contains(key),
          onEdit: () => _openSheet(context, ref, key, locale, current),
        ),
      );
    }

    if (rows.isEmpty) {
      return AdminScaffold(
        title: l10n.adminSiteContent,
        selectedRoute: Routes.adminSiteContent,
        child: EmptyState(
          title: l10n.adminSiteContent,
          message: l10n.adminSiteContentHint,
          icon: Icons.article_outlined,
        ),
      );
    }

    return AdminScaffold(
      title: l10n.adminSiteContent,
      selectedRoute: Routes.adminSiteContent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final String code in kAppTextLocales)
                  ChoiceChip(
                    label: Text(kAppTextLocaleNames[code] ?? code),
                    selected: code == locale,
                    onSelected: (_) => ref
                        .read(siteContentEditorLocaleProvider.notifier)
                        .set(code),
                  ),
                Chip(
                  label: Text('${keys.length} edited'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          ...rows,
        ],
      ),
    );
  }

  Future<void> _openSheet(
    BuildContext context,
    WidgetRef ref,
    String key,
    String locale,
    String current,
  ) async {
    ref
        .read(siteContentEditorControllerProvider.notifier)
        .load(key, locale, current);
    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AdminSiteContentEditorSheet(
        textKey: key,
        locale: locale,
        initialValue: current,
      ),
    );
    if (saved == true && context.mounted) {
      ref.invalidate(siteContentProvider(locale));
      ref.invalidate(siteContentKeysProvider(locale));
    }
  }
}

class SiteContentViewRow extends ConsumerWidget {
  const SiteContentViewRow({
    super.key,
    required this.textKey,
    required this.locale,
    required this.current,
    required this.isOverride,
    required this.onEdit,
  });

  final String textKey;
  final String locale;
  final String current;
  final bool isOverride;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        textKey,
                        style: BrandTypography.labelSmall.copyWith(
                          color: BrandColors.gold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        current.isEmpty ? l10n.adminSiteContentValue : current,
                        style: BrandTypography.bodyMedium.copyWith(
                          color: dark
                              ? BrandColors.ivory
                              : BrandColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOverride)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      color: BrandColors.gold,
                      size: 20,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.actionEdit,
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The keys the storefront home reads from `public.site_content`.
const List<String> kSiteContentKeys = <String>[
  'heroTitle',
  'heroTagline',
  'heroButtonLabel',
  'sectionTitle:browseCategories',
  'sectionTitle:featured',
  'sectionTitle:allProducts',
];
