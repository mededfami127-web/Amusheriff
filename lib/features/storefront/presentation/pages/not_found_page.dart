import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/gradient_button.dart';

/// Rendered by go_router's `errorBuilder` for any unmatched path.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.location});

  final String? location;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppScaffold(
      showLockup: false,
      title: l10n.stateNotFoundTitle,
      body: EmptyState(
        title: l10n.stateNotFoundTitle,
        message: l10n.stateNotFoundMessage,
        icon: Icons.explore_off_outlined,
        action: GradientButton(
          label: l10n.navHome,
          icon: Icons.home_outlined,
          expand: false,
          height: 48,
          onPressed: () => context.go(Routes.storefront),
        ),
      ),
    );
  }
}
