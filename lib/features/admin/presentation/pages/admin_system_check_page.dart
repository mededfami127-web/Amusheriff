import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env.dart';
import '../../../../core/config/flavors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../data/system_check_runner.dart';
import '../providers/system_check_providers.dart';
import '../widgets/admin_scaffold.dart';

/// Diagnosis screen: what this build expects from its backend, and what is
/// actually there.
///
/// It exists because "every screen shows an error" has three different causes —
/// the database was never set up on this project, the project cannot be
/// reached, or a single asset is misconfigured — and each one has a different
/// fix. Rather than make the owner guess from scattered error banners, one
/// screen probes each table, bucket and function and prints the exact command
/// that repairs what it found.
class AdminSystemCheckPage extends ConsumerWidget {
  const AdminSystemCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<SystemAssetCheck>> async = ref.watch(
      systemChecksProvider,
    );

    final Widget body = async.when<Widget>(
      loading: () => const _CheckSkeleton(),
      error: (Object error, StackTrace __) => ErrorStateView(
        failure: ErrorMapper.map(error),
        onRetry: () => ref.invalidate(systemChecksProvider),
      ),
      data: (List<SystemAssetCheck> checks) => _SystemCheckList(checks: checks),
    );

    return AdminScaffold(
      title: l10n.systemCheckTitle,
      selectedRoute: Routes.adminSystemCheck,
      actions: <Widget>[
        IconButton(
          tooltip: l10n.systemCheckRun,
          onPressed: () => ref.invalidate(systemChecksProvider),
          icon: const Icon(Icons.refresh_rounded, color: BrandColors.gold),
        ),
      ],
      child: body,
    );
  }
}

class _SystemCheckList extends ConsumerWidget {
  const _SystemCheckList({required this.checks});

  final List<SystemAssetCheck> checks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    final List<SystemAssetCheck> missing = checks
        .where((SystemAssetCheck c) => c.status == SystemAssetStatus.missing)
        .toList(growable: false);
    final bool unreachable = checks.any(
      (SystemAssetCheck c) => c.status == SystemAssetStatus.unreachable,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: <Widget>[
        const _BuildMetaCard(),
        const SizedBox(height: 12),
        missing.isEmpty && !unreachable
            ? _allClearCard(l10n, dark)
            : _needsWorkCard(context, ref, l10n, dark, missing, unreachable),
        const SizedBox(height: 16),
        for (final SystemAssetCheck check in checks) ...<Widget>[
          _CheckTile(check: check),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _allClearCard(AppLocalizations l10n, bool dark) {
    return _card(
      dark: dark,
      border: BrandColors.success.withValues(alpha: 0.5),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.check_circle_outline,
            color: BrandColors.success,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.systemCheckAllGood,
              style: BrandTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _needsWorkCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool dark,
    List<SystemAssetCheck> missing,
    bool unreachable,
  ) {
    final bool missingDatabase = missing.any(
      (SystemAssetCheck c) => c.kind != SystemAssetKind.function,
    );
    final bool missingFunction = missing.any(
      (SystemAssetCheck c) => c.kind == SystemAssetKind.function,
    );

    return _card(
      dark: dark,
      border: BrandColors.danger.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.error_outline,
                color: BrandColors.danger,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.systemCheckMissingSummary,
                  style: BrandTypography.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (missingDatabase) ...<Widget>[
            _fixLine(l10n.systemCheckFixDatabase),
            const SizedBox(height: 6),
            _fixLine(l10n.systemCheckFixSeed),
            const SizedBox(height: 6),
          ],
          if (missingFunction) ...<Widget>[
            _fixLine(l10n.systemCheckFixFunction),
            const SizedBox(height: 6),
          ],
          if (unreachable) _fixLine(l10n.systemCheckFixNetwork),
          const SizedBox(height: 14),
          SizedBox(
            width: 220,
            child: GradientButton(
              label: l10n.systemCheckRun,
              icon: Icons.refresh_rounded,
              expand: false,
              height: 44,
              onPressed: () => ref.invalidate(systemChecksProvider),
            ),
          ),
        ],
      ),
    );
  }

  /// A copyable command line, styled like a terminal.
  Widget _fixLine(String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const Padding(
        padding: EdgeInsets.only(top: 2),
        child: Icon(Icons.terminal_rounded, size: 16, color: BrandColors.gold),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: BrandTypography.bodySmall.copyWith(fontFamily: 'monospace'),
        ),
      ),
    ],
  );

  Widget _card({
    required bool dark,
    required Color border,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? BrandColors.plumSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

/// Which flavor and which Supabase project this binary was baked for — the two
/// facts that decide whether the rest of the screen is even pointing at the
/// right backend.
class _BuildMetaCard extends ConsumerWidget {
  const _BuildMetaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    // Read from the build's own configuration rather than from a live client,
    // so this card still renders — and still says which project the app is
    // talking to — when that backend cannot be reached at all.
    final String host = Env.supabaseUrl.isEmpty
        ? '—'
        : (Uri.tryParse(Env.supabaseUrl)?.host ?? '—');
    final String? email = ref.watch(currentUserProvider)?.email;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? BrandColors.plumSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _metaRow(l10n.systemCheckBuild, AppFlavor.current.name),
          const SizedBox(height: 8),
          _metaRow(l10n.systemCheckProject, host),
          const SizedBox(height: 8),
          _metaRow(
            l10n.systemCheckAccount,
            email ?? l10n.systemCheckNotSignedIn,
          ),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 150,
          child: Text(label, style: BrandTypography.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: BrandTypography.bodyMedium.copyWith(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({required this.check});

  final SystemAssetCheck check;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color surface = dark ? BrandColors.plumSurface : Colors.white;

    final (
      String label,
      IconData statusIcon,
      Color color,
    ) = switch (check.status) {
      SystemAssetStatus.ok => (
        l10n.systemCheckOk,
        Icons.check_circle_outline,
        BrandColors.success,
      ),
      SystemAssetStatus.restricted => (
        l10n.systemCheckRestricted,
        Icons.lock_outline,
        BrandColors.gold,
      ),
      SystemAssetStatus.missing => (
        l10n.systemCheckMissing,
        Icons.error_outline,
        BrandColors.danger,
      ),
      SystemAssetStatus.unreachable => (
        l10n.systemCheckUnreachable,
        Icons.wifi_off_rounded,
        BrandColors.warning,
      ),
      SystemAssetStatus.unknown => (
        l10n.systemCheckUnknown,
        Icons.help_outline,
        BrandTypography.mutedOn(Theme.of(context).brightness),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrandColors.goldHairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(_kindIcon, size: 20, color: BrandColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  check.name,
                  style: BrandTypography.bodyMedium.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                if (check.detail case final String detail) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: BrandTypography.bodySmall.copyWith(
                      color: BrandTypography.mutedOn(
                        Theme.of(context).brightness,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Icon(statusIcon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: BrandTypography.labelSmall.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData get _kindIcon => switch (check.kind) {
    SystemAssetKind.table => Icons.table_chart_outlined,
    SystemAssetKind.storage => Icons.folder_outlined,
    SystemAssetKind.function => Icons.bolt_outlined,
  };
}

class _CheckSkeleton extends StatelessWidget {
  const _CheckSkeleton();

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: 9,
      itemBuilder: (BuildContext context, int index) => Container(
        height: index == 0 ? 120 : 64,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: (dark ? BrandColors.plumSurface : Colors.grey.shade200)
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
