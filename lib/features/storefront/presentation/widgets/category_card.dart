import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/storage_urls.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';

/// One category tile that always shows an image.
///
/// Resolution order: the category's own cover, then the first product image in
/// that category, then a branded placeholder. The product fallback comes from
/// one derived map (the storefront products stream), never a query per card.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String language = Localizations.localeOf(context).languageCode;
    final StorageUrls urls = ref.watch(storageUrlsProvider);
    final String? productPath = ref.watch(
      categoryThumbnailPathsProvider,
    )[category.id];

    final String? coverUrl = category.hasCover
        ? urls.categoryCover(category.coverPath!)
        : null;
    final String? productUrl = productPath == null
        ? null
        : urls.productMediaThumb(productPath, width: 160);
    final String? fallbackUrl = coverUrl != null ? productUrl : null;

    return Semantics(
      button: true,
      label: l10n.a11yOpenCategory(category.nameFor(language)),
      child: SizedBox(
        width: width,
        child: Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _CategoryThumb(
                    url: coverUrl ?? productUrl,
                    fallbackUrl: fallbackUrl,
                    dark: dark,
                  ),
                  Text(
                    category.nameFor(language),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: BrandTypography.titleMedium.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryThumb extends StatelessWidget {
  const _CategoryThumb({
    required this.url,
    required this.fallbackUrl,
    required this.dark,
  });

  final String? url;
  final String? fallbackUrl;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = _CategoryThumbFallback(dark: dark);
    final Widget image = url == null
        ? placeholder
        : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: url!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              memCacheWidth: 160,
              placeholder: (_, __) => placeholder,
              errorWidget: (_, __, ___) => fallbackUrl == null
                  ? placeholder
                  : CachedNetworkImage(
                      imageUrl: fallbackUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      memCacheWidth: 160,
                      placeholder: (_, __) => placeholder,
                      errorWidget: (_, __, ___) => placeholder,
                    ),
            ),
          );

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: BrandGradients.brand,
      ),
      child: image,
    );
  }
}

class _CategoryThumbFallback extends StatelessWidget {
  const _CategoryThumbFallback({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.weekend_outlined,
      size: 20,
      color: dark ? BrandColors.goldLight : BrandColors.ivory,
    );
  }
}
