import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Radius tokens — ubah di sini untuk mengubah radius seluruh app.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
}

/// Seed color utama brand — ganti nilai ini untuk mengubah seluruh palet.
const Color _seedColor = Color(0x00069550);

// ---------------------------------------------------------------------------
// Lora secondary text theme — exposed via ThemeExtension
// ---------------------------------------------------------------------------

/// Secondary typography menggunakan font Lora.
/// Akses via: `Theme.of(context).extension<LoraTextTheme>()!`
class LoraTextTheme extends ThemeExtension<LoraTextTheme> {
  const LoraTextTheme({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.bodyXSmall,
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle bodyXSmall;

  @override
  LoraTextTheme copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? bodyXSmall,
  }) => LoraTextTheme(
    displayLarge: displayLarge ?? this.displayLarge,
    displayMedium: displayMedium ?? this.displayMedium,
    displaySmall: displaySmall ?? this.displaySmall,
    headlineLarge: headlineLarge ?? this.headlineLarge,
    headlineMedium: headlineMedium ?? this.headlineMedium,
    headlineSmall: headlineSmall ?? this.headlineSmall,
    titleLarge: titleLarge ?? this.titleLarge,
    titleMedium: titleMedium ?? this.titleMedium,
    titleSmall: titleSmall ?? this.titleSmall,
    labelLarge: labelLarge ?? this.labelLarge,
    labelMedium: labelMedium ?? this.labelMedium,
    labelSmall: labelSmall ?? this.labelSmall,
    bodyLarge: bodyLarge ?? this.bodyLarge,
    bodyMedium: bodyMedium ?? this.bodyMedium,
    bodySmall: bodySmall ?? this.bodySmall,
    bodyXSmall: bodyXSmall ?? this.bodyXSmall,
  );

  @override
  LoraTextTheme lerp(LoraTextTheme? other, double t) {
    if (other == null) return this;
    return LoraTextTheme(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      bodyXSmall: TextStyle.lerp(bodyXSmall, other.bodyXSmall, t)!,
    );
  }
}

LoraTextTheme _buildLoraTextTheme() {
  TextStyle loraStyle(double size, FontWeight weight, double height) =>
      GoogleFonts.lora(fontSize: size, fontWeight: weight, height: height, letterSpacing: 0);

  return LoraTextTheme(
    // Display — Regular, line height 1.25
    displayLarge: loraStyle(34, FontWeight.w400, 1.25),
    displayMedium: loraStyle(32, FontWeight.w400, 1.25),
    displaySmall: loraStyle(30, FontWeight.w400, 1.25),
    // Headline — Medium, line height 1.25
    headlineLarge: loraStyle(28, FontWeight.w500, 1.25),
    headlineMedium: loraStyle(24, FontWeight.w500, 1.25),
    headlineSmall: loraStyle(20, FontWeight.w500, 1.25),
    // Title — SemiBold, line height 1.25
    titleLarge: loraStyle(18, FontWeight.w600, 1.25),
    titleMedium: loraStyle(16, FontWeight.w600, 1.25),
    titleSmall: loraStyle(14, FontWeight.w600, 1.25),
    // Label — Medium, line height 1.25
    labelLarge: loraStyle(14, FontWeight.w500, 1.25),
    labelMedium: loraStyle(12, FontWeight.w500, 1.25),
    labelSmall: loraStyle(10, FontWeight.w500, 1.25),
    // Body — Regular; Large/Medium=1.5, Small/XSmall=1.5
    bodyLarge: loraStyle(16, FontWeight.w400, 1.5),
    bodyMedium: loraStyle(14, FontWeight.w400, 1.5),
    bodySmall: loraStyle(12, FontWeight.w400, 1.5),
    bodyXSmall: loraStyle(10, FontWeight.w400, 1.5),
  );
}

/// Membangun [ThemeData] untuk light & dark mode.
///
/// Semua kustomisasi tema terpusat di sini.
ThemeData buildTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(seedColor: _seedColor, brightness: brightness);

  // Helper untuk membuat TextStyle Roboto sesuai spec
  TextStyle robotoStyle(double size, FontWeight weight, double height) =>
      GoogleFonts.roboto(fontSize: size, fontWeight: weight, height: height, letterSpacing: 0);

  final textTheme = TextTheme(
    // Display — Regular, line height 1.5
    displayLarge: robotoStyle(34, FontWeight.w400, 1.5),
    displayMedium: robotoStyle(32, FontWeight.w400, 1.5),
    displaySmall: robotoStyle(30, FontWeight.w400, 1.5),
    // Headline — Medium, line height 1.5
    headlineLarge: robotoStyle(28, FontWeight.w500, 1.5),
    headlineMedium: robotoStyle(24, FontWeight.w500, 1.5),
    headlineSmall: robotoStyle(20, FontWeight.w500, 1.5),
    // Title — SemiBold, line height 1.5
    titleLarge: robotoStyle(18, FontWeight.w600, 1.5),
    titleMedium: robotoStyle(16, FontWeight.w600, 1.5),
    titleSmall: robotoStyle(14, FontWeight.w600, 1.5),
    // Label — Medium, line height 1.5
    labelLarge: robotoStyle(14, FontWeight.w500, 1.5),
    labelMedium: robotoStyle(12, FontWeight.w500, 1.5),
    labelSmall: robotoStyle(10, FontWeight.w500, 1.5),
    // Body — Regular; Large=1.5, Medium/Small=1.25
    bodyLarge: robotoStyle(16, FontWeight.w400, 1.5),
    bodyMedium: robotoStyle(14, FontWeight.w400, 1.25),
    bodySmall: robotoStyle(12, FontWeight.w400, 1.25),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: textTheme,
    visualDensity: VisualDensity.standard,

    // ---- AppBar ----
    appBarTheme: const AppBarTheme(elevation: 0, scrolledUnderElevation: 1, centerTitle: false),

    // ---- Card ----
    cardTheme: CardThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      margin: EdgeInsets.zero,
    ),

    // ---- ElevatedButton ----
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // ---- OutlinedButton ----
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // ---- TextButton ----
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),

    // ---- TextField ----
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    ),

    // ---- Dialog ----
    dialogTheme: const DialogThemeData(
      elevation: 3,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg))),
    ),

    // ---- SnackBar ----
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.md))),
    ),

    // ---- Divider ----
    dividerTheme: const DividerThemeData(thickness: 1, space: 1),

    // ---- Extensions ----
    extensions: [_buildLoraTextTheme()],
  );
}
