import 'package:flutter/material.dart';

/// Visual style for [AppTab].
enum AppTabStyle {
  /// Flat tab style with a bottom indicator on selected item.
  flat,

  /// Rounded segmented style with pill-shaped selected item.
  rounded,
}

/// A theme-aware tabs widget built on [DefaultTabController], [TabBar], and
/// [TabBarView] with flat and rounded variants.
class AppTab extends StatelessWidget {
  const AppTab({
    super.key,
    required this.labels,
    required this.children,
    this.initialIndex = 0,
    this.style = AppTabStyle.flat,
    this.height,
    this.contentHeight = 210,
    this.contentSpacing = 12,
    this.gap = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.borderRadius,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.labelStyle,
    this.physics,
  }) : assert(labels.length >= 2, 'AppTab requires at least 2 labels'),
       assert(labels.length == children.length, 'labels and children length must match'),
       assert(initialIndex >= 0, 'initialIndex cannot be negative'),
       assert(initialIndex < labels.length, 'initialIndex out of range');

  final List<String> labels;
  final List<Widget> children;
  final int initialIndex;
  final AppTabStyle style;
  final double? height;
  final double contentHeight;
  final double contentSpacing;
  final double gap;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;
  final TextStyle? labelStyle;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final effectiveHeight = height ?? (style == AppTabStyle.rounded ? 88 : 56);
    final effectiveLabelStyle = tt.titleLarge
        ?.copyWith(fontWeight: FontWeight.w600)
        .merge(labelStyle);

    return DefaultTabController(
      length: labels.length,
      initialIndex: initialIndex,
      child: Column(
        children: [
          switch (style) {
            AppTabStyle.flat => TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.zero,
              indicatorColor: indicatorColor ?? cs.primary,
              indicatorWeight: 3,
              labelColor: selectedColor ?? cs.primary,
              unselectedLabelColor: unselectedColor ?? cs.onSurfaceVariant,
              labelStyle: effectiveLabelStyle,
              tabs: [for (final label in labels) Tab(text: label)],
            ),
            AppTabStyle.rounded => Container(
              height: effectiveHeight,
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor ?? cs.surfaceContainerHighest,
                borderRadius: borderRadius ?? BorderRadius.circular(999),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.symmetric(horizontal: gap / 2),
                indicator: BoxDecoration(
                  color: selectedBackgroundColor ?? cs.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
                labelColor: selectedColor ?? cs.primary,
                unselectedLabelColor: unselectedColor ?? cs.onSurfaceVariant,
                labelStyle: effectiveLabelStyle,
                tabs: [for (final label in labels) Tab(text: label)],
              ),
            ),
          },
          SizedBox(height: contentSpacing),
          SizedBox(
            height: contentHeight,
            child: TabBarView(physics: physics, children: children),
          ),
        ],
      ),
    );
  }
}
