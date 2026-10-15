import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../providers/favourites_providers.dart';

/// The heart that saves a piece to the customer's favourites.
///
/// The tap writes to the device store straight away and the icon follows the
/// stored set, so the state survives a restart and is identical on the grid, the
/// detail page and the favourites screen.
class FavouriteButton extends ConsumerWidget {
  const FavouriteButton({
    super.key,
    required this.productId,
    this.onPhoto = false,
    this.dense = false,
  });

  final String productId;

  /// Draws a translucent disc so the heart stays legible over a photo.
  final bool onPhoto;

  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool selected = ref.watch(isFavouriteProvider(productId));

    final Widget icon = Icon(
      selected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      size: dense ? 18 : 22,
      color: selected
          ? BrandColors.gold
          : (onPhoto ? BrandColors.ivory : BrandColors.goldHairline),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: selected ? l10n.actionUnfavourite : l10n.actionFavourite,
      child: IconButton(
        tooltip: selected ? l10n.actionUnfavourite : l10n.actionFavourite,
        visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
        style: onPhoto
            ? IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.45),
              )
            : null,
        onPressed: () async {
          final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
          final bool added =
              await ref.read(favouritesProvider.notifier).toggle(productId);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                added ? l10n.actionFavourite : l10n.actionUnfavourite,
              ),
              duration: const Duration(milliseconds: 1200),
            ),
          );
        },
        icon: icon,
      ),
    );
  }
}
