import 'package:flutter/material.dart';
import '../buttons/primary_button.dart';

/// Supported semantic layouts for [AppDialog].
enum DialogType {
  /// Success state with centered icon and message.
  success,

  /// Failed state with centered icon and message.
  fail,

  /// Confirmation state with title and supporting message.
  confirm,
}

/// Declarative action config for [AppDialog].
class AppDialogAction {
  const AppDialogAction({
    required this.id,
    required this.label,
    this.variant = ButtonVariant.filled,
    this.onPressed,
    this.closeDialog = true,
  });

  /// Unique id returned by [AppDialog.show] when this action is pressed.
  final String id;

  /// Label shown inside the button.
  final String label;

  /// Visual button variant.
  final ButtonVariant variant;

  /// Optional callback when pressed.
  final VoidCallback? onPressed;

  /// Whether pressing this action should dismiss the dialog.
  final bool closeDialog;
}

/// A design-system dialog definition — passed to [AppDialog.show].
///
/// Separates data/configuration from the widget so dialogs can be defined
/// declaratively and shown from non-widget code (e.g. BLoC, ViewModel).
class AppDialogConfig {
  const AppDialogConfig({
    required this.type,
    required this.message,
    required this.actions,
    this.title,
    this.isDismissible = true,
    this.icon,
  }) : assert(actions.length >= 1 && actions.length <= 2, 'Actions must be 1 or 2 buttons.');

  /// Dialog layout type.
  final DialogType type;

  /// Optional heading. Intended for [DialogType.confirm].
  final String? title;

  /// Main message text.
  final String message;

  /// One or two actions rendered at the bottom.
  final List<AppDialogAction> actions;

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
///       type: DialogType.confirm,
///       title: 'Konfirmasi',
///       message: 'Lanjutkan proses ini?',
///       actions: [
///         AppDialogAction(
///           id: 'cancel',
///           label: 'Periksa Kembali',
///           variant: ButtonVariant.secondary,
///         ),
///         AppDialogAction(id: 'ok', label: 'Ya, saya mengerti'),
///       ],
///     ),
///   ),
/// );
/// ```
///
/// ### Convenience helper
/// ```dart
/// final actionId = await AppDialog.show(
///   context: context,
///   config: AppDialogConfig( ... ),
/// );
/// if (actionId == 'ok') { ... }
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({super.key, required this.config});

  /// Data configuration for layout and labels.
  final AppDialogConfig config;

  // ---------------------------------------------------------------------------
  // Convenience factory
  // ---------------------------------------------------------------------------

  /// Shows the dialog and returns the selected action id.
  static Future<String?> show({
    required BuildContext context,
    required AppDialogConfig config,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: config.isDismissible,
      builder: (_) => AppDialog(config: config),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color _accentColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (config.type) {
      DialogType.success => cs.primary,
      DialogType.fail => cs.error,
      DialogType.confirm => cs.primary,
    };
  }

  Color _iconColor(BuildContext context) => _accentColor(context);

  Widget? _buildIcon(BuildContext context) {
    if (config.type == DialogType.confirm && config.icon == null) {
      return null;
    }

    if (config.icon != null) {
      return IconTheme(
        data: IconThemeData(color: _iconColor(context), size: 40),
        child: config.icon!,
      );
    }

    IconData? iconData = switch (config.type) {
      DialogType.success => Icons.check_circle_outline_rounded,
      DialogType.fail => Icons.close_rounded,
      DialogType.confirm => null,
    };

    if (iconData == null) return null;

    return Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(iconData, color: _iconColor(context), size: 56),
    );
  }

  void _handleAction(BuildContext context, AppDialogAction action) {
    action.onPressed?.call();
    if (action.closeDialog) {
      Navigator.of(context).pop(action.id);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _buildIcon(context);
    final isConfirm = config.type == DialogType.confirm;
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface);
    final messageStyle = isConfirm
        ? theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)
        : theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isConfirm ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Align(alignment: Alignment.center, child: icon),
                const SizedBox(height: 16),
              ],
              if (config.title != null && config.title!.isNotEmpty) ...[
                Text(
                  config.title!,
                  style: titleStyle,
                  textAlign: isConfirm ? TextAlign.left : TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                config.message,
                style: messageStyle,
                textAlign: isConfirm ? TextAlign.left : TextAlign.center,
              ),
              const SizedBox(height: 24),
              _DialogActions(
                actions: config.actions,
                onActionTap: (action) => _handleAction(context, action),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private action row
// ---------------------------------------------------------------------------

class _DialogActions extends StatelessWidget {
  const _DialogActions({required this.actions, required this.onActionTap});

  final List<AppDialogAction> actions;
  final ValueChanged<AppDialogAction> onActionTap;

  @override
  Widget build(BuildContext context) {
    if (actions.length == 1) {
      final action = actions.first;
      return PrimaryButton(
        label: action.label,
        variant: action.variant,
        expand: true,
        onPressed: () => onActionTap(action),
      );
    }

    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: actions[i].label,
              variant: actions[i].variant,
              expand: true,
              onPressed: () => onActionTap(actions[i]),
            ),
          ),
        ],
      ],
    );
  }
}
