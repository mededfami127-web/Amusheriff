import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/brand_colors.dart';

/// A single shimmering rounded block. Use for one-line placeholders.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.radius = 8,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: dark ? BrandColors.plumSurface : const Color(0xFFEDE6DA),
      highlightColor:
          dark ? const Color(0xFF3A2A4C) : const Color(0xFFFBF8F2),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Product-card shaped placeholder used while the catalogue loads.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    this.height = 260,
    this.showLines = true,
  });

  final double height;
  final bool showLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ShimmerBox(height: height, radius: 20),
        if (showLines) ...<Widget>[
          const SizedBox(height: 12),
          const ShimmerBox(height: 14, width: 160),
          const SizedBox(height: 8),
          const ShimmerBox(height: 14, width: 90),
        ],
      ],
    );
  }
}

/// A full grid of [ShimmerCard]s, matching the storefront's 2-column layout.
class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.aspectRatio = 0.62,
    this.padding = const EdgeInsets.all(16),
  });

  final int itemCount;
  final double aspectRatio;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (_, __) => const ShimmerCard(),
    );
  }
}

/// Shimmering horizontal rail used for the featured carousel.
class ShimmerRail extends StatelessWidget {
  const ShimmerRail({super.key, this.height = 200, this.itemCount = 4});

  final double height;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => ShimmerBox(
          height: height,
          width: height * 0.82,
          radius: 20,
        ),
      ),
    );
  }
}
