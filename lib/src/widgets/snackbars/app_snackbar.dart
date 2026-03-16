import 'package:flutter/material.dart';

/// Semantic intent of an [AppSnackbar].
enum SnackbarType {
  /// Neutral informational message.
  info,

  /// Confirms a successful operation.
  success,

  /// Warns the user about something.
  warning,

  /// Indicates an error or failure.
  error,
}

/// A design-system helper for showing consistent, theme-aware snackbars.
///
/// ### Basic usage
/// ```dart
/// AppSnackbar.show(
///   context,
///   message: 'Data berhasil disimpan.',
///   type: SnackbarType.success,
/// );
/// ```
///
/// ### With a custom action
/// ```dart
/// AppSnackbar.show(
///   context,
///   message: 'Gagal memuat data.',
///   type: SnackbarType.error,
///   actionLabel: 'Coba Lagi',
///   onAction: _reload,
/// );
/// ```
abstract class AppSnackbar {
  // ── Token maps — mirrors PrimaryButton color tokens ─────────────────────────
  //   info    → ButtonVariant.filled   → cs.primary    / cs.onPrimary
  //   success → ButtonVariant.secondary (filled)       → cs.secondary / cs.onSecondary
  //   warning → ButtonVariant.tertiary (filled)        → cs.tertiary  / cs.onTertiary
  //   error   → ButtonVariant.danger   → cs.error      / cs.onError

  static Color _background(BuildContext context, SnackbarType type) {
    final cs = Theme.of(context).colorScheme;
    return switch (type) {
      SnackbarType.info => cs.primary,
      SnackbarType.success => cs.secondary,
      SnackbarType.warning => cs.tertiary,
      SnackbarType.error => cs.error,
    };
  }

  static Color _foreground(BuildContext context, SnackbarType type) {
    final cs = Theme.of(context).colorScheme;
    return switch (type) {
      SnackbarType.info => cs.onPrimary,
      SnackbarType.success => cs.onSecondary,
      SnackbarType.warning => cs.onTertiary,
      SnackbarType.error => cs.onError,
    };
  }

  /// OK/action button: inverted — foreground becomes bg, background becomes text.
  /// Mirrors the filled-button pattern (text always contrasts with its own fill).
  static ({Color bg, Color fg}) _buttonColors(BuildContext context, SnackbarType type) {
    final fg = _foreground(context, type);
    // Semi-transparent version of fg overlaid on snackbar bg = readable filled button
    return (bg: fg.withValues(alpha: 0.18), fg: fg);
  }

  static IconData _icon(SnackbarType type) => switch (type) {
    SnackbarType.info => Icons.info_outline_rounded,
    SnackbarType.success => Icons.check_circle_outline_rounded,
    SnackbarType.warning => Icons.warning_amber_rounded,
    SnackbarType.error => Icons.error_outline_rounded,
  };

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Shows a floating snackbar built from design-system tokens.
  ///
  /// [context] must be a valid [BuildContext] reachable by [ScaffoldMessenger].
  ///
  /// [message] is the main body text.
  ///
  /// [type] drives the color scheme and leading icon. Defaults to [SnackbarType.info].
  ///
  /// [actionLabel] shows a custom action button (e.g. "Coba Lagi"). When
  /// omitted, a default "OK" dismiss button is shown.
  ///
  /// [onAction] is called when the custom action button is tapped.
  ///
  /// [duration] controls how long the snackbar stays on screen.
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final bg = _background(context, type);
    final btnColors = _buttonColors(context, type);
    final fg = btnColors.fg;
    final icon = _icon(type);
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: btnColors.fg,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    final effectiveLabel = actionLabel ?? 'OK';
    final effectiveAction = actionLabel != null ? onAction : null;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          // Remove default horizontal padding so we can control layout manually.
          padding: EdgeInsets.zero,
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: fg, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: fg),
                  ),
                ),
                const SizedBox(width: 8),
                // Filled mini-button styled like PrimaryButton
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    effectiveAction?.call();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: btnColors.bg,
                    foregroundColor: btnColors.fg,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: labelStyle,
                  ),
                  child: Text(effectiveLabel),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
