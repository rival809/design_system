import 'package:flutter/material.dart';

/// Semantic variants for [AppSectionMessage].
enum SectionMessageType {
  /// Error state with an error icon color.
  error,

  /// Success state with a success icon color.
  success,

  /// Warning state with a warning icon color.
  warning,

  /// Informational state with an info icon color.
  info,
}

/// A bordered message section using surface and outline tokens.
///
/// Defaults:
/// - Background: [ColorScheme.surface]
/// - Border: [ColorScheme.outline]
/// - Radius: 8
/// - Padding: 12
class AppSectionMessage extends StatelessWidget {
  const AppSectionMessage({
    super.key,
    required this.message,
    this.type = SectionMessageType.info,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.backgroundColor,
    this.borderColor,
    this.messageStyle,
    this.icon,
    this.iconColor,
    this.iconSize = 28,
    this.gap = 12,
  });

  final String message;
  final SectionMessageType type;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? messageStyle;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final double gap;

  IconData _resolveIcon() {
    return switch (type) {
      SectionMessageType.error => Icons.error,
      SectionMessageType.success => Icons.check_circle_rounded,
      SectionMessageType.warning => Icons.warning_rounded,
      SectionMessageType.info => Icons.info,
    };
  }

  Color _resolveIconColor() {
    return switch (type) {
      SectionMessageType.error => Colors.red.shade700,
      SectionMessageType.success => Colors.green.shade600,
      SectionMessageType.warning => Colors.orange.shade700,
      SectionMessageType.info => Colors.blue.shade700,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? cs.surface;
    final outline = borderColor ?? cs.outline;
    final resolvedIcon = icon ?? _resolveIcon();
    final resolvedIconColor = iconColor ?? _resolveIconColor();
    final resolvedMessageStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(color: cs.onSurface).merge(messageStyle);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius,
        border: Border.all(color: outline, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(resolvedIcon, color: resolvedIconColor, size: iconSize),
          SizedBox(width: gap),
          Expanded(child: Text(message, style: resolvedMessageStyle)),
        ],
      ),
    );
  }
}
