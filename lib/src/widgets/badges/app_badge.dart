import 'package:flutter/material.dart';

/// Semantic color variants for [AppBadge].
enum BadgeVariant {
  /// Uses [ColorScheme.primary] with [ColorScheme.onPrimary].
  primary,

  /// Uses [ColorScheme.error] with [ColorScheme.onError].
  error,

  /// Uses [ColorScheme.secondaryContainer] with [ColorScheme.onSecondaryContainer].
  onSecondaryContainer,
}

/// A compact, theme-aware badge widget for labels/counters.
///
/// ```dart
/// AppBadge(label: '1')
/// AppBadge(label: 'NEW', variant: BadgeVariant.onSecondaryContainer)
/// AppBadge.dot(variant: BadgeVariant.error)
/// ```
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.primary,
    this.padding = const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
  }) : isDot = false,
       dotSize = 0;

  const AppBadge.dot({
    super.key,
    this.variant = BadgeVariant.primary,
    this.dotSize = 8,
    this.backgroundColor,
  }) : label = '',
       isDot = true,
       padding = EdgeInsets.zero,
       textStyle = null,
       foregroundColor = null;

  final String label;
  final BadgeVariant variant;
  final bool isDot;
  final double dotSize;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  Color _background(ColorScheme cs) {
    return switch (variant) {
      BadgeVariant.primary => cs.primary,
      BadgeVariant.error => cs.error,
      BadgeVariant.onSecondaryContainer => cs.secondaryContainer,
    };
  }

  Color _foreground(ColorScheme cs) {
    return switch (variant) {
      BadgeVariant.primary => cs.onPrimary,
      BadgeVariant.error => cs.onError,
      BadgeVariant.onSecondaryContainer => cs.onSecondaryContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? _background(cs);
    final fg = foregroundColor ?? _foreground(cs);

    if (isDot) {
      return Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: fg).merge(textStyle),
      ),
    );
  }
}
