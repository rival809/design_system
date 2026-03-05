import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../buttons/primary_button.dart';

/// Semantic intent of an [AppDialog] action button pair.
enum DialogType {
  /// Neutral informational dialog — primary button uses [AppColors.primary].
  info,

  /// Confirms a successful or positive action.
  success,

  /// Warns the user before proceeding with a risky action.
  warning,

  /// Confirms a destructive or irreversible action.
  destructive,
}

/// A design-system dialog definition — passed to [AppDialog.show].
///
/// Separates data/configuration from the widget so dialogs can be defined
/// declaratively and shown from non-widget code (e.g. BLoC, ViewModel).
class AppDialogConfig {
  const AppDialogConfig({
    required this.title,
    required this.content,
    this.type = DialogType.info,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.showCancelButton = true,
    this.isDismissible = true,
    this.icon,
  });

  /// Dialog heading.
  final String title;

  /// Body text or custom widget displayed below the title.
  final Widget content;

  /// Semantic intent that drives button color.
  final DialogType type;

  /// Label for the primary confirm action.
  final String confirmLabel;

  /// Label for the secondary cancel/dismiss action.
  final String cancelLabel;

  /// Whether to render the cancel button.
  final bool showCancelButton;

  /// Whether tapping outside the dialog dismisses it.
  final bool isDismissible;

  /// Optional icon rendered above the title.
  final Widget? icon;
}

/// Base dialog widget the design system uses to keep dialogs consistent.
///
/// ### Direct widget usage
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => AppDialog(
///     config: AppDialogConfig(
///       title: 'Delete item?',
///       content: const Text('This cannot be undone.'),
///       type: DialogType.destructive,
///       confirmLabel: 'Delete',
///       onConfirm: () { /* ... */ },
///     ),
///     onConfirm: _deleteItem,
///   ),
/// );
/// ```
///
/// ### Convenience helper
/// ```dart
/// final confirmed = await AppDialog.show(
///   context: context,
///   config: AppDialogConfig( ... ),
/// );
/// if (confirmed == true) { ... }
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({super.key, required this.config, this.onConfirm, this.onCancel});

  /// Data configuration for layout and labels.
  final AppDialogConfig config;

  /// Called when the confirm button is pressed. The dialog is automatically
  /// popped with `true` after this callback returns.
  final VoidCallback? onConfirm;

  /// Called when the cancel button is pressed. The dialog is automatically
  /// popped with `false` after this callback returns.
  final VoidCallback? onCancel;

  // ---------------------------------------------------------------------------
  // Convenience factory
  // ---------------------------------------------------------------------------

  /// Shows the dialog and returns `true` if confirmed, `false`/`null` otherwise.
  static Future<bool?> show({
    required BuildContext context,
    required AppDialogConfig config,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: config.isDismissible,
      builder: (_) => AppDialog(config: config, onConfirm: onConfirm, onCancel: onCancel),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color _confirmColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (config.type) {
      DialogType.info => colorScheme.primary,
      DialogType.success => AppColors.success,
      DialogType.warning => AppColors.warning,
      DialogType.destructive => AppColors.error,
    };
  }

  Color _iconColor(BuildContext context) => _confirmColor(context);

  Widget? _buildIcon(BuildContext context) {
    if (config.icon != null) {
      return IconTheme(
        data: IconThemeData(color: _iconColor(context), size: 40),
        child: config.icon!,
      );
    }

    IconData? iconData = switch (config.type) {
      DialogType.info => Icons.info_outline_rounded,
      DialogType.success => Icons.check_circle_outline_rounded,
      DialogType.warning => Icons.warning_amber_rounded,
      DialogType.destructive => Icons.error_outline_rounded,
    };

    return Icon(iconData, color: _iconColor(context), size: 40);
  }

  void _handleConfirm(BuildContext context) {
    onConfirm?.call();
    Navigator.of(context).pop(true);
  }

  void _handleCancel(BuildContext context) {
    onCancel?.call();
    Navigator.of(context).pop(false);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confirmColor = _confirmColor(context);

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLg),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Icon ----
            _buildIcon(context)!,
            const SizedBox(height: 16),

            // ---- Title ----
            Text(
              config.title,
              style: AppTextStyles.titleLarge.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // ---- Content ----
            DefaultTextStyle(
              style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
              child: config.content,
            ),
            const SizedBox(height: 24),

            // ---- Actions ----
            _DialogActions(
              confirmLabel: config.confirmLabel,
              cancelLabel: config.cancelLabel,
              showCancelButton: config.showCancelButton,
              confirmColor: confirmColor,
              onConfirm: () => _handleConfirm(context),
              onCancel: () => _handleCancel(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private action row
// ---------------------------------------------------------------------------

class _DialogActions extends StatelessWidget {
  const _DialogActions({
    required this.confirmLabel,
    required this.cancelLabel,
    required this.showCancelButton,
    required this.confirmColor,
    required this.onConfirm,
    required this.onCancel,
  });

  final String confirmLabel;
  final String cancelLabel;
  final bool showCancelButton;
  final Color confirmColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final confirmButton = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: confirmColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: AppTextStyles.labelLarge,
        ),
        child: Text(confirmLabel),
      ),
    );

    if (!showCancelButton) return confirmButton;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        confirmButton,
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: cancelLabel,
            variant: ButtonVariant.text,
            onPressed: onCancel,
            expand: true,
          ),
        ),
      ],
    );
  }
}
