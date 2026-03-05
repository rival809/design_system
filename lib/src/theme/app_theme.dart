import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds [ThemeData] objects (light + dark) that wire [AppColors] and
/// [AppTextStyles] into Flutter's Material 3 token system.
///
/// **Usage in the host app**
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light(),
///   darkTheme: AppTheme.dark(),
/// );
/// ```
abstract final class AppTheme {
  // ---------------------------------------------------------------------------
  // Shared radius token
  // ---------------------------------------------------------------------------

  /// Default border radius used across cards, buttons, dialogs, etc.
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12));

  /// Radius token for small elements (chips, badges, text fields).
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(8));

  /// Radius token for large elements (bottom sheets, large cards).
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(20));

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  /// Returns the light [ThemeData] for the design system.
  static ThemeData light({String? fontFamily}) {
    final colorScheme = _lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      textTheme: _buildTextTheme(AppColors.onSurface),
      scaffoldBackgroundColor: AppColors.background,

      // ---- AppBar ----
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.onSurface),
      ),

      // ---- Card ----
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),

      // ---- ElevatedButton ----
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.onDisabled,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ---- OutlinedButton ----
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.onDisabled,
          side: const BorderSide(color: AppColors.primary),
          shape: const RoundedRectangleBorder(borderRadius: borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ---- TextButton ----
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: borderRadiusSm),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // ---- InputDecoration (TextField) ----
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        floatingLabelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),

      // ---- Dialog ----
      dialogTheme: DialogThemeData(
        elevation: 3,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: borderRadiusLg),
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // ---- SnackBar ----
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.surface),
        shape: const RoundedRectangleBorder(borderRadius: borderRadius),
      ),

      // ---- Chip ----
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        shape: const StadiumBorder(),
        labelStyle: AppTextStyles.labelMedium,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ---- Divider ----
      dividerTheme: const DividerThemeData(color: AppColors.outlineVariant, thickness: 1, space: 1),
    );
  }

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  /// Returns the dark [ThemeData] for the design system.
  static ThemeData dark({String? fontFamily}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      fontFamily: fontFamily,
      textTheme: _buildTextTheme(AppColors.onSurfaceDark),
      scaffoldBackgroundColor: AppColors.backgroundDark,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.onSurfaceDark,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.onSurfaceDark),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: AppColors.outlineDark),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkTheme,
          foregroundColor: AppColors.backgroundDark,
          disabledBackgroundColor: AppColors.outlineDark,
          disabledForegroundColor: AppColors.onSurfaceVariantDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDarkTheme,
          side: const BorderSide(color: AppColors.primaryDarkTheme),
          shape: const RoundedRectangleBorder(borderRadius: borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariantDark),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariantDark),
        floatingLabelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryDarkTheme),
        border: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.outlineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.primaryDarkTheme, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusSm,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: borderRadiusLg),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.onSurfaceDark),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariantDark),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariantDark,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static ColorScheme get _lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.info,
    onTertiary: AppColors.onPrimary,
    tertiaryContainer: AppColors.infoContainer,
    onTertiaryContainer: AppColors.onInfoContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
  );

  static ColorScheme get _darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDarkTheme,
    onPrimary: AppColors.backgroundDark,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.backgroundDark,
    secondaryContainer: AppColors.secondaryDark,
    onSecondaryContainer: AppColors.secondaryLight,
    tertiary: AppColors.info,
    onTertiary: AppColors.backgroundDark,
    tertiaryContainer: AppColors.onInfoContainer,
    onTertiaryContainer: AppColors.infoContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.onErrorContainer,
    onErrorContainer: AppColors.errorContainer,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.onSurfaceVariantDark,
    outline: AppColors.outlineDark,
    outlineVariant: AppColors.outlineVariantDark,
  );

  static TextTheme _buildTextTheme(Color defaultColor) => TextTheme(
    displayLarge: AppTextStyles.displayLarge.copyWith(color: defaultColor),
    displayMedium: AppTextStyles.displayMedium.copyWith(color: defaultColor),
    displaySmall: AppTextStyles.displaySmall.copyWith(color: defaultColor),
    headlineLarge: AppTextStyles.headlineLarge.copyWith(color: defaultColor),
    headlineMedium: AppTextStyles.headlineMedium.copyWith(color: defaultColor),
    headlineSmall: AppTextStyles.headlineSmall.copyWith(color: defaultColor),
    titleLarge: AppTextStyles.titleLarge.copyWith(color: defaultColor),
    titleMedium: AppTextStyles.titleMedium.copyWith(color: defaultColor),
    titleSmall: AppTextStyles.titleSmall.copyWith(color: defaultColor),
    labelLarge: AppTextStyles.labelLarge.copyWith(color: defaultColor),
    labelMedium: AppTextStyles.labelMedium.copyWith(color: defaultColor),
    labelSmall: AppTextStyles.labelSmall.copyWith(color: defaultColor),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: defaultColor),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(color: defaultColor),
    bodySmall: AppTextStyles.bodySmall.copyWith(color: defaultColor),
  );
}
