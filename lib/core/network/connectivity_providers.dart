import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/brand_colors.dart';
import '../theme/typography.dart';

part 'connectivity_providers.g.dart';

/// Live "is there a network at all" flag.
///
/// This is the transport view, not a reachability probe: Supabase can still be
/// down while Wi-Fi is up. That is what the typed `NetworkFailure` screens are
/// for. This provider exists so a device with no radio shows a banner instead
/// of a blank screen while every request times out.
@riverpod
Stream<bool> hasConnection(Ref ref) async* {
  final Connectivity connectivity = Connectivity();
  final List<ConnectivityResult> initial = await connectivity
      .checkConnectivity();
  yield _online(initial);
  yield* connectivity.onConnectivityChanged.map(_online);
}

bool _online(List<ConnectivityResult> results) =>
    results.isNotEmpty && !results.contains(ConnectivityResult.none);

/// Wraps the app and pins a slim banner under the status bar when offline.
///
/// It overlays rather than replaces the child: cached content, forms and the
/// gateway stay usable, and a reconnect removes the banner on the next event.
class OfflineBannerHost extends ConsumerWidget {
  const OfflineBannerHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool offline = ref.watch(hasConnectionProvider).value == false;
    if (!offline) return child;

    final AppLocalizations l10n = AppLocalizations.of(context);
    return Stack(
      children: <Widget>[
        child,
        PositionedDirectional(
          top: 0,
          start: 0,
          end: 0,
          child: SafeArea(
            bottom: false,
            child: Material(
              color: BrandColors.danger,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 16,
                      color: BrandColors.ivory,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.errorNetwork,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: BrandTypography.bodySmall.copyWith(
                          color: BrandColors.ivory,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
