import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/user_registration/presentation/pages/registration_page.dart';
import '../../features/user_registration/presentation/pages/user_list_page.dart';
import '../../pages/buttons_page.dart';
import '../../pages/colors_page.dart';
import '../../pages/dialogs_page.dart';
import '../../pages/form_page.dart';
import '../../pages/inputs_page.dart';
import '../../pages/section_messages_page.dart';
import '../../pages/tabs_page.dart';
import '../../pages/typography_page.dart';
import '../di/injection_container.dart';
import '../theme/theme_notifier.dart';
import 'route_paths.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────────────────────────────────────

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: RoutePaths.colors,
  redirect: (_, state) => state.uri.path == '/' ? RoutePaths.colors : null,
  routes: [
    // ── Shell: Showcase tabs (NavigationBar + NavigationDrawer) ───────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ShowcaseShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: RoutePaths.colors, builder: (_, __) => const ColorsPage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: RoutePaths.typography, builder: (_, __) => const TypographyPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: RoutePaths.buttons, builder: (_, __) => const ButtonsPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: RoutePaths.tabs, builder: (_, __) => const TabsPage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.sectionMessages,
              builder: (_, __) => const SectionMessagesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: RoutePaths.inputs, builder: (_, __) => const InputsPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: RoutePaths.dialogs, builder: (_, __) => const DialogsPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: RoutePaths.form, builder: (_, __) => const FormPage())],
        ),
      ],
    ),

    // ── Full-page routes (outside shell) ──────────────────────────────────────
    GoRoute(path: RoutePaths.register, builder: (_, __) => const RegistrationPage()),
    GoRoute(path: RoutePaths.users, builder: (_, __) => const UserListPage()),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// Shell scaffold — wraps the showcase IndexedStack
// ─────────────────────────────────────────────────────────────────────────────

class ShowcaseShell extends StatelessWidget {
  const ShowcaseShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  // Ordered to match StatefulShellBranch indices above.
  static const _destinations = [
    (icon: Icons.palette_outlined, selectedIcon: Icons.palette, label: 'Colors'),
    (icon: Icons.text_fields_outlined, selectedIcon: Icons.text_fields, label: 'Typography'),
    (icon: Icons.smart_button_outlined, selectedIcon: Icons.smart_button, label: 'Buttons'),
    (icon: Icons.tab_outlined, selectedIcon: Icons.tab, label: 'Tabs'),
    (icon: Icons.segment_outlined, selectedIcon: Icons.segment, label: 'Section Messages'),
    (icon: Icons.input_outlined, selectedIcon: Icons.input, label: 'Inputs'),
    (icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble, label: 'Dialogs'),
    (icon: Icons.edit_note_outlined, selectedIcon: Icons.edit_note, label: 'Form'),
  ];

  void _switchBranch(int index) {
    navigationShell.goBranch(
      index,
      // Re-tap the current tab → return to the branch's initial location.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Design System'), actions: const [_ThemeToggleButton()]),
      drawer: NavigationDrawer(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) {
          Navigator.pop(context); // close drawer
          if (i < _destinations.length) {
            _switchBranch(i);
          } else {
            context.go(RoutePaths.register);
          }
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Showcase', style: tt.titleSmall),
          ),
          for (final d in _destinations)
            NavigationDrawerDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: Text(d.label),
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
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _switchBranch,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme toggle button — listens to ThemeNotifier independently
// ─────────────────────────────────────────────────────────────────────────────

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final notifier = sl<ThemeNotifier>();
    return ListenableBuilder(
      listenable: notifier,
      builder: (_, __) => IconButton(
        tooltip: notifier.themeMode == ThemeMode.dark
            ? 'Switch to light mode'
            : 'Switch to dark mode',
        icon: Icon(
          notifier.themeMode == ThemeMode.dark
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
        ),
        onPressed: notifier.toggle,
      ),
    );
  }
}
