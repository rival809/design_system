import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class TabsPage extends StatelessWidget {
  const TabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Flat', style: tt.titleSmall),
          const SizedBox(height: 12),
          const _FlatTabsDemo(),

          const SizedBox(height: 24),

          Text('Rounded', style: tt.titleSmall),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          const _RoundedTabsDemo(),
          const SizedBox(height: 12),
          const _RoundedTabsDemo(initialIndex: 1),
        ],
      ),
    );
  }
}

class _FlatTabsDemo extends StatelessWidget {
  const _FlatTabsDemo();

  @override
  Widget build(BuildContext context) {
    return AppTab(
      labels: ['Overview', 'Activity'],
      style: AppTabStyle.flat,
      children: [
        _TabContentCard(
          title: 'Overview',
          description: 'Ringkasan informasi akun dan status terbaru.',
          bullets: ['Total users: 1.248', 'Pending request: 12', 'Server uptime: 99.9%'],
        ),
        _TabContentCard(
          title: 'Activity',
          description: 'Riwayat aktivitas pengguna dalam 7 hari terakhir.',
          bullets: ['Login: 38 event', 'Update profile: 9 event', 'Reset password: 2 event'],
        ),
      ],
    );
  }
}

class _RoundedTabsDemo extends StatelessWidget {
  const _RoundedTabsDemo({this.initialIndex = 0});

  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppTab(
      labels: const ['Profile', 'Security'],
      style: AppTabStyle.rounded,
      initialIndex: initialIndex,
      height: 88,
      backgroundColor: cs.surfaceContainerHighest,
      selectedBackgroundColor: cs.surface,
      children: const [
        _TabContentCard(
          title: 'Profile',
          description: 'Informasi dasar pengguna: nama, email, dan role aktif.',
          bullets: ['Nama: John Doe', 'Email: john.doe@mail.com', 'Role: Administrator'],
        ),
        _TabContentCard(
          title: 'Security',
          description: 'Pengaturan keamanan: password, OTP, dan sesi login.',
          bullets: ['2FA: Aktif', 'Last password update: 3 hari lalu', 'Active sessions: 2 device'],
        ),
      ],
    );
  }
}

class _TabContentCard extends StatelessWidget {
  const _TabContentCard({required this.title, required this.description, required this.bullets});

  final String title;
  final String description;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tt.titleMedium),
          const SizedBox(height: 6),
          Text(description, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 10),
          for (final item in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: tt.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
