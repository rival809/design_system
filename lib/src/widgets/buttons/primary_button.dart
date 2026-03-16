import 'package:flutter/material.dart';

/// Visual variant for [PrimaryButton].
enum ButtonVariant {
  /// Filled solid background using the primary color.
  filled,

  /// Outlined with a transparent background and primary-colored border.
  outlined,

  /// Text-only, no background or border.
  text,

  /// Outlined with secondary color.
  secondary,

  /// Filled solid background using the error/danger color.
  danger,

  /// Outlined with tertiary color.
  tertiary,

  /// Text-only that looks like a hyperlink (underlined).
  link,
}

/// Size preset for [PrimaryButton].
enum ButtonSize {
  /// Compact size — suitable for dense UIs, toolbars, and inline actions.
  small,

  /// Default size — suitable for most use cases.
  medium,

  /// Large size — suitable for prominent CTAs.
  large,
}

/// A customizable, theme-aware button widget.
///
/// Wraps [ElevatedButton], [OutlinedButton] or [TextButton] depending on
/// [variant]. Supports a built-in [isLoading] state that replaces the label
/// with a [CircularProgressIndicator] and disables user interaction.
///
/// ```dart
/// PrimaryButton(
///   label: 'Get Started',
///   onPressed: _handleSubmit,
/// )
///
/// PrimaryButton(
///   label: 'Cancel',
///   variant: ButtonVariant.outlined,
///   onPressed: Navigator.of(context).pop,
/// )
///
/// PrimaryButton(
///   label: 'Submitting…',
///   isLoading: true,
///   onPressed: null,
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  /// Text displayed inside the button.
  final String label;

  /// Callback invoked when the button is tapped. If `null`, the button is
  /// rendered in a disabled state.
  final VoidCallback? onPressed;

  /// Visual variant — [ButtonVariant.filled] by default.
  final ButtonVariant variant;

  /// Size preset — [ButtonSize.medium] by default.
  final ButtonSize size;

  /// When `true`, replaces [label] with a [CircularProgressIndicator] and
  /// prevents the button from receiving tap events.
  final bool isLoading;

  /// Icon displayed to the left of [label]. Ignored while [isLoading] is true.
  final Widget? leadingIcon;

  /// Icon displayed to the right of [label]. Ignored while [isLoading] is true.
  final Widget? trailingIcon;

  /// Overrides the default full-width behavior.
  /// When `false`, the button sizes itself to its content.
  final bool expand;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.expand = false,
  });

  // ---------------------------------------------------------------------------
  // Size helpers
  // ---------------------------------------------------------------------------

  EdgeInsetsGeometry get _padding => switch (size) {
    ButtonSize.small => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ButtonSize.large => const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
  };

  double get _fontSize => switch (size) {
    ButtonSize.small => 12,
    ButtonSize.medium => 14,
    ButtonSize.large => 16,
  };

  double get _loaderSize => switch (size) {
    ButtonSize.small => 14,
    ButtonSize.medium => 18,
    ButtonSize.large => 22,
  };

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget button = switch (variant) {
      ButtonVariant.filled => _FilledButton(
        label: label,
        onPressed: isLoading ? null : onPressed,
        padding: _padding,
        fontSize: _fontSize,
        loaderSize: _loaderSize,
        isLoading: isLoading,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        colorScheme: colorScheme,
      ),
      ButtonVariant.outlined => _OutlinedButtonWidget(
        label: label,
        onPressed: isLoading ? null : onPressed,
        padding: _padding,
        fontSize: _fontSize,
        loaderSize: _loaderSize,
        isLoading: isLoading,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        colorScheme: colorScheme,
      ),
      ButtonVariant.text => _TextButtonWidget(
        label: label,
        onPressed: isLoading ? null : onPressed,
        padding: _padding,
        fontSize: _fontSize,
        loaderSize: _loaderSize,
        isLoading: isLoading,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        colorScheme: colorScheme,
      ),
      ButtonVariant.secondary => _SecondaryButton(
        label: label,
        onPressed: isLoading ? null : onPressed,
        padding: _padding,
        fontSize: _fontSize,
        loaderSize: _loaderSize,
        isLoading: isLoading,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        colorScheme: colorScheme,
      ),
      ButtonVariant.danger => _DangerButton(
        label: label,
        onPressed: isLoading ? null : onPressed,
        padding: _padding,
        fontSize: _fontSize,
        loaderSize: _loaderSize,
        isLoading: isLoading,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        colorScheme: colorScheme,
      ),
      ButtonVariant.tertiary => _TertiaryButton(
        label: label,
        onPressed: isLoading ? null : onPressed,
        padding: _padding,
        fontSize: _fontSize,
        loaderSize: _loaderSize,
        isLoading: isLoading,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        colorScheme: colorScheme,
      ),
      ButtonVariant.link => _LinkButton(
        label: label,
        onPressed: isLoading ? null : onPressed,
        padding: _padding,
        fontSize: _fontSize,
        loaderSize: _loaderSize,
        isLoading: isLoading,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        colorScheme: colorScheme,
      ),
    };

    if (expand) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.loaderSize,
    required this.loaderColor,
    required this.fontSize,
    this.leadingIcon,
    this.trailingIcon,
    this.overrideColor,
    this.textStyle,
  });

  final String label;
  final bool isLoading;
  final double loaderSize;
  final Color loaderColor;
  final double fontSize;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  /// When set, wraps content in a [DefaultTextStyle] + [IconTheme] with this color.
  final Color? overrideColor;

  /// When set, overrides the text style (e.g. for underline in link).
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: loaderSize,
        height: loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
        ),
      );
    }

    Widget content;
    if (leadingIcon == null && trailingIcon == null) {
      content = Text(label, style: textStyle);
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 8)],
          Text(label, style: textStyle),
          if (trailingIcon != null) ...[const SizedBox(width: 8), trailingIcon!],
        ],
      );
    }

    if (overrideColor != null) {
      content = IconTheme(
        data: IconThemeData(color: overrideColor, size: fontSize + 2),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: overrideColor),
          child: content,
        ),
      );
    }

    return content;
  }
}

class _FilledButton extends StatelessWidget {
  const _FilledButton({
    required this.label,
    required this.onPressed,
    required this.padding,
    required this.fontSize,
    required this.loaderSize,
    required this.isLoading,
    required this.colorScheme,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double loaderSize;
  final bool isLoading;
  final ColorScheme colorScheme;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: fontSize);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: padding,
        textStyle: labelStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        loaderSize: loaderSize,
        loaderColor: cs.onPrimary,
        fontSize: fontSize,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
      ),
    );
  }
}

class _OutlinedButtonWidget extends StatelessWidget {
  const _OutlinedButtonWidget({
    required this.label,
    required this.onPressed,
    required this.padding,
    required this.fontSize,
    required this.loaderSize,
    required this.isLoading,
    required this.colorScheme,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double loaderSize;
  final bool isLoading;
  final ColorScheme colorScheme;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: fontSize);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
        side: BorderSide(
          color: onPressed == null && !isLoading
              ? cs.onSurface.withValues(alpha: 0.12)
              : cs.primary,
        ),
        padding: padding,
        textStyle: labelStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        loaderSize: loaderSize,
        loaderColor: colorScheme.primary,
        fontSize: fontSize,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
      ),
    );
  }
}

class _TextButtonWidget extends StatelessWidget {
  const _TextButtonWidget({
    required this.label,
    required this.onPressed,
    required this.padding,
    required this.fontSize,
    required this.loaderSize,
    required this.isLoading,
    required this.colorScheme,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double loaderSize;
  final bool isLoading;
  final ColorScheme colorScheme;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: fontSize);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        padding: padding,
        textStyle: labelStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        loaderSize: loaderSize,
        loaderColor: colorScheme.primary,
        fontSize: fontSize,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Secondary — Outlined using secondary color
// ---------------------------------------------------------------------------

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    required this.padding,
    required this.fontSize,
    required this.loaderSize,
    required this.isLoading,
    required this.colorScheme,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double loaderSize;
  final bool isLoading;
  final ColorScheme colorScheme;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: fontSize);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.secondary,
        disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
        side: BorderSide(
          color: onPressed == null && !isLoading
              ? cs.onSurface.withValues(alpha: 0.12)
              : cs.secondary,
        ),
        padding: padding,
        textStyle: labelStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        loaderSize: loaderSize,
        loaderColor: cs.secondary,
        fontSize: fontSize,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Danger — Filled using error color
// ---------------------------------------------------------------------------

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.onPressed,
    required this.padding,
    required this.fontSize,
    required this.loaderSize,
    required this.isLoading,
    required this.colorScheme,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double loaderSize;
  final bool isLoading;
  final ColorScheme colorScheme;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: fontSize);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.error,
        foregroundColor: cs.onError,
        disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: padding,
        textStyle: labelStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        loaderSize: loaderSize,
        loaderColor: cs.onError,
        fontSize: fontSize,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tertiary — Outlined using tertiary color
// ---------------------------------------------------------------------------

class _TertiaryButton extends StatelessWidget {
  const _TertiaryButton({
    required this.label,
    required this.onPressed,
    required this.padding,
    required this.fontSize,
    required this.loaderSize,
    required this.isLoading,
    required this.colorScheme,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double loaderSize;
  final bool isLoading;
  final ColorScheme colorScheme;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: fontSize);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
        padding: padding,
        textStyle: labelStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        loaderSize: loaderSize,
        loaderColor: cs.primary,
        fontSize: fontSize,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Link — Text button with underline, minimal tap area
// ---------------------------------------------------------------------------

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.onPressed,
    required this.padding,
    required this.fontSize,
    required this.loaderSize,
    required this.isLoading,
    required this.colorScheme,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double loaderSize;
  final bool isLoading;
  final ColorScheme colorScheme;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final activeColor = onPressed == null ? cs.onSurface.withValues(alpha: 0.38) : cs.primary;
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontSize: fontSize,
      color: activeColor,
      decoration: TextDecoration.underline,
      decorationColor: activeColor,
    );
    // Use InkWell directly so the ripple/hotspot is tight around the content.
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        child: _ButtonContent(
          label: label,
          isLoading: isLoading,
          loaderSize: loaderSize,
          loaderColor: activeColor,
          fontSize: fontSize,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
          overrideColor: activeColor,
          textStyle: labelStyle,
        ),
      ),
    );
  }
}
