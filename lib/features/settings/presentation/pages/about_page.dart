import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/gold_divider.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../contacts/domain/entities/contact_kind.dart';
import '../../../contacts/domain/entities/contact_link.dart';
import '../../../contacts/presentation/providers/contact_providers.dart';
import '../../domain/entities/site_settings.dart';
import '../providers/site_settings_providers.dart';

/// Brand story plus every live contact channel.
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final SiteSettings settings = ref.watch(siteSettingsValueProvider);
    final List<ContactLink> links = ref.watch(orderChannelsProvider);

    return AppScaffold(
      showLockup: false,
      title: l10n.settingsAbout,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: <Widget>[
          Center(
            child: Image.asset(
              'assets/brand/logo.png',
              width: 132,
              height: 132,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              settings.storeNameEn,
              textAlign: TextAlign.center,
              style: BrandTypography.brandTitle.copyWith(
                color: dark ? BrandColors.goldLight : BrandColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              settings.storeNameAm,
              textAlign: TextAlign.center,
              style: BrandTypography.bodyForLocale(
                const Locale('am'),
                base: BrandTypography.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              settings.storeNameAr,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: BrandTypography.bodyForLocale(
                const Locale('ar'),
                base: BrandTypography.bodyMedium,
              ).copyWith(color: BrandColors.gold),
            ),
          ),
          const SizedBox(height: 22),
          const GoldDivider(withOrnament: true),
          const SizedBox(height: 20),
          Text(
            settings.hasAbout ? settings.about! : l10n.aboutFallback,
            textAlign: TextAlign.center,
            style: BrandTypography.bodyLarge.copyWith(
              color: dark
                  ? BrandColors.ivory.withValues(alpha: 0.88)
                  : BrandColors.charcoal.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 30),
          if (links.isNotEmpty) ...<Widget>[
            Text(
              l10n.actionContactOwner,
              style:
                  BrandTypography.displayForLocale(
                    Localizations.localeOf(context),
                    base: BrandTypography.displaySmall,
                  ).copyWith(
                    color: dark ? BrandColors.goldLight : BrandColors.charcoal,
                  ),
            ),
            const SizedBox(height: 14),
            ...links.map(
              (ContactLink link) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ContactTile(link: link),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactTile extends ConsumerWidget {
  const _ContactTile({required this.link});

  final ContactLink link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final bool isChat =
        link.kind == ContactKind.whatsapp || link.kind == ContactKind.telegram;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrandColors.goldHairline),
        color: dark ? BrandColors.plumSurface : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isChat ? BrandGradients.brand : BrandGradients.gold,
            ),
            child: Icon(link.kind.icon, size: 20, color: BrandColors.ivory),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(link.label, style: BrandTypography.titleMedium),
                const SizedBox(height: 2),
                Text(
                  link.displayValue,
                  style: BrandTypography.bodySmall.copyWith(
                    color: BrandTypography.mutedOn(
                      Theme.of(context).brightness,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GradientButton(
            label: l10n.actionContinue,
            expand: false,
            height: 40,
            goldBorder: false,
            gradient: isChat
                ? BrandGradients.brand
                : BrandGradients.goldHorizontal,
            foreground: isChat ? BrandColors.ivory : BrandColors.charcoal,
            onPressed: () =>
                ref.read(contactLauncherProvider).launch(link).then((bool ok) {
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.contactLaunchFailed)),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}
