import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';
import '../theme/gradients.dart';

/// A 1px metallic gold rule — the recurring "luxury hairline" of the brand.
///
/// When [withOrnament] is true a small diamond sits at the centre, evoking the
/// gold rule beneath the ASM wordmark.
class GoldDivider extends StatelessWidget {
  const GoldDivider({
    super.key,
    this.withOrnament = false,
    this.indent = 0,
    this.endIndent = 0,
    this.thickness = 1,
  });

  final bool withOrnament;
  final double indent;
  final double endIndent;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final Widget rule = Container(
      height: thickness,
      decoration: const BoxDecoration(gradient: BrandGradients.goldHorizontal),
    );

    if (!withOrnament) {
      return Padding(
        padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
        child: rule,
      );
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
      child: Row(
        children: <Widget>[
          Expanded(child: rule),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Transform.rotate(
              angle: 0.785398, // 45° — a diamond
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: BrandGradients.gold,
                  color: BrandColors.gold,
                ),
                child: SizedBox(width: 7, height: 7),
              ),
            ),
          ),
          Expanded(child: rule),
        ],
      ),
    );
  }
}
