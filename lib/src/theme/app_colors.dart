import 'package:flutter/material.dart';

/// Centralized color palette for the design system.
///
/// All colors are defined as static constants and organized by role
/// (primary, neutral, semantic). Consume via [AppTheme] or directly
/// via `AppColors.<token>`.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Primary
  // ---------------------------------------------------------------------------

  /// Main brand color — used for primary actions, links, and accents.
  static const Color primary = Color(0xFF2563EB);

  /// Lighter tint of [primary], suitable for hover/focus states.
  static const Color primaryLight = Color(0xFF60A5FA);

  /// Darker shade of [primary], suitable for pressed states.
  static const Color primaryDark = Color(0xFF1D4ED8);

  /// Color used for content placed on top of [primary] backgrounds.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Subtle tinted container for primary elements (chips, badges, etc.).
  static const Color primaryContainer = Color(0xFFDBEAFE);

  /// Content color on top of [primaryContainer].
  static const Color onPrimaryContainer = Color(0xFF1E3A8A);

  // ---------------------------------------------------------------------------
  // Secondary
  // ---------------------------------------------------------------------------

  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF5B21B6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFEDE9FE);
  static const Color onSecondaryContainer = Color(0xFF3B0764);

  // ---------------------------------------------------------------------------
  // Neutral / Surface
  // ---------------------------------------------------------------------------

  /// App background color (light theme).
  static const Color background = Color(0xFFF8FAFC);

  /// Primary surface color (cards, sheets, dialogs).
  static const Color surface = Color(0xFFFFFFFF);

  /// Slightly elevated surface (e.g., bottom nav, app-bar).
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  /// Content color on top of [surface].
  static const Color onSurface = Color(0xFF0F172A);

  /// Muted content color for secondary text on surfaces.
  static const Color onSurfaceVariant = Color(0xFF64748B);

  // ---------------------------------------------------------------------------
  // Outline / Border
  // ---------------------------------------------------------------------------

  /// Default border / divider color.
  static const Color outline = Color(0xFFCBD5E1);

  /// Subtle variant for low-emphasis separators.
  static const Color outlineVariant = Color(0xFFE2E8F0);

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------

  /// Indicates a successful or positive state.
  static const Color success = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccessContainer = Color(0xFF14532D);

  /// Indicates a warning or caution state.
  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF78350F);

  /// Indicates a destructive or error state.
  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF7F1D1D);
  static const Color onError = Color(0xFFFFFFFF);

  /// Informational state.
  static const Color info = Color(0xFF0284C7);
  static const Color infoContainer = Color(0xFFE0F2FE);
  static const Color onInfoContainer = Color(0xFF082F49);

  // ---------------------------------------------------------------------------
  // Disabled
  // ---------------------------------------------------------------------------

  /// Color for disabled interactive elements.
  static const Color disabled = Color(0xFFCBD5E1);

  /// Content color on top of [disabled] backgrounds.
  static const Color onDisabled = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------------
  // Dark theme overrides
  // ---------------------------------------------------------------------------

  static const Color primaryDarkTheme = Color(0xFF60A5FA);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color onSurfaceDark = Color(0xFFF1F5F9);
  static const Color onSurfaceVariantDark = Color(0xFF94A3B8);
  static const Color outlineDark = Color(0xFF475569);
  static const Color outlineVariantDark = Color(0xFF334155);
}
