import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/launcher.dart';
import '../../../../core/utils/phone_numbers.dart';
import '../../../contacts/domain/entities/contact_settings.dart';
import '../../../contacts/presentation/providers/contact_settings_providers.dart';

/// The one Call button every product surface uses.
///
/// The number is never a widget constant: it is the global owner phone from
/// `admin_contact_settings`, so the owner changes it once in the admin panel and
/// every card, image and product page dials the new number without an app
/// release. A blank setting falls back to [PhoneNumbers.defaultOwnerPhone], so a
/// fresh install with an empty row still has a working button.
///
/// The `tel:` URI carries the international form (`tel:+251917928950`) because
/// Android needs the country code to dial a saved contact correctly; the label
/// still shows the local form the shop publishes (`0917928950`).
class CallButton extends ConsumerWidget {
  const CallButton({super.key, this.dense = false, this.label});

  /// Compact form for a grid card: one gold line, no button chrome.
  final bool dense;

  /// Replaces the default "Call · 0917928950" label.
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ContactSettings settings = ref.watch(contactSettingsValueProvider);
    final String dialNumber = settings.callPhone;
    final Uri uri = settings.callUri;
    // A card has ~130dp of usable width, so its line is the bare number; the
    // full panel form spells out "Call · number".
    final String text =
        label ??
        (dense
            ? PhoneNumbers.display(dialNumber)
            : '${l10n.actionCall} · ${PhoneNumbers.display(dialNumber)}');

    Future<void> dial() async {
      final bool opened = await ref.read(linkLauncherProvider).openTel(uri);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.contactLaunchFailed)));
      }
    }

    if (dense) {
      return Semantics(
        button: true,
        label: l10n.actionCallNow,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: dial,
            borderRadius: BorderRadius.circular(999),
            // A minimum rather than a fixed height: at a 2.0 accessibility
            // scale the label is twice as tall and must not be clipped.
            child: Container(
              constraints: const BoxConstraints(minHeight: 34),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: BrandColors.gold),
                color: BrandColors.gold.withValues(alpha: 0.10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.call_rounded,
                    size: 14,
                    color: BrandColors.gold,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BrandTypography.labelSmall.copyWith(
                        color: BrandColors.gold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: l10n.actionCallNow,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: dial,
          style: FilledButton.styleFrom(
            backgroundColor: BrandColors.gold,
            foregroundColor: BrandColors.charcoal,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.call_rounded, size: 22),
          label: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BrandTypography.labelLarge.copyWith(
              color: BrandColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
