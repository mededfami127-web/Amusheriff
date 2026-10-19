import 'package:flutter/material.dart';

import '../../../../core/network/storage_urls.dart' show storageUrlsProvider;
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../catalog/domain/entities/category.dart';

/// One category tile that always shows an image.
///
/// Resolution order: category cover -> branded placeholder with an icon.
/// No per-category product-image lookup here; the cover lives on the category
/// row, which keeps this to a single image per tile and avoids N+1.
class CategoryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String language = Localizations.localeOf(context).languageCode;

    return SizedBox(
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
                _CategoryThumb(category: category, dark: dark),
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
    );
  }
}

class _CategoryThumb extends StatelessWidget {
  const _CategoryThumb({required this.category, required this.dark});

  final Category category;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Widget image = category.hasCover
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              storageUrlsProvider.categoryCover(category.coverPath!),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _CategoryThumbFallback(dark: dark),
              loadingBuilder: (
                BuildContext context,
                ImageProvider provider,
                ImageChunkEvent? progress,
              ) {
                if (progress == null) return SizedBox.shrink();
                return _CategoryThumbFallback(dark: true);
              },
            ),
          )
        : _CategoryThumbFallback(dark: dark);

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
