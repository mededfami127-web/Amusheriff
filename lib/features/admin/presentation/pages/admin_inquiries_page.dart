import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../contacts/domain/entities/contact_kind.dart';
import '../../../inquiries/domain/entities/inquiry.dart';
import '../../../inquiries/presentation/providers/inquiry_providers.dart';
import '../widgets/admin_scaffold.dart';

/// Lead log: which product, which channel, when. Filterable by channel.
class AdminInquiriesPage extends ConsumerStatefulWidget {
  const AdminInquiriesPage({super.key});

  @override
  ConsumerState<AdminInquiriesPage> createState() =>
      _AdminInquiriesPageState();
}

class _AdminInquiriesPageState extends ConsumerState<AdminInquiriesPage> {
  ContactKind? _channel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Inquiry>> async =
        ref.watch(adminInquiriesProvider);

    final Widget body = async.when<Widget>(
      loading: () => const _InquirySkeleton(),
      error: (Object error, StackTrace __) => ErrorStateView(
        failure: ErrorMapper.map(error),
        onRetry: () => ref.invalidate(adminInquiriesProvider),
      ),
      data: (List<Inquiry> all) {
        final List<Inquiry> rows = _channel == null
            ? all
            : all
                .where((Inquiry i) =>
                    i.channel.toLowerCase() == _channel!.name.toLowerCase())
                .toList(growable: false);

        if (rows.isEmpty) {
          return EmptyState(
            title: l10n.adminNoInquiries,
            message: l10n.adminNoInquiriesYet,
            icon: Icons.insights_outlined,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
          itemCount: rows.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) return _filterBar(l10n, rows.length);
            final Inquiry inquiry = rows[index - 1];
            return _InquiryTile(inquiry: inquiry);
          },
        );
      },
    );

    return AdminScaffold(
      title: l10n.adminInquiries,
      selectedRoute: Routes.adminInquiries,
      child: body,
    );
  }

  Widget _filterBar(AppLocalizations l10n, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          FilterChip(
            label: Text(l10n.adminFilterAllStatus),
            selected: _channel == null,
            selectedColor: BrandColors.gold.withValues(alpha: 0.3),
            onSelected: (_) => setState(() => _channel = null),
          ),
          for (final ContactKind kind in ContactKind.values)
            FilterChip(
              label: Text(kind.name),
              selected: _channel == kind,
              selectedColor: BrandColors.gold.withValues(alpha: 0.3),
              onSelected: (_) => setState(() => _channel = kind),
            ),
          const SizedBox(width: 8),
          Text(
            l10n.searchResultsCount(count),
            style: BrandTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InquiryTile extends StatelessWidget {
  const _InquiryTile({required this.inquiry});

  final Inquiry inquiry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final DateTime when = inquiry.effectiveCreatedAt;
    final bool recent = when.isAfter(DateTime.now().subtract(const Duration(days: 7)));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: dark ? BrandColors.plumSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: recent
              ? BrandColors.gold.withValues(alpha: 0.55)
              : BrandColors.goldHairline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            _iconFor(inquiry.channel),
            color: BrandColors.gold,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  inquiry.productTitle ?? l10n.adminAnonymous,
                  style: BrandTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${inquiry.channel} · ${Formatters.relativeTime(when)}',
                  style: BrandTypography.bodySmall.copyWith(
                    color: BrandTypography.mutedOn(Theme.of(context).brightness),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String channel) {
    final ContactKind? kind = ContactKind.values
        .where((ContactKind k) => k.name == channel.toLowerCase())
        .firstOrNull;
    return kind?.icon ?? Icons.link_rounded;
  }
}

class _InquirySkeleton extends StatelessWidget {
  const _InquirySkeleton();

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) => Container(
        height: 64,
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
