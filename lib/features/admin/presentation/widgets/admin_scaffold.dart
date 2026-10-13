import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/admin_ui_providers.dart';

/// One destination in the gateway.
class AdminDestination {
  const AdminDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  /// Uses an already-localised string rather than a key, because the caller
  /// holds the `AppLocalizations` instance.
  final String label;
  final IconData icon;
  final String route;
}

List<AdminDestination> _destinations(AppLocalizations l10n) =>
    <AdminDestination>[
      AdminDestination(
        label: l10n.adminDashboard,
        icon: Icons.dashboard_outlined,
        route: Routes.adminRoot,
      ),
      AdminDestination(
        label: l10n.adminCategories,
        icon: Icons.category_outlined,
        route: Routes.adminCategories,
      ),
      AdminDestination(
        label: l10n.adminProducts,
        icon: Icons.chair_outlined,
        route: Routes.adminProducts,
      ),
      AdminDestination(
        label: l10n.adminContacts,
        icon: Icons.share_outlined,
        route: Routes.adminContacts,
      ),
      AdminDestination(
        label: l10n.adminInquiries,
        icon: Icons.insights_outlined,
        route: Routes.adminInquiries,
      ),
      AdminDestination(
        label: l10n.adminSiteSettings,
        icon: Icons.tune_outlined,
        route: Routes.adminSiteSettings,
      ),
      AdminDestination(
        label: l10n.adminChangePassword,
        icon: Icons.password_rounded,
        route: Routes.adminChangePassword,
      ),
    ];

/// Responsive chrome shared by every gateway screen.
///
/// Tablet and web get a permanent [NavigationRail]; phones get a drawer. Both
/// render the same destinations from the same list, so the two layouts cannot
/// drift apart, and both are topped by the brand-gradient header.
class AdminScaffold extends ConsumerWidget {
  const AdminScaffold({
    super.key,
    required this.child,
    required this.title,
    this.selectedRoute = Routes.adminRoot,
    this.actions,
    this.floatingActionButton,
  });

  final Widget child;
  final String title;
  final String selectedRoute;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  static const double _railBreakpoint = 1000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<AdminDestination> destinations = _destinations(l10n);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= _railBreakpoint;
        if (wide) {
          return Scaffold(
            floatingActionButton: floatingActionButton,
            body: Row(
              children: <Widget>[
                _AdminRail(destinations: destinations, current: selectedRoute),
                Expanded(
                  child: _AdminPane(
                    title: title,
                    actions: actions,
                    child: child,
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          floatingActionButton: floatingActionButton,
          drawer: _AdminDrawer(destinations: destinations, current: selectedRoute),
          appBar: _appBar(actions),
          body: SafeArea(top: false, child: child),
        );
      },
    );
  }

  /// Phone layout: navigation lives in the drawer, so the bar carries the
  /// hamburger plus this page's actions.
  PreferredSizeWidget _appBar(List<Widget>? actions) =>
      _adminAppBar(title: title, actions: actions, canPop: true);
}

/// Branded app bar shared by both layouts, so the hairline and title
/// treatment are defined once.
PreferredSizeWidget _adminAppBar({
  required String title,
  List<Widget>? actions,
  bool canPop = false,
}) {
  return AppBar(
    automaticallyImplyLeading: canPop,
    titleSpacing: 16,
    title: _AdminTitle(title),
    actions: actions,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: BrandGradients.goldHorizontal),
        child: SizedBox(height: 1, width: double.infinity),
      ),
    ),
  );
}

class _AdminTitle extends StatelessWidget {
  const _AdminTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: BrandTypography.titleMedium.copyWith(
        color: dark ? BrandColors.goldLight : BrandColors.charcoal,
      ),
    );
  }
}

/// Content area with its own branded app bar (wide layout).
class _AdminPane extends StatelessWidget {
  const _AdminPane({
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _adminAppBar(title: title, actions: actions),
      body: SafeArea(top: false, child: child),
    );
  }
}

/// Brand-gradient header used at the top of both the rail and the drawer.
class AdminBrandHeader extends ConsumerWidget {
  const AdminBrandHeader({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool previewing = ref.watch(previewAsCustomerProvider);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
          decoration: const BoxDecoration(gradient: BrandGradients.brand),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.brandMonogram,
                style: BrandTypography.displayWeighted(700, size: 26).copyWith(
                  color: BrandColors.goldLight,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.adminGatewayTitle,
                style: BrandTypography.bodySmall.copyWith(
                  color: BrandColors.ivory.withValues(alpha: 0.9),
                ),
              ),
              if (previewing) ...<Widget>[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: BrandColors.ivory.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.adminPreviewBadge,
                    style: BrandTypography.labelSmall.copyWith(
                      color: BrandColors.ivory,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminRail extends ConsumerWidget {
  const _AdminRail({required this.destinations, required this.current});

  final List<AdminDestination> destinations;
  final String current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Container(
      width: 244,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? BrandColors.deepPlum
            : Colors.white,
        border: Border(
          right: BorderSide(
            color: BrandColors.gold.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          const AdminBrandHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: destinations.length,
              itemBuilder: (BuildContext context, int index) {
                final AdminDestination d = destinations[index];
                final bool selected =
                    GoRouterState.of(context).matchedLocation == d.route ||
                        current == d.route;
                return _AdminTile(
                  destination: d,
                  selected: selected,
                  onTap: () => context.go(d.route),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: BrandColors.goldHairline),
          _AdminActionTile(
            label: l10n.adminViewStore,
            icon: Icons.storefront_outlined,
            onTap: () => context.go(Routes.storefront),
          ),
          _AdminActionTile(
            label: l10n.adminSignOut,
            icon: Icons.logout_rounded,
            onTap: () async {
              await ref.read(adminAuthControllerProvider.notifier).signOut();
              if (context.mounted) context.go(Routes.storefront);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AdminDrawer extends ConsumerWidget {
  const _AdminDrawer({required this.destinations, required this.current});

  final List<AdminDestination> destinations;
  final String current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String location = GoRouterState.of(context).matchedLocation;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const AdminBrandHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: destinations.length,
                itemBuilder: (BuildContext context, int index) {
                  final AdminDestination d = destinations[index];
                  final bool selected =
                      location == d.route || current == d.route;
                  return _AdminTile(
                    destination: d,
                    selected: selected,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(d.route);
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1, thickness: 1),
            _AdminActionTile(
              label: l10n.adminViewStore,
              icon: Icons.storefront_outlined,
              onTap: () {
                Navigator.of(context).pop();
                context.go(Routes.storefront);
              },
            ),
            _AdminActionTile(
              label: l10n.adminSignOut,
              icon: Icons.logout_rounded,
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(adminAuthControllerProvider.notifier).signOut();
                if (context.mounted) context.go(Routes.storefront);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AdminDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color foreground = dark ? BrandColors.ivory : BrandColors.charcoal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected
            ? BrandGradients.brand.colors.first.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            // 48dp minimum touch target (accessibility requirement).
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: selected
                  ? Border.all(color: BrandColors.gold.withValues(alpha: 0.6))
                  : null,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  destination.icon,
                  size: 20,
                  color: selected ? BrandColors.gold : foreground,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: selected
                        ? BrandTypography.labelLarge.copyWith(
                            color: dark
                                ? BrandColors.goldLight
                                : BrandColors.charcoal,
                          )
                        : BrandTypography.bodyMedium.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  const _AdminActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minTileHeight: 48,
      leading: Icon(icon, size: 20, color: BrandColors.gold),
      title: Text(label, style: BrandTypography.bodyMedium),
      onTap: onTap,
    );
  }
}
