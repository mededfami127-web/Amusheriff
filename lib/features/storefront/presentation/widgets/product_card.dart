import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/storage_urls.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../catalog/domain/entities/product.dart';
import 'favourite_button.dart';

/// A single catalogue tile. Tapping opens the product detail route.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, this.width});

  final Product product;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String language = Localizations.localeOf(context).languageCode;
    final String title = product.titleFor(language);
    final String? cover = product.coverPath;

    return SizedBox(
      width: width,
      child: Card(
        child: InkWell(
          onTap: () => context.push(Routes.product(product.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // The photo takes whatever height the host leaves after the text,
              // so a taller accessibility text block cannot overflow the cell.
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    if (cover == null)
                      _Placeholder(dark: dark)
                    else
                      CachedNetworkImage(
                        imageUrl: ref
                            .read(storageUrlsProvider)
                            .productMediaThumb(cover, width: 560),
                        // Decode at the size the tile paints; a full 4K photo
                        // per grid cell is most of the raster cost of a scroll.
                        memCacheWidth: 560,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 220),
                        placeholder: (_, __) => _Placeholder(dark: dark),
                        errorWidget: (_, __, ___) =>
                            _Placeholder(dark: dark, failed: true),
                        imageBuilder: (_, ImageProvider provider) => Semantics(
                          label: l10n.a11yProductImage(title),
                          image: true,
                          child: Image(image: provider, fit: BoxFit.cover),
                        ),
                        // Helps screen readers and keeps a11y labels localized.
                        imageBuilder: (_, ImageProvider provider) => Semantics(
                          label: l10n.a11yProductImage(title),
                          image: true,
                          child: Image(image: provider, fit: BoxFit.cover),
                        ),
                      ),
                    if (product.hasDiscount)
                      PositionedDirectional(
                        top: 10,
                        start: 10,
                        child: _DiscountBadge(
                          percent: product.discountPercent ?? 0,
                          label: l10n.labelDiscount(
                            product.discountPercent ?? 0,
                          ),
                        ),
                      ),
                    if (!product.isAvailable)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: 0.42),
                          child: Center(
                            child: Text(
                              l10n.labelUnavailable,
                              style: BrandTypography.labelLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (product.videos.isNotEmpty)
                      const PositionedDirectional(
                        bottom: 10,
                        end: 10,
                        child: _VideoChip(),
                      ),
                    // Saving a piece is one tap, right where the customer
                    // decided they liked it.
                    PositionedDirectional(
                      top: 6,
                      end: 6,
                      child: FavouriteButton(
                        productId: product.id,
                        onPhoto: true,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BrandTypography.titleMedium.copyWith(
                        color: dark ? BrandColors.ivory : BrandColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // A price and a struck-through price side by side do not fit
                    // a 136dp tile at 2.0 text; a Wrap puts the second one on
                    // its own line instead of clipping the first.
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        ShaderMask(
                          shaderCallback:
                              BrandGradients.goldHorizontal.createShader,
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            Formatters.money(
                              product.price,
                              currency: product.currencyCode,
                              locale: language,
                            ),
                            style: BrandTypography.price.copyWith(
                              color: BrandColors.gold,
                            ),
                          ),
                        ),
                        if (product.hasDiscount)
                          Text(
                            Formatters.money(
                              product.compareAtPrice!,
                              currency: product.currencyCode,
                              locale: language,
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: BrandTypography.priceStruck.copyWith(
                              color: BrandTypography.mutedOn(
                                Theme.of(context).brightness,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid metrics that grow with the accessibility text scale.
///
/// The old fixed `0.62` aspect was tuned for 1.0 text; at 2.0 the text block is
/// twice as tall and the tile had no room left. Two things change instead of
/// shrinking the words:
///
/// * a phone at 1.6x or more drops to one column, because a price token cannot
///   wrap inside a 136dp tile without breaking mid-number;
/// * otherwise the cell gets taller, and the photo absorbs the difference.
SliverGridDelegate productGridDelegate(BuildContext context) {
  final double scale = MediaQuery.textScalerOf(context).scale(1);
  final double width = MediaQuery.sizeOf(context).width;
  final bool singleColumn = width < 600 && scale >= 1.6;
  final double extra = (scale - 1).clamp(0.0, 1.0) * 0.55;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: singleColumn ? 1 : 2,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: singleColumn ? 0.9 : 0.62 / (1 + extra),
  );
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.dark, this.failed = false});

  final bool dark;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? <Color>[BrandColors.plumSurface, BrandColors.deepPlum]
              : <Color>[const Color(0xFFF3ECE1), BrandColors.ivory],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          failed ? Icons.broken_image_outlined : Icons.chair_outlined,
          size: 34,
          color: BrandColors.gold.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent, required this.label});

  final int percent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: BrandGradients.warmAccent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: BrandTypography.labelSmall.copyWith(
          color: BrandColors.charcoal,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _VideoChip extends StatelessWidget {
  const _VideoChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        shape: BoxShape.circle,
        border: Border.all(color: BrandColors.gold.withValues(alpha: 0.6)),
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        size: 16,
        color: BrandColors.ivory,
      ),
    );
  }
}
