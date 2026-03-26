import 'package:flutter/material.dart';

/// Sebuah layout wrapper yang merender UI berbeda berdasarkan lebar layar
/// (breakpoint). Ini adalah best practice untuk memisahkan desain mobile (list)
/// dan desain desktop (table) secara bersih tanpa if-else berantakan di dalam
/// satu widget tree besar.
class AppAdaptiveLayout extends StatelessWidget {
  const AppAdaptiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
    this.breakpoint = 768.0,
  });

  /// Widget yang akan di-render saat constraint lebar < [breakpoint]
  final Widget mobile;

  /// Widget yang akan di-render saat constraint lebar >= [breakpoint]
  final Widget desktop;

  /// Titik potong lebar layar. Default 768.0 (ukuran tablet pada umumnya).
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return mobile;
        }
        return desktop;
      },
    );
  }
}
