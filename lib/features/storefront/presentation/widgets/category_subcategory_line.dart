import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../catalog/domain/entities/category.dart';

/// Horizontally scrollable subcategory chips for a category page.
///
/// One level of nesting only: every chip is a sibling of the page's category,
/// not a grandchild. Selecting a chip navigates to that subcategory's page,
/// and the chip reflects the currently selected slug so the customer sees where
/// they are — including in RTL, where the line scrolls the opposite way.
class CategorySubcategoryLine extends StatelessWidget {
  const CategorySubcategoryLine({
    super.key,
    required this.categories,
    required this.language,
    this.selectedSlug,
  });

  final List<Category> categories;
  final String language;    final String? selectedSlug;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _Chip(
              label: l10n.adminFilterAllCategories,
              icon: Icons.category_outlined,
              isSelected: selectedSlug == null,
              onTap: selectedSlug == null
                    ? null
                    : () => context.go(Routes.category(categories.first.slug)),
            );
          }

          final Category category = categories[index - 1];
          final bool selected = selectedSlug == category.slug;

          return _Chip(
            label: category.nameFor(language),
            icon: Icons.subdirectory_arrow_right_rounded,
            isSelected: selected,
            onTap: () => context.go(Routes.category(category.slug)),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: isSelected,
      label: isSelected
          ? '${label} (selected)'
          : label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? BrandColors.gold
                : (dark
                    ? BrandColors.plumSurface
                    : BrandColors.ivory),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? BrandColors.gold : BrandColors.goldHairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? BrandColors.charcoal
                    : BrandColors.gold,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: BrandTypography.labelLarge.copyWith(
                  color: isSelected
                      ? BrandColors.charcoal
                      : (dark
                          ? BrandColors.goldLight
                          : BrandColors.charcoal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// RTL: the line itself is an `Axis.horizontal` ListView, which already
  /// lays out the chips in the correct scroll direction for the directionality
  /// of the context. No extra flip is needed here.
  bool get debugRtlScrollOk => true;
}

