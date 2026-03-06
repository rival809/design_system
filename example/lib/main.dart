import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'app_theme.dart';
import 'core/di/injection_container.dart';
import 'pages/colors_page.dart';
import 'pages/typography_page.dart';
import 'pages/buttons_page.dart';
import 'pages/inputs_page.dart';
import 'pages/dialogs_page.dart';
import 'pages/form_page.dart';
import 'features/user_registration/presentation/pages/registration_page.dart';

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
    logger.e('FlutterError caught', error: details.exception, stackTrace: details.stack);
    FlutterError.presentError(details);
  }

  static void logError(Object error, StackTrace stackTrace) {
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
  bool _showRegister = false;

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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    const pages = <Widget>[
      ColorsPage(),
      TypographyPage(),
      ButtonsPage(),
      InputsPage(),
      DialogsPage(),
      FormPage(),
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
      drawer: NavigationDrawer(
        selectedIndex: _showRegister ? 6 : _selectedIndex,
        onDestinationSelected: (i) {
          if (i == 6) {
            setState(() => _showRegister = true);
          } else {
            setState(() {
              _selectedIndex = i;
              _showRegister = false;
            });
          }
          Navigator.pop(context);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Showcase', style: tt.titleSmall),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette),
            label: Text('Colors'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.text_fields_outlined),
            selectedIcon: Icon(Icons.text_fields),
            label: Text('Typography'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.smart_button_outlined),
            selectedIcon: Icon(Icons.smart_button),
            label: Text('Buttons'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.input_outlined),
            selectedIcon: Icon(Icons.input),
            label: Text('Inputs'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: Text('Dialogs'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: Text('Form'),
          ),
          const Divider(indent: 28, endIndent: 28),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 16, 10),
            child: Text('API Demo', style: tt.titleSmall),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.person_add_outlined),
            selectedIcon: Icon(Icons.person_add, color: cs.primary),
            label: const Text('Register'),
          ),
        ],
      ),
      body: _showRegister
          ? const RegistrationPage()
          : IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _showRegister
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: _destinations,
            ),
    );
  }
}
