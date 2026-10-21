import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/storage_urls.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/shimmer_card.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';

/// One category tile: the photo is the card, edge to edge.
///
/// Resolution order: the category's own cover, then the first product image in
/// that category, then a branded placeholder. The product fallback comes from
/// one derived map (the storefront products stream), never a query per card.
///
/// The URL is built from the storage path alone — never from the locale or the
/// localised name — so the same photo loads in every language. A failed request
/// degrades to the branded placeholder, never to an error panel, and the name
/// stays readable on the scrim above it.
class CategoryCard extends ConsumerWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.width,
    this.onTap,
  });

  final Category category;
  final double? width;
  final VoidCallback? onTap;

  /// Decode width for the cover. The tile is ~138dp wide, so 3x the widest
  /// phone density is enough for a crisp photo without holding a 4K bitmap for
  /// every card on the rail.
  static const int _coverCacheWidth = 480;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String language = Localizations.localeOf(context).languageCode;
    final StorageUrls urls = ref.watch(storageUrlsProvider);
    final String? productPath = ref.watch(
      categoryThumbnailPathsProvider,
    )[category.id];

    final String? coverPath = category.hasCover ? category.coverPath : null;
    final String? imageUrl = coverPath != null
        ? urls.categoryCover(coverPath)
        : productPath == null
        ? null
        : urls.productMediaThumb(productPath, width: _coverCacheWidth);

    final String name = category.nameFor(language);

    return Semantics(
      button: true,
      image: imageUrl != null,
      label: l10n.a11yOpenCategory(name),
      child: SizedBox(
        width: width,
        child: Card(
          margin: EdgeInsets.zero,
          // Clipping at the card is what rounds the full-bleed photo; the image
          // itself is not a small thumbnail in a corner any more.
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: BrandColors.goldHairline),
          ),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CategoryCoverImage(url: imageUrl),
                const _BottomScrim(),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Align(
                      alignment: AlignmentDirectional.bottomStart,
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: BrandTypography.titleMedium.copyWith(
                          fontSize: 14,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.ivory,
                          shadows: const <Shadow>[
                            Shadow(
                              color: Color(0xCC000000),
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
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

/// The cover photo of one category tile, filling its parent.
///
/// Shows a shimmer while the bytes arrive and the branded placeholder when
/// there is no photo or the request fails.
class CategoryCoverImage extends StatelessWidget {
  const CategoryCoverImage({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const Widget placeholder = _CategoryPlaceholder();
    if (url == null) return placeholder;

    return CachedNetworkImage(
      imageUrl: url!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      memCacheWidth: CategoryCard._coverCacheWidth,
      maxWidthDiskCache: CategoryCard._coverCacheWidth,
      fadeInDuration: const Duration(milliseconds: 220),
      placeholder: (_, __) =>
          const ShimmerBox(height: double.infinity, radius: 0),
      errorWidget: (_, __, ___) => placeholder,
      imageBuilder: (_, ImageProvider provider) =>
          Image(image: provider, fit: BoxFit.cover),
    );
  }
}

/// Darkens the lower half so the category name keeps contrast on any photo.
class _BottomScrim extends StatelessWidget {
  const _BottomScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0x00000000),
            Color(0x1A000000),
            Color(0xE6000000),
          ],
          stops: <double>[0.30, 0.55, 1],
        ),
      ),
    );
  }
}

/// Branded fallback: the sofa mark on the brand sweep, never a broken icon.
class _CategoryPlaceholder extends StatelessWidget {
  const _CategoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: dark ? BrandGradients.brandVertical : BrandGradients.gold,
      ),
      child: Center(
        child: Icon(
          Icons.weekend_outlined,
          size: 44,
          color: dark ? BrandColors.goldLight : BrandColors.charcoal,
        ),
      ),
    );
  }
}
