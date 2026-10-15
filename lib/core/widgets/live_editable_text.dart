import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/text_editor/presentation/providers/text_editor_providers.dart';
import '../../features/text_editor/presentation/widgets/text_edit_sheet.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/text_catalog.dart';
import '../theme/brand_colors.dart';

/// A text that the owner can rewrite in place.
///
/// Renders exactly like a plain [Text] until live edit mode is switched on, at
/// which point a small gold pencil appears **above** the words. Tapping it opens
/// the editing sheet for that ARB key, and the change lands on every screen the
/// moment it is saved.
///
/// Call sites pass the already-localised [text] so nothing renders differently
/// in normal use; [textKey] is what makes it editable.
class LiveEditableText extends ConsumerWidget {
  const LiveEditableText({
    super.key,
    required this.textKey,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.dark = false,
    this.dense = false,
  });

  /// ARB key behind [text].
  final String textKey;

  /// The string as it should render right now.
  final String text;

  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  /// Light-on-dark surfaces need the pencil to stay legible.
  final bool dark;

  /// Tighter pencil for list rows and chips.
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget label = Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );

    if (!ref.watch(liveEditModeProvider)) return label;
    if (!kAppTextByKey.containsKey(textKey)) return label;

    final AppLocalizations l10n = AppLocalizations.of(context);
    final double size = dense ? 15 : 18;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          button: true,
          label: '${l10n.actionEdit}: $text',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => showTextEditSheet(
              context,
              textKey: textKey,
              locale: Localizations.localeOf(context).languageCode,
            ),
            child: Padding(
              padding: EdgeInsets.all(dense ? 1 : 2),
              child: Icon(
                Icons.edit_outlined,
                size: size,
                color: dark ? BrandColors.goldLight : BrandColors.gold,
              ),
            ),
          ),
        ),
        label,
      ],
    );
  }
}
