import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/l10n/text_catalog.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/inline_failure_banner.dart';
import '../../../admin/presentation/widgets/admin_scaffold.dart';
import '../providers/text_editor_providers.dart';
import '../widgets/text_edit_sheet.dart';

/// Every word of the app, per screen and per language.
///
/// This is the section the brief asks for: the owner picks a language, sees the
/// screens listed with their texts, and each text carries a working edit icon.
/// Saving writes one row to `public.text_overrides`, and because the whole app
/// reads its strings through the override-aware `AppLocalizations`, the new
/// wording appears on the dashboard and every other screen immediately.
class AdminTextEditorPage extends ConsumerWidget {
  const AdminTextEditorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = ref.watch(textEditorLocaleProvider);
    final TextEditorStatus status = ref.watch(textEditorControllerProvider);
    final List<AppTextEntry> entries = ref.watch(filteredTextEntriesProvider);
    final Map<String, String> overrides =
        ref.watch(textOverridesProvider(locale)).value ?? const <String, String>{};

    return AdminScaffold(
      title: l10n.adminTextEditor,
      selectedRoute: Routes.adminTextEditor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: <Widget>[
          if (status.failure != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InlineFailureBanner(
                failure: status.failure!,
                onDismiss: ref.read(textEditorControllerProvider.notifier).acknowledge,
              ),
            ),
          _Intro(l10n: l10n, locale: locale, edits: overrides.length),
          const SizedBox(height: 14),
          const _LiveEditToggle(),
          const SizedBox(height: 14),
          _SearchField(l10n: l10n),
          const SizedBox(height: 12),
          const _SectionChips(),
          const SizedBox(height: 8),
          _LanguagePicker(l10n: l10n, locale: locale),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                l10n.adminTextEditorNoResults,
                textAlign: TextAlign.center,
                style: BrandTypography.bodySmall,
              ),
            )
          else
            ..._grouped(entries, overrides, locale),
        ],
      ),
    );
  }

  /// Groups the visible entries under their screen heading, preserving the
  /// catalogue order so the dashboard really is the first screen listed.
  List<Widget> _grouped(
    List<AppTextEntry> entries,
    Map<String, String> overrides,
    String locale,
  ) {
    final List<Widget> widgets = <Widget>[];
    String? currentSection;
    for (final AppTextEntry entry in entries) {
      if (entry.sectionKey != currentSection) {
        currentSection = entry.sectionKey;
        widgets.add(_SectionHeading(sectionKey: entry.sectionKey));
      }
      widgets.add(
        _TextRow(
          entry: entry,
          locale: locale,
          value: overrides[entry.key] ?? entry.defaultFor(locale),
          isOverride: overrides.containsKey(entry.key),
        ),
      );
    }
    return widgets;
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.l10n, required this.locale, required this.edits});

  final AppLocalizations l10n;
  final String locale;
  final int edits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
        color: BrandColors.gold.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.adminTextEditorHint, style: BrandTypography.bodySmall),
          const SizedBox(height: 8),
          Text(
            '${kAppTextLocaleNames[locale] ?? locale} · '
            '${kAppTextEntries.length} · $edits ✓',
            style: BrandTypography.labelSmall.copyWith(color: BrandColors.gold),
          ),
        ],
      ),
    );
  }
}

class _LiveEditToggle extends ConsumerWidget {
  const _LiveEditToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool enabled = ref.watch(liveEditModeProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: SwitchListTile(
        value: enabled,
        onChanged: (_) => ref.read(liveEditModeProvider.notifier).toggle(),
        secondary: Icon(
          Icons.edit_note_rounded,
          color: enabled ? BrandColors.gold : BrandColors.goldHairline,
        ),
        title: Text(l10n.adminLiveEdit, style: BrandTypography.titleMedium),
        subtitle: Text(
          enabled ? l10n.adminLiveEditOn : l10n.adminLiveEditOff,
          style: BrandTypography.bodySmall,
        ),
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  const _SearchField({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: ref.read(textEditorQueryProvider.notifier).update,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: l10n.adminTextEditorSearch,
        prefixIcon: const Icon(Icons.search_rounded),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _SectionChips extends ConsumerWidget {
  const _SectionChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> sections = ref.watch(textEditorSectionsProvider);
    final String? selected = ref.watch(textEditorSectionProvider);
    final Map<String, String> byKey = <String, String>{
      for (final AppTextEntry entry in kAppTextEntries)
        entry.sectionKey: entry.key,
    };

    // 48 rather than 44: a ChoiceChip still fits at the largest text scale the
    // app allows, so this row can never overflow.
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(l10n.adminTextEditorAllScreens),
              selected: selected == null,
              onSelected: (_) =>
                  ref.read(textEditorSectionProvider.notifier).select(null),
            ),
          ),
          for (final String section in sections)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  // The screen name is itself an editable string, so the
                  // heading follows the language being edited.
                  _sectionLabel(l10n, byKey[section] ?? section),
                ),
                selected: selected == section,
                onSelected: (_) =>
                    ref.read(textEditorSectionProvider.notifier).select(section),
              ),
            ),
        ],
      ),
    );
  }

  static String _sectionLabel(AppLocalizations l10n, String key) =>
      switch (key) {
        'groupCommon' => l10n.groupCommon,
        'groupErrors' => l10n.groupErrors,
        'groupStorefront' => l10n.groupStorefront,
        'groupValidation' => l10n.groupValidation,
        _ => _byKey(l10n, key),
      };

  /// The same switch the rest of the app uses for section titles, so each screen
  /// heading reads naturally in the active language.
  static String _byKey(AppLocalizations l10n, String key) => switch (key) {
        'adminDashboard' => l10n.adminDashboard,
        'adminProducts' => l10n.adminProducts,
        'adminCategories' => l10n.adminCategories,
        'adminContacts' => l10n.adminContacts,
        'adminInquiries' => l10n.adminInquiries,
        'adminSiteSettings' => l10n.adminSiteSettings,
        'adminAccount' => l10n.adminAccount,
        'adminTextEditor' => l10n.adminTextEditor,
        'gateTitle' => l10n.gateTitle,
        'settingsTitle' => l10n.settingsTitle,
        _ => l10n.groupCommon,
      };
}

class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditorController controller =
        ref.read(textEditorControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.settingsLanguage, style: BrandTypography.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final String code in kAppTextLocales)
              ChoiceChip(
                label: Text(kAppTextLocaleNames[code] ?? code),
                selected: code == locale,
                onSelected: (_) {
                  ref.read(textEditorLocaleProvider.notifier).select(code);
                  // A fresh language means the previous save's banner is stale.
                  controller.acknowledge();
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.sectionKey});

  final String sectionKey;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 26, 4, 8),
      child: Row(
        children: <Widget>[
          const Icon(Icons.smartphone_rounded, size: 18, color: BrandColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _SectionChips._sectionLabel(l10n, sectionKey),
              style: BrandTypography.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// One string: an edit icon **above** the words, the words themselves, and the
/// key plus its variables underneath.
class _TextRow extends ConsumerWidget {
  const _TextRow({
    required this.entry,
    required this.locale,
    required this.value,
    required this.isOverride,
  });

  final AppTextEntry entry;
  final String locale;
  final String value;
  final bool isOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    void open() => showTextEditSheet(context, textKey: entry.key, locale: locale);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
      decoration: BoxDecoration(
        color: dark ? BrandColors.deepPlum : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverride ? BrandColors.gold : BrandColors.goldHairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // The editing icon, above the text it edits.
              IconButton(
                onPressed: entry.isEditable ? open : null,
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: BrandColors.gold,
                tooltip: l10n.actionEdit,
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  entry.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BrandTypography.labelSmall.copyWith(
                    color: BrandColors.gold,
                  ),
                ),
              ),
              if (entry.hasPlaceholders)
                Tooltip(
                  message: l10n.adminTextEditorHasVariables,
                  child: const Icon(
                    Icons.data_object_rounded,
                    size: 16,
                    color: BrandColors.goldLight,
                  ),
                ),
              if (isOverride)
                IconButton(
                  onPressed: () => ref
                      .read(textEditorControllerProvider.notifier)
                      .restore(textKey: entry.key, locale: locale),
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  tooltip: l10n.adminTextEditorReset,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 6),
            child: Text(
              entry.isPlural ? entry.defaultFor(locale) : value,
              style: BrandTypography.bodyMedium.copyWith(
                color: dark ? BrandColors.ivory : BrandColors.charcoal,
                fontStyle: entry.isPlural ? FontStyle.italic : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
