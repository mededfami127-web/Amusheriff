import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/admin/presentation/widgets/admin_gate_taps.dart';
import '../../features/settings/domain/entities/site_settings.dart';
import '../../features/settings/presentation/providers/site_settings_providers.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/brand_colors.dart';
import '../theme/gradients.dart';
import 'brand_logo.dart';

/// Scaffold shared by every surface: a branded app bar with the ASM lockup,
/// a metallic hairline under it, and an optional leading back button.
class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.showLockup = true,
    this.onBack,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.safeArea = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final bool showLockup;
  final VoidCallback? onBack;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final bool safeArea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final SiteSettings settings = ref.watch(siteSettingsValueProvider);
    final bool canPop = onBack != null || Navigator.of(context).canPop();

    // The shop name is too long for one app-bar line, so it is split after the
    // first word: "Amusheriff" large, "Arabiyan Mejlis and Furniture" under it.
    // Splitting the name the owner typed keeps the two lines in step with the
    // site settings instead of hard-coding them here.
    //
    // `displayName` also covers the stored row still holding a pre-rename
    // spelling: the app bar reads the current brand even before the SQL update
    // in `supabase/APPLY_ALL.sql` has run against the project.
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String language = Localizations.localeOf(context).languageCode;
    final String brand =
        title ?? settings.displayName(language, brandFallback: l10n.appTitle);

    // Two lines of brand copy double in height at a 2.0 text scale, which is
    // taller than the stock 56 dp toolbar. Growing the bar with the text keeps
    // the whole name on screen instead of clipping it, and the wordmark clamps
    // the rest of the scale so the block still fits at 320 dp wide.
    final double textScale = MediaQuery.textScalerOf(context).scale(1);
    final double toolbarHeight = showLockup
        ? 56 + (textScale.clamp(1.0, 1.6) - 1) * 44
        : kToolbarHeight;
    final int splitAt = brand.indexOf(' ');
    final String brandHead = splitAt <= 0 ? brand : brand.substring(0, splitAt);
    final String? brandTail = splitAt <= 0
        ? null
        : brand.substring(splitAt + 1).trim();

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      appBar: AppBar(
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              )
            : null,
        automaticallyImplyLeading: canPop,
        toolbarHeight: toolbarHeight,
        title: showLockup
            // Five taps on the badge open the owner panel.
            ? AdminGateTaps(
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.6,
                  child: BrandLockup(
                    english: brandHead,
                    secondary: brandTail,
                    amharic:
                        title == null &&
                            !SiteSettings.isLegacyBrandName(
                              settings.storeNameAm,
                            )
                        ? settings.storeNameAm.trim()
                        : null,
                    arabic:
                        title == null &&
                            !SiteSettings.isLegacyBrandName(
                              settings.storeNameAr,
                            )
                        ? settings.storeNameAr.trim()
                        : null,
                  ),
                ),
              )
            : Text(title ?? ''),
        titleSpacing: 16,
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: BrandGradients.goldHorizontal,
              color: dark ? BrandColors.gold : BrandColors.gold,
            ),
          ),
        ),
      ),
      body: safeArea ? SafeArea(top: false, child: body) : body,
    );
  }
}
