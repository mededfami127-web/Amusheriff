import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/domain/entities/site_settings.dart';
import '../../features/settings/presentation/providers/site_settings_providers.dart';
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
        title: showLockup
            ? BrandLockup(
                english: title ?? settings.storeNameEn,
                amharic: title == null ? settings.storeNameAm : null,
                arabic: title == null ? settings.storeNameAr : null,
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
