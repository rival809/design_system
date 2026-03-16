import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'app_theme.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_notifier.dart';

class ErrorReporter {
  static bool _isHotRestartWebViewDisposeAssertion(FlutterErrorDetails details) {
    if (!kIsWeb) return false;
    final message = details.exceptionAsString();
    return message.contains('Trying to render a disposed EngineFlutterView');
  }

  static Logger _createLogger() => Logger(
    printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8, lineLength: 100, colors: true),
  );

  static void logFlutterError(FlutterErrorDetails details) {
    if (_isHotRestartWebViewDisposeAssertion(details)) {
      // Known transient assertion on Flutter web during restart/hot restart.
      return;
    }

    final logger = _createLogger();
    logger.e('FlutterError caught', error: details.exception, stackTrace: details.stack);
    FlutterError.presentError(details);
  }

  static void logError(Object error, StackTrace stackTrace) {
    final logger = _createLogger();
    logger.e('Uncaught error', error: error, stackTrace: stackTrace);
  }
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        ErrorReporter.logFlutterError(details);
      };

      await initDependencies();

      runApp(const MyApp());
    },
    (error, stackTrace) {
      ErrorReporter.logError(error, stackTrace);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = sl<ThemeNotifier>();

    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, __) {
        // Tentukan theme mana yang aktif berdasarkan themeMode
        final bool isDark =
            themeNotifier.themeMode == ThemeMode.dark ||
            (themeNotifier.themeMode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);

        final activeTheme = isDark ? buildTheme(Brightness.dark) : buildTheme(Brightness.light);

        return MaterialApp.router(
          title: 'Design System Showcase',
          debugShowCheckedModeBanner: false,
          theme: activeTheme, // Tetap pasang theme default
          routerConfig: appRouter,
          // DI SINI KUNCI ANIMASINYA:
          builder: (context, child) {
            return AnimatedTheme(
              data: activeTheme,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              child: child!,
            );
          },
        );
      },
    );
  }
}
