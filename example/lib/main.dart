import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'app_theme.dart';
import 'pages/colors_page.dart';
import 'pages/typography_page.dart';
import 'pages/buttons_page.dart';
import 'pages/inputs_page.dart';
import 'pages/dialogs_page.dart';
import 'pages/form_page.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 100,
    colors: true,
    printEmojis: true,
  ),
);

class ErrorReporter {
  static void logFlutterError(FlutterErrorDetails details) {
    logger.e(
      'FlutterError caught',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  }

  static void logError(Object error, StackTrace stackTrace) {
    logger.e('Uncaught error', error: error, stackTrace: stackTrace);
  }
}

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      ErrorReporter.logFlutterError(details);
    };

    runApp(const MyApp());
  }, (error, stackTrace) {
    ErrorReporter.logError(error, stackTrace);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design System Showcase',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: _themeMode,
      home: _ShowcasePage(onToggleTheme: _toggleTheme, themeMode: _themeMode),
    );
  }
}

// ---------------------------------------------------------------------------
// Showcase page
// ---------------------------------------------------------------------------

class _ShowcasePage extends StatefulWidget {
  const _ShowcasePage({required this.onToggleTheme, required this.themeMode});

  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  @override
  State<_ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<_ShowcasePage> {
  int _selectedIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.palette_outlined),
      selectedIcon: Icon(Icons.palette),
      label: 'Colors',
    ),
    NavigationDestination(
      icon: Icon(Icons.text_fields_outlined),
      selectedIcon: Icon(Icons.text_fields),
      label: 'Typography',
    ),
    NavigationDestination(
      icon: Icon(Icons.smart_button_outlined),
      selectedIcon: Icon(Icons.smart_button),
      label: 'Buttons',
    ),
    NavigationDestination(
      icon: Icon(Icons.input_outlined),
      selectedIcon: Icon(Icons.input),
      label: 'Inputs',
    ),
    NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble),
      label: 'Dialogs',
    ),
    NavigationDestination(
      icon: Icon(Icons.edit_note_outlined),
      selectedIcon: Icon(Icons.edit_note),
      label: 'Form',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ColorsPage(),
      const TypographyPage(),
      const ButtonsPage(),
      const InputsPage(),
      const DialogsPage(),
      const FormPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System'),
        actions: [
          IconButton(
            tooltip: widget.themeMode == ThemeMode.dark
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: _destinations,
      ),
    );
  }
}
