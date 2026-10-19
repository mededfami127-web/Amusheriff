import 'package:flutter/material.dart';

/// A body that sits centred when it fits and scrolls when it does not.
///
/// The failure this exists to remove: an empty state is a `Column`, a `Column`
/// given a short height (a small phone with the keyboard open, or 2.0 text)
/// overflows, and the customer sees the yellow-and-black stripes instead of the
/// message. A blind `SingleChildScrollView` is not the fix either — it would
/// collapse the centring and, inside a screen that already scrolls, add a second
/// unbounded viewport.
///
/// [AdaptiveScrollBody] measures the space it is actually given:
///
/// * bounded height → a scroll view whose child is at least as tall as the
///   viewport, so short content stays centred and tall content scrolls;
/// * unbounded height (a sliver, a column) → the child is returned with its
///   natural size, because the parent already scrolls.
///
/// `keyboardDismissBehavior: onDrag` means a form can be dismissed by dragging
/// the message, matching the rest of the forms.
class AdaptiveScrollBody extends StatelessWidget {
  const AdaptiveScrollBody({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!constraints.hasBoundedHeight) return child;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            // No IntrinsicHeight: it forces a tight height on the child, and a
            // rounded line box one pixel taller than the viewport then reports
            // an overflow instead of scrolling. Align + a min height already
            // centres short content and lets tall content grow.
            child: Align(alignment: alignment, child: child),
          ),
        );
      },
    );
  }
}

/// [AdaptiveScrollBody] with the scrollbar-friendly padding empty states use.
class ScrollableEmptyState extends StatelessWidget {
  const ScrollableEmptyState({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AdaptiveScrollBody(child: child);
}
