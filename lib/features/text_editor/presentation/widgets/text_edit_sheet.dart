import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/l10n/text_catalog.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/inline_failure_banner.dart';
import '../providers/text_editor_providers.dart';

/// Opens the editing sheet for one string.
///
/// [locale] defaults to whatever language the editor is pointed at; the live
/// pencils pass the app's current language so the owner rewrites what they are
/// looking at.
Future<void> showTextEditSheet(
  BuildContext context, {
  required String textKey,
  String? locale,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? BrandColors.deepPlum
        : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) =>
        _TextEditSheet(textKey: textKey, initialLocale: locale),
  );
}

class _TextEditSheet extends ConsumerStatefulWidget {
  const _TextEditSheet({required this.textKey, this.initialLocale});

  final String textKey;
  final String? initialLocale;

  @override
  ConsumerState<_TextEditSheet> createState() => _TextEditSheetState();
}

class _TextEditSheetState extends ConsumerState<_TextEditSheet> {
  late String _locale;
  late final TextEditingController _controller;

  AppTextEntry? get _entry => kAppTextByKey[widget.textKey];

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale ?? ref.read(textEditorLocaleProvider);
    if (!kAppTextLocales.contains(_locale)) _locale = kAppTextLocales.first;
    _controller = TextEditingController(text: _currentText());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The override if there is one, otherwise the shipped wording.
  String _currentText() {
    final AppTextEntry? entry = _entry;
    if (entry == null) return widget.textKey;
    final Map<String, String> overrides =
        ref.read(textOverridesProvider(_locale)).value ??
        const <String, String>{};
    return overrides[widget.textKey] ?? entry.defaultFor(_locale);
  }

  bool _isOverridden(String locale) =>
      (ref.read(textOverridesProvider(locale)).value ??
              const <String, String>{})
          .containsKey(widget.textKey);

  void _switchLocale(String locale) {
    setState(() {
      _locale = locale;
      _controller.text = _currentText();
    });
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool ok = await ref
        .read(textEditorControllerProvider.notifier)
        .save(
          textKey: widget.textKey,
          locale: _locale,
          value: _controller.text,
        );

    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminTextEditorSaved)),
      );
    }
  }

  Future<void> _restore() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool ok = await ref
        .read(textEditorControllerProvider.notifier)
        .restore(textKey: widget.textKey, locale: _locale);

    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminTextEditorResetDone)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppTextEntry? entry = _entry;
    final TextEditorStatus status = ref.watch(textEditorControllerProvider);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.edit_outlined,
                  color: BrandColors.gold,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.actionEdit,
                    style: BrandTypography.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n.actionClose,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              entry == null ? widget.textKey : l10n.adminTextEditor,
              style: BrandTypography.bodySmall,
            ),
            // A refused write used to pop nothing and say nothing, which read
            // exactly like a dead Save button. The typed failure now sits in
            // the sheet, above the field it belongs to.
            if (status.failure != null) ...<Widget>[
              const SizedBox(height: 12),
              InlineFailureBanner(
                failure: status.failure!,
                showDetails: true,
                onDismiss: ref
                    .read(textEditorControllerProvider.notifier)
                    .acknowledge,
              ),
            ],
            const SizedBox(height: 14),

            // Every language is reachable from here, so one sheet can rewrite
            // the same word in English, Amharic, Arabic and Oromo.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (final String code in kAppTextLocales) ...<Widget>[
                    ChoiceChip(
                      label: Text(
                        '${kAppTextLocaleNames[code] ?? code}'
                        '${_isOverridden(code) ? ' •' : ''}',
                      ),
                      selected: code == _locale,
                      onSelected: (_) => _switchLocale(code),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              minLines: 2,
              maxLines: 6,
              autofocus: false,
              textInputAction: TextInputAction.newline,
              style: BrandTypography.bodyMedium.copyWith(
                color: dark ? BrandColors.ivory : BrandColors.charcoal,
              ),
              decoration: InputDecoration(
                labelText: l10n.adminTextEditor,
                border: const OutlineInputBorder(),
                hintText: entry?.defaultFor(_locale),
              ),
            ),

            if (entry != null && entry.hasPlaceholders) ...<Widget>[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BrandColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BrandColors.goldHairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.adminTextEditorPlaceholderHint,
                      style: BrandTypography.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: <Widget>[
                        for (final String name in entry.placeholders)
                          Chip(
                            label: Text('{$name}'),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            if (status.failure != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                status.failure is ValidationFailure
                    ? l10n.validateRequired
                    : l10n.errorServer,
                style: BrandTypography.bodySmall.copyWith(
                  color: BrandColors.danger,
                ),
              ),
            ],

            const SizedBox(height: 18),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: BrandColors.royalViolet,
                foregroundColor: BrandColors.ivory,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: status.saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.actionSave),
              onPressed: status.saving ? null : _save,
            ),
            if (_isOverridden(_locale)) ...<Widget>[
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.restart_alt_rounded),
                label: Text(l10n.adminTextEditorReset),
                onPressed: status.saving ? null : _restore,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
