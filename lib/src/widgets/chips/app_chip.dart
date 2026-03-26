import 'package:flutter/material.dart';

/// Color variants for [AppChip] using Material shade 100/900 pairs.
enum ChipVariant {
  /// Background: blue 100, foreground: blue 900.
  blue,

  /// Background: green 100, foreground: green 900.
  green,

  /// Background: red 100, foreground: red 900.
  red,

  /// Background: yellow 100, foreground: yellow 900.
  yellow,
}

/// A compact chip with default 100/900 color variants and optional overrides.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.variant = ChipVariant.blue,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  });

  final String label;
  final ChipVariant variant;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadiusGeometry? borderRadius;

  Color _background() {
    return switch (variant) {
      ChipVariant.blue => Colors.blue.shade100,
      ChipVariant.green => Colors.green.shade100,
      ChipVariant.red => Colors.red.shade100,
      ChipVariant.yellow => Colors.yellow.shade100,
    };
  }

  Color _foreground() {
    return switch (variant) {
      ChipVariant.blue => Colors.blue.shade900,
      ChipVariant.green => Colors.green.shade900,
      ChipVariant.red => Colors.red.shade900,
      ChipVariant.yellow => Colors.yellow.shade900,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? _background();
    final fg = foregroundColor ?? _foreground();

    return Container(
      padding: padding,
      decoration: BoxDecoration(color: bg, borderRadius: borderRadius ?? BorderRadius.circular(10)),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: fg).merge(textStyle),
      ),
    );
  }
}
