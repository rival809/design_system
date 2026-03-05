import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Visual variant for [PrimaryButton].
enum ButtonVariant {
  /// Filled solid background using the primary color.
  filled,

  /// Outlined with a transparent background and primary-colored border.
  outlined,

  /// Text-only, no background or border.
  text,
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
  });

  final String label;
  final bool isLoading;
  final double loaderSize;
  final Color loaderColor;
  final double fontSize;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

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

    if (leadingIcon == null && trailingIcon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 8)],
        Text(label),
        if (trailingIcon != null) ...[const SizedBox(width: 8), trailingIcon!],
      ],
    );
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
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: AppColors.onDisabled,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
        padding: padding,
        textStyle: AppTextStyles.labelLarge.copyWith(fontSize: fontSize),
      ),
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        loaderSize: loaderSize,
        loaderColor: AppColors.onPrimary,
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
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: AppColors.onDisabled,
        side: BorderSide(
          color: onPressed == null && !isLoading ? AppColors.disabled : colorScheme.primary,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
        padding: padding,
        textStyle: AppTextStyles.labelLarge.copyWith(fontSize: fontSize),
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
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: AppColors.onDisabled,
        shape: const RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusSm),
        padding: padding,
        textStyle: AppTextStyles.labelLarge.copyWith(fontSize: fontSize),
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
