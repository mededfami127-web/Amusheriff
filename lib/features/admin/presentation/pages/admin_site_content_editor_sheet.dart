import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/inline_failure_banner.dart';
import '../controllers/site_content_editor_controller.dart';

/// Edit one site_content key for one locale.
///
/// The sheet pops with `true` once the save lands, so the editor page can say
/// "saved" instead of guessing.
class AdminSiteContentEditorSheet extends ConsumerStatefulWidget {
  const AdminSiteContentEditorSheet({
    super.key,
    required this.textKey,
    required this.locale,
    this.initialValue,
  });

  final String textKey;
  final String locale;
  final String? initialValue;

  @override
  ConsumerState<AdminSiteContentEditorSheet> createState() =>
      _AdminSiteContentEditorSheetState();
}

class _AdminSiteContentEditorSheetState
    extends ConsumerState<AdminSiteContentEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SiteContentEditorState state = ref.watch(
      siteContentEditorControllerProvider,
    );
    final SiteContentEditorController controller = ref.read(
      siteContentEditorControllerProvider.notifier,
    );
    final bool saving = state.status.saving;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
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
              widget.textKey,
              style: BrandTypography.bodySmall.copyWith(
                color: BrandColors.gold,
              ),
            ),
            const SizedBox(height: 14),
            if (state.status.failure != null)
              InlineFailureBanner(
                failure: state.status.failure!,
                onDismiss: controller.acknowledge,
              ),
            const SizedBox(height: 14),
            _LocaleChips(l10n: l10n, locale: state.locale),
            const SizedBox(height: 16),
            TextField(
              // Mirror the draft when it is seeded for another locale, without
              // rebuilding the controller (and resetting the caret) per key.
              controller: _syncController(state.value),
              minLines: 3,
              maxLines: 8,
              textInputAction: TextInputAction.newline,
              style: BrandTypography.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? BrandColors.ivory
                    : BrandColors.charcoal,
              ),
              decoration: InputDecoration(
                labelText: l10n.adminSiteContentValue,
                border: const OutlineInputBorder(),
              ),
              onChanged: controller.setValue,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: BrandColors.royalViolet,
                foregroundColor: BrandColors.ivory,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.actionSave),
              onPressed: saving ? null : () => _save(context, ref, l10n),
            ),
            if (widget.initialValue != null)
              TextButton.icon(
                icon: const Icon(Icons.restart_alt_rounded),
                label: Text(l10n.adminTextEditorReset),
                onPressed: saving ? null : () => _restore(context, ref, l10n),
              ),
          ],
        ),
      ),
    );
  }

  /// Keeps the field in step with the draft without replacing the controller.
  TextEditingController _syncController(String value) {
    if (_controller.text != value) {
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    return _controller;
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final bool ok = await ref
        .read(siteContentEditorControllerProvider.notifier)
        .save();
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.adminTextEditorSaved)));
    }
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final bool ok = await ref
        .read(siteContentEditorControllerProvider.notifier)
        .restore();
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.adminTextEditorResetDone)));
    }
  }
}

class _LocaleChips extends ConsumerWidget {
  const _LocaleChips({required this.l10n, required this.locale});

  final AppLocalizations l10n;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SiteContentEditorController controller = ref.read(
      siteContentEditorControllerProvider.notifier,
    );
    final SiteContentEditorState state = ref.watch(
      siteContentEditorControllerProvider,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final String code in kAppTextLocales)
          ChoiceChip(
            label: Text(
              '${kAppTextLocaleNames[code] ?? code}'
              '${code == state.locale ? ' •' : ''}',
            ),
            selected: code == state.locale,
            onSelected: (_) => controller.setLocale(code),
          ),
      ],
    );
  }
}

const Map<String, String> kAppTextLocaleNames = <String, String>{
  'en': 'English',
  'am': 'አማርኛ',
  'ar': 'عربي',
  'om': 'Oromoo',
};
